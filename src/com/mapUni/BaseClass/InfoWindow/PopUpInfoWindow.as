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
package com.mapUni.BaseClass.InfoWindow
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.webmap.PopUpRenderer;
	import com.esri.ags.webmap.supportClasses.PopUpInfo;
	
	import mx.core.ClassFactory;

	
	/**
	 *
	 * <p>气泡显示点位的信息</p>
	 *  
	 * @author liuXL
	 * 
	 */	
	public class PopUpInfoWindow
	{
		
		/**
		 *
		 * 气泡显示点位的信息
		 *  
		 * @param map 地图
		 * @param graphic 目标图形
 		 * @param title 标题
		 * @param content 内容。如果需要换行可以使用换行符来实现
		 * @param isShow 是否要立即弹出信息框
		 * @param showLocated 气泡框显示的位置
		 * @param link 第一个超连接的地址
		 * @param linkName 第一个超链接的名称
		 * @param link2 第二个超连接的地址
		 * @param linkName2 第二个超链接的名称
		 * @param link3 第三个超连接的地址
		 * @param linkName3 第三个超链接的名称
		 * 
		 */		
		public function PopUpInfoWindow(map:Map, graphic:Graphic, title:String, content:String, 
										   isShow:Boolean=false, showLocated:MapPoint=null,
										   link:String="", linkName:String="", 
										   link2:String="", linkName2:String="",
										   link3:String="",linkName3:String=""):void
		{
			/*
			var infoResult:InfoResult = new InfoResult();
			infoResult.title = title;
			infoResult.content = content;
			infoResult.graphic = graphic;
			infoResult.link = link;
			infoResult.link2 = link2;
			infoResult.link3 = link3;
			
			graphic.attributes = infoResult;
			*/
			
			if(!graphic){
				return;
			}
			
			var attri:Object = graphic.attributes;
			attri["title"] = title;
			attri["content"] = content;
			attri["graphic"] = graphic;
			attri["link"] = link;
			attri["link2"] = link2;
			attri["link3"] = link3;
			
			var popUpInfo:PopUpInfo = configurePopUpInfo(linkName,linkName2,linkName3);
			
			if(isShow)
			{
				var popUpRenderer:PopUpRenderer = new PopUpRenderer();
				popUpRenderer.popUpInfo = popUpInfo;
				popUpRenderer.graphic = graphic;
				
				var mapPoint:MapPoint = new MapPoint();
				
				if(showLocated)
				{
					mapPoint = showLocated;
				}
				else
				{
					switch(graphic.geometry.type)
					{
						case Geometry.MAPPOINT:
							
							mapPoint = graphic.geometry as MapPoint;
							
							break;
						
						case Geometry.POLYLINE:
							
							var polyline:Polyline = graphic.geometry as Polyline;
							var array:Array = polyline.paths;
							mapPoint = array[Math.ceil(array.length/2)] as MapPoint;
							
							break;
						
						case Geometry.EXTENT:
						case Geometry.POLYGON:
							
							mapPoint = graphic.geometry.extent.center;
							
							break;
					}
				}
				
				map.infoWindow.content = popUpRenderer;
				map.infoWindow.show(mapPoint);
			}
			else
			{
				var infoWindowRenderer:ClassFactory = new ClassFactory(PopUpRenderer);
				infoWindowRenderer.properties = { popUpInfo: popUpInfo};
				graphic.infoWindowRenderer = infoWindowRenderer;
			}
		}
		
		
		/**
		 * 
		 * 功能：配置气泡
		 * 
		 * 参数：linkName 连接名称1
		 * 		linkName2 连接名称2
		 * 		linkName3 连接名称3
		 * 返回：PopUpInfo 
		 * 
		 */		
		private function configurePopUpInfo(linkName:String, linkName2:String, linkName3:String):PopUpInfo
		{
			var popUpInfo:PopUpInfo = new PopUpInfo;
			
			popUpInfo.title = "{title}";
			popUpInfo.description = "{content}";
			
			if(linkName){
				popUpInfo.description += "<br/><a href='{link}'>"+ linkName +"</a>";
			}
			if(linkName2){
				popUpInfo.description += "<br/><a href='{link2}'>"+ linkName2 +"</a>";
			}
			if(linkName3){
				popUpInfo.description += "<br/><a href='{link3}'>"+ linkName3 +"</a>"
			}
			
			return popUpInfo;
		}
	
	
	
	
	
	
	
	
	
	

	}
}