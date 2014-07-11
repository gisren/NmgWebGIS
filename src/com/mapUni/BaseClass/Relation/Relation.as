////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	图形叠加分析
//
//	通过对 gis api 中的 relation 功能进行基本封装实现
//  传入图形1和图形2，通过调用后台几何服务中 relation 功能，
//  得到两组空间数据中各个图形间的空间关系
//
//  Author：MengY
//  Date：2012-03-16
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.Relation
{
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.RelationParameters;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	import com.mapUni.BaseClass.MapUni;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncResponder;
	import mx.rpc.events.FaultEvent;
	
	
	public class Relation
	{
		
		/**
		 * 
		 * <p>比较传入两组几何图形中各个图形间的空间关系</p>
		 * 
		 * @param geomServUrl 几何服务地址
		 * @param geometryList1 被搜索的几何图形集合
		 * @param geometryList2 搜索条件几何图形集合
		 * @param onResult 缓冲成功后要执行的方法,参数为一个数组
		 * @param resultParam 要对缓冲成功后执行的方法传递的额外参数
		 * @param onFault 缓冲失败后要执行的方法
		 * @param faultParam 要对缓冲失败后执行的方法传递的额外参数
		 * @param spatialRelationship 指定两组几何图形要素满足的空间关系，可以通过RelationParameters中的静态常量来指定此参数值，默认为完全包含。
		 * 
		 */		
		public function Relation(geomServUrl:String, geometryList1:Array, geometryList2:Array, onResult:Function, 
								 resultParam:Object, onFault:Function, faultParam:Object, 
								 spatialRelationship:String="esriGeometryRelationIn"):void
		{
			
			var relationParam:RelationParameters = new RelationParameters();
			
			if(geometryList1 && geometryList2)
			{
				relationParam.geometries1 = geometryList1;
				relationParam.geometries2 = geometryList2;
			}
			else
			{
				showError("错误：传入的两组几何图形中至少有一组为空\n");
				
				return ;
			}
			
			if(RelationParameters)
			{
				relationParam.spatialRelationship = spatialRelationship;
			}
			
			var myGeometryService:GeometryService = new GeometryService(geomServUrl);
			myGeometryService.relation(relationParam, new AsyncResponder(result,fault));
			
			//设置鼠标忙碌光标
			CursorManager.setBusyCursor();
			
			//分析成功
			function result(event:Array, token:Object):void
			{
				//移除鼠标忙碌光标
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
			
			//分析失败
			function fault(error:Error,token:Object):void
			{
				//移除鼠标忙碌光标
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
					var geom1:String = "";
					var geom2:String = "";
					
					if(geometryList1)
						geom1 = geometryList1.toString();
					if(geometryList2)
						geom2 = geometryList2.toString();
					
					showError(
						"错误：判断两组空间数据的关系时发生错误\n" +
						"第一组空间数据：" + geom1 + "\n" +
						"第二组空间数据：" + geom2 + "\n" +
						+ error.toString()
					);
				}
			}
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
			var classInfo:String = "方法：UB_Relation \n功能：比较传入两组几何图形的空间关系 \n";
			
			var error:String = classInfo + errorInfo; 
			
			new ErrorClass(error);
		}
	}
}