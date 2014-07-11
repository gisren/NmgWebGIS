////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	图形缓冲
//
//	通过对 gis api 中的 buffer 功能进行基本封装实现
//  传入图形缓冲所需的基本参数得到缓冲后的图形
//
//  Author：liuXL
//  Date：2012-03-13
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.Buffer
{
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	
	import mx.managers.CursorManager;
	import mx.rpc.AsyncResponder;
	
	/**
	 *
	 * <p>图形缓冲。</p>
	 *  
	 * @author LiuXL
	 * 
	 */	
	public class Buffer
	{
		
		/**
		 * 
		 * <p>对传入的几何图形进行缓冲并得到缓冲图形</p>
		 * 
		 * @param geomServUrl 几何服务地址
		 * @param geometry 要进行缓冲的几何图形。数组格式，可同时缓冲多个图形
		 * @param distances 要缓冲的距离。数组格式，可对每个几何图形进行不同距离的多层缓冲
		 * @param unit 缓冲距离的单位。从 GeometryService 中获取
		 * @param onResult 缓冲成功后要执行的方法, 参数为数组格式
		 * @param resultParam 要对缓冲成功后执行的方法传递的额外参数
		 * @param onFault 缓冲失败后要执行的方法
		 * @param faultParam 要对缓冲失败后执行的方法传递的额外参数
		 * @param spatialReference 要缓冲的几何图形、缓冲方法、缓冲后的输出图形的空间参考坐标系，
		 * 							如果要缓冲的几何图形因为没有空间参考坐标系而报错，可以在此传入来解决。
		 * 
		 */		
		public function Buffer(geomServUrl:String, geometry:Array, distances:Array, unit:Number, onResult:Function, 
							   resultParam:Object, onFault:Function, faultParam:Object, 
							   spatialReference:SpatialReference):void
		{
			geometry = checkGeometryData(geometry, spatialReference);
			
			if(!geometry || !distances)
			{
				return ;
			}
			for each(var geom:Geometry in geometry)
			{
				if(!geom)
					return;
			}
			for each(var distan:Number in distances)
			{
				if(!distan)
					return;
			}
			
			var bufferParameters:BufferParameters = new BufferParameters();
			bufferParameters.geometries = geometry;
			bufferParameters.distances = distances;
			bufferParameters.unit = unit;
			bufferParameters.bufferSpatialReference = new SpatialReference(102113);
			
			if(spatialReference)
			{
				bufferParameters.outSpatialReference = spatialReference;
			}
			
			var myGeometryService:GeometryService = new GeometryService(geomServUrl);
			myGeometryService.buffer(bufferParameters, new AsyncResponder(result,fault));
			
			//鼠标光标设置为忙碌
			CursorManager.setBusyCursor();
			
			function result(event:Array, token:Object):void
			{
				//清除忙碌图标
				CursorManager.removeBusyCursor();
				
				if(resultParam)
				{
					onResult(event, resultParam);
				}
				else
				{
					onResult(event);
				}
			}
			
			function fault(error:Error,token:Object):void
			{
				//清除忙碌光标
				CursorManager.removeBusyCursor();
				
				if(onFault != null)
				{
					if(faultParam)
					{
						onFault(error, faultParam);
					}
					else
					{
						onFault(error);
					}
				}
				else
				{
					var geom:String = "";
					var diat:String = "";
					var unit:String = "";
					
					if(geometry)
						geom = geometry.toString();
					if(distances)
						diat = distances.toString();
					if(unit)
						unit = unit.toString();
					
					showError(
						"错误：在调用几何服务来计算得到缓冲后的几何图形时发生错误\n" +
						"几何图形：" + geom + "\n" +
						"缓冲距离：" + diat + "\n" +
						"距离单位代码：" + unit + "\n" +
						+ error.toString()
					);
				}
			}
		}
		
		
		/**
		 *
		 * 检查传入的几何数据的格式
		 * 为没有空间参考的几何图层添加空间参考系
		 *  
		 * @param geometry 几何数据集合
		 * 
		 * @return 检查后没有问题的数据
		 * 
		 */		
		private function  checkGeometryData(geometry:Array, spatialReference:SpatialReference):Array
		{
			if(geometry && geometry.length)
			{
				var isFine:Boolean = true;
				
				for(var i:int=0; i<geometry.length; i++)
				{
					var geom:Geometry = geometry[i];
					
					if(geom)
					{
						if(!geom.spatialReference)
						{
							if(spatialReference)
							{
								geom.spatialReference = spatialReference;
								geometry[i] = geom;
							}
							else
							{
								showError("错误：传入的几何图形数据中第"+i+"个图形\n"+geom.toString()+"\n没有空间参考坐标系");
								isFine = false;						
							}
						}
					}
					else
					{
						showError("错误：传入的几何图形数据中第"+i+"个数据为空");
						isFine = false;
					}
				}
				
				if(isFine)
				{
					return geometry;
				}
			}
			else
			{
				showError("错误：传入的几何图形数据为空");
			}
			
			return null;
		}
		
		
		/**
		 * 
		 * 弹出错误提示窗口
		 * 
		 * @param errorInfo 错误信息
		 * 
		 */		
		private function showError(errorInfo:String):void
		{
			var classInfo:String = "方法：UB_Buffer \n功能：根据传入的参数得到缓冲后的图形 \n";
			
			var error:String = classInfo + errorInfo; 
			
			new ErrorClass(error);
		}
		
		
		
		
	}
}