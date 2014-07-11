////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	获取图层在地图服务中的地址。
//
//  根据需要可以通过传入参数的不同来得到 mapLayer 的地址和 featureLayer 的地址
//
//  Author：liuXL
//  Date：2012-02-10
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.GetLayerUrl
{
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * 
	 * <p>根据图层名称获取图层编号</p>
	 * <p>初始化传参，调用 getUrl() 获取结果</p>
	 * 
	 * @author liuxl
	 * 
	 */	
	public class GetLayerUrl
	{
		
		private var mapLayerUrl:String = "";
		
		
		/**
		 * 
		 * <p>根据图层名称获取地图图层编号</p>
		 * 
		 * @param map 要从中检索的地图或图层，可以为 Map， 也可以为 ArcGISDynamicMapServiceLayer 或者 ArcGISTiledMapServiceLaye
		 * @param layerName 要获取的图层名称
		 * @param returnUrlType 返回的图层地址类型，1为普通地图服务的图层地址，2为"FeatureService"地图服务的图层地址,默认为1，
		 * 						若输入规定数据以外的参数，程序默认将以1来处理，可选参数
		 * @return 返回图层名对应的图层地址,如果没有调取到则返回空字符串
		 * 
		 */		
		public function GetLayerUrl(mapOrLayer:Object, layerName:String, serverType:Number):void
		{
			
			var layerUrl:String = "";
			
			/*
			判断传入图层集合类型
			根据图层类型的不同来调用不同的方法
			*/
			if(mapOrLayer is Map)
			{
				layerUrl =  onMapGetLayerUrl(mapOrLayer as Map, layerName);
			}
			else if(mapOrLayer is ArcGISDynamicMapServiceLayer)
			{
				layerUrl = getLayerUrl(mapOrLayer as ArcGISDynamicMapServiceLayer, layerName);
			}
			else if(mapOrLayer is ArcGISTiledMapServiceLayer)
			{
				layerUrl = getLayerUrl(mapOrLayer as ArcGISTiledMapServiceLayer, layerName);
			}
			else
			{
				showError("map参数为空或为指定格式外类型");
			}
			
			/*
			根据所要的图层格式
			对图层类型进行处理
			*/
			layerUrl = checkUrl(layerUrl, serverType);
			
			mapLayerUrl = layerUrl;
			
			if(!mapLayerUrl)
			{
				var errorStr:String = 
					"查询地址失败\n" + 
					"图层：" + layerName;
				showError(errorStr);
			}
		}
		
		
		/**
		 *
		 * 获取图层地址
		 *  
		 * @return 图层地址
		 * 
		 */		
		public function getUrl():String
		{
			return mapLayerUrl;
		}
		
		
		/**
		 *
		 * 获取动态地图或切图地图图层内的图层地址
		 *  
		 * @param arcgisLayer 动态地图图层或切图地图图层
		 * @param layerName 需要查询地址的图层名称
		 * @return 图层地址
		 * 
		 */		
		private function getLayerUrl(arcgisLayer:*, layerName:String):String
		{
			if(arcgisLayer.layerInfos)
			{
				//遍历图层
				for(var l:int=0;l<arcgisLayer.layerInfos.length;l++)
				{
					//通过匹配图层名称来得到地址
					if(layerName == arcgisLayer.layerInfos[l].name)
					{
						var layerId:String = arcgisLayer.layerInfos[l].id;
						var mapUrl:String = arcgisLayer.url;
						
						if(layerId && mapUrl)
						{
							var layerUrl:String = mapUrl + "/" + layerId;
							return layerUrl;
						}
					}
				}
			}
			
			return "";
		}
		
		
		/**
		 *
		 * 获取图层集类型为 Map 时的图层地址
		 *  
		 * @param map 地图属性数据
		 * @param layerName 图层名称
		 * @return 图层地址
		 * 
		 */		
		private function onMapGetLayerUrl(map:Map, layerName:String):String
		{
			var layers:ArrayCollection = map.layers as ArrayCollection;
			
			//遍历图层
			for(var t:int=0;t<layers.length;t++)
			{
				//查找动态地图图层和地图切图图层
				if(layers[t] is ArcGISDynamicMapServiceLayer || layers[t] is ArcGISTiledMapServiceLayer)
				{
					var layerUrl:String = getLayerUrl(layers[t], layerName);
					
					if(layerUrl)
					{
						return layerUrl;
					}
				}
			}
			
			return "";
		}
		
		
		/**
		 *
		 * 针对所需的图层类型来对得到的地址进行处理
		 *  
		 * @param layerUrl 图层地址
		 * @param serverType 所需的图层类型
		 * @return 所需的图层地址
		 * 
		 */		
		private function checkUrl(layerUrl:String, serverType:Number):String
		{
			if(layerUrl)
			{
				if(serverType == 1)
				{
					return layerUrl;
				}
				else if(serverType == 2)
				{
					layerUrl = layerUrl.replace("MapServer","FeatureServer");
					
					return layerUrl;
				}
			}
			
			return "";
		}
		
		/**
		 * 弹出错误窗口
		 */		
		private function showError(errorString:String):void
		{
			var str:String = 
				"方法：GetLayerUrl\n" +
				"功能：根据图层名称查询图层地址\n" +
				"错误：" + errorString;
			new ErrorClass(str);
		}
		
		
	}
}