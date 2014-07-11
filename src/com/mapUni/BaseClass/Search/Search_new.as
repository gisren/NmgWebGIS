////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	地图图层指定的一个或多个对象的搜索
//
//  对 ArcGIS Api For Flex 中 Search 方法进行封装
//
//  Author：liuXL
//  Date：2012-02-10
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.Search
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.Query;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncResponder;
	
	/**
	 *
	 * <p>地图查询</p>
	 *  
	 * @author liuxl
	 * 
	 */	
	public class Search_new
	{
		/**
		 * 
		 * <p>对指定地图图层进行条件查询</p>
		 * 
		 * @param layerUrl 图层地址 所要查询的地图图层地址
		 * @param qGeometry 图形查询条件 参数为 Geometry 格式的图形
		 * @param qWhere 属性查询条件 可以为针对字段的属性查询条件，如："name='好'"如果要查询所有记录，可以将此参数设置为"1=1" ，但效率很低，不推荐这样使用；
		 * @param result 查询成功后要执行的方法
		 * @param resultParam 要对查询成功后执行的方法传递的额外参数
		 * @param outField 查询记录中返回的属性字段，默认为全部返回
		 * @param useAMF 查询返回数据时是否使用 AMF 格式文件，当使用的 ArcGIS Server 10 以上的地图服务时把此参数改为true，可以明显提高查询的速度。默认为true。
		 * @param fault 查询失败后要执行的方法
		 * @param faultParam 要对查询失败后执行的方法传递的额外参数
		 * 
		 */		
		public function Search_new(layerUrl:String, qGeometry:Geometry, qWhere:String, result:Function, resultParam:Object=null, 
							   outField:Array=null, useAMF:Boolean=true, fault:Function=null, faultParam:Object=null):void
		{
			var queryParam:Query = getQuery(qGeometry, qWhere, outField);
			
			query(layerUrl, queryParam, useAMF, result, resultParam, fault, faultParam);
		}
		
		
		/**
		 *
		 * 获取查询参数
		 *  
		 * @param seachCondition 查询条件
		 * @param qOutField 查询结果输入字段
		 * @return 查询参数
		 * 
		 */		
		private function getQuery(geometry:Geometry, where:String, qOutField:Array):Query
		{
			var query:Query = new Query();
			
			if(where)
			{
				query.where = where;
			}
			if(geometry)
			{
				query.geometry = geometry;
			}
			
			
			/*
			判断查询结果的输出字段，如果为空，则输入全部
			*/
			if(qOutField)
			{
				query.outFields = qOutField;
			}
			else
			{
				query.outFields = ["*"];
			}
			
			
			query.returnGeometry=true;
			query.spatialRelationship = Query.SPATIAL_REL_INTERSECTS;
			
			
			return query;
			
		}
		
		
		/**
		 *
		 * 进行查询
		 *  
		 * @param layerUrl 要查询的图层
		 * @param queryParam 查询参数，Query类型
		 * @param useAMF	是否使用AMF格式文件
		 * @param onRestFunction 成功查询的回调函数
		 * @param onRestParam 调取回调函数时传递的参数
		 * 
		 */		
		private function query(layerUrl:String, queryParam:Query, useAMF:Boolean, 
							   onRestFunction:Function, onRestParam:Object, fault:Function, faultParam:Object):void
		{
			if(!layerUrl)
			{
				showError("错误：传入的图层地址为空");
				return;
			}
			
			var queryLayer:QueryTask = new QueryTask(layerUrl);
			queryLayer.useAMF = useAMF;
			queryLayer.showBusyCursor = true;
			queryLayer.execute(queryParam, new AsyncResponder(onResult,onFault));
			
			//鼠标显示为忙碌光标
			CursorManager.setBusyCursor();
			
			/*
			查询成功
			*/
			function onResult(featureSet:FeatureSet, token:Object=null):void
			{
				//鼠标移除忙碌光标
				CursorManager.removeBusyCursor();
				
				/*
				调用插入的回调函数
				*/
				if(onRestParam)
				{
					onRestFunction(featureSet, onRestParam);
				}
				else
				{
					onRestFunction(featureSet);
				}
			}
			
			/*
			查询失败
			*/
			function onFault(info:Error, token:Object=null):void
			{
				//清除忙碌光标
				CursorManager.removeBusyCursor();
				
				if(fault != null)
				{
					if(faultParam)
					{
						fault(info, faultParam);
					}
					else
					{
						fault(info);
					}
				}
				else
				{
					var where:String = "";
					var geom:String = "";
					var outField:String = "";
					
					if(queryParam.where)
					{
						where = queryParam.where.toString();
					}
					if(queryParam.geometry)
					{
						geom = queryParam.geometry.toString();
					}
					if(queryParam.outFields)
					{
						outField = queryParam.outFields.toString();
					}
					
					showError(
						"错误:在根据条件查询图层数据时出错。请检查查询条件\n" + 
						"url:" + layerUrl + "\n" +
						"Where:" + where + "\n" +
						"Geometry:" + geom + "\n" +
						"OutField:" + outField + "\n" + 
						info.toString()
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
			var classInfo:String = "方法：Search \n功能：对地图图层进行属性、几何查询 \n";
			
			var error:String = classInfo + errorInfo; 
			
			new ErrorClass(error);
		}
		
		
		
		
		
	}
}