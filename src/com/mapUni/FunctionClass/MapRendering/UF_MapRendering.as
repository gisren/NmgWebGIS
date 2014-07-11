////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	地图渲染。
//
//  
//
//  Author：liuXL
//  Date：2012-02-10
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.FunctionClass.MapRendering
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;

	
	/**
	 * 
	 * <p></p>
	 * 
	 * @author LiuXL
	 * 
	 */	
	public class UF_MapRendering
	{
		public function UF_MapRendering(renderGraphicsLayer:GraphicsLayer, renderNameLayer:GraphicsLayer)
		{
			_renderGraphicsLayer = renderGraphicsLayer;
			_renderNameLayer = renderNameLayer;
			
		}

		
		/**
		 * 承载地图渲染对象的图层 
		 */		
		private var _renderGraphicsLayer:GraphicsLayer = new GraphicsLayer();
		
		
		private var _renderNameLayer:GraphicsLayer = new GraphicsLayer();
		
		public var map:Map;
		
		//Graphic Move 
		private var _GraphicMouseDown:Boolean=false;
		private var _GraphicMouseDrag:Boolean=false;
		/**
		 *
		 * 单个地图对象的渲染
		 *  
		 * @param layerName
		 * @param searchWhere
		 * @param color
		 * @param alpha
		 * @param extentName
		 * @param toolTip
		 * 
		 */		
		public function RenderingSingle(layerUrl:String, searchWhere:String, fillColor:Number=0x000000, fillAlpha:Number=0.5, extentName:String=null, toolTip:String=null,
										  lineColor:Number=0x3FAFDC, lineAlpha:Number=0.75, lineWidth:Number=1, extentNameSize:Number=13, extentNameColor:Number=0 ):void
		{
			if(layerUrl)
			{
				MapUni.search(layerUrl, null, searchWhere, onSearchRest, [fillColor, fillAlpha, extentName, toolTip, lineColor, lineAlpha, lineWidth, extentNameSize, extentNameColor]);
			}
			else
			{
				MapUni.errorWindow("的图层地址不能为空");
			}
		}
		
		public function RenderingSingle_New(layerUrl:String, searchWhere:String ,clickCallbackObj:Object,tipWindow:Object,fillColor:Number=0x000000, fillAlpha:Number=0.5, extentName:String=null, toolTip:Object=null,
										lineColor:Number=0x3FAFDC, lineAlpha:Number=0.75, lineWidth:Number=1, extentNameSize:Number=13, extentNameColor:Number=0):void
		{
			if(layerUrl)
			{
				MapUni.search_new(layerUrl, null, searchWhere, onSearchRest, [fillColor, fillAlpha, extentName, toolTip, lineColor, lineAlpha, lineWidth, extentNameSize, extentNameColor,clickCallbackObj,tipWindow]);
			}
			else
			{
				MapUni.errorWindow("的图层地址不能为空");
			}
		}
		private function showError(errorString:String):void
		{
			var classInfo:String = 
				"功能名称：地图渲染\n" +
				"方法名称：UF_MapRendering\n" +
				
				new ErrorClass(classInfo + errorString);
		}
		
		
		/**
		 * 
		 * 得到查询结果
		 * 定义结果的样式
		 * 
		 * @param searchRest
		 * @param param
		 * 
		 */		
		private function onSearchRest(searchRest:FeatureSet, param:Array):void
		{
			var fillColor:Number = param[0];
			var fillAlpha:Number = param[1];
			
			var extentName:String = param[2];
			var toolTip:String = param[3];
			
			var lineColor:Number = param[4];
			var lineAlpha:Number = param[5];
			var lineWidth:Number = param[6];
			
			var extentNameSize:Number = param[7];
			var extentNameColor:Number = param[8];
			var clickCallbackObj:Object=param[9];
			
			var resultSymbol:*;
			var xMin:Number=119;
			var yMin:Number=42;
			var xMax:Number=132;
			var yMax:Number=46;
			
			var mapPoint:MapPoint = new MapPoint();
			
			for each(var graphic:Graphic in searchRest.features)
			{
				switch(graphic.geometry.type)
				{
					case Geometry.MAPPOINT:
						resultSymbol= new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 15, fillColor, fillAlpha);
						graphic.symbol = resultSymbol;
						
						mapPoint = graphic.geometry as MapPoint;
						break;
					
					case Geometry.MULTIPOINT:
						resultSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 15, fillColor, fillAlpha);
						graphic.symbol = resultSymbol;
						
						mapPoint = graphic.geometry.extent.center;
						break;
					
					case Geometry.POLYLINE:
						resultSymbol= new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, lineColor, lineAlpha, lineWidth);
						graphic.symbol = resultSymbol;
						
						mapPoint = graphic.geometry.extent.center;
						break;
					
					case Geometry.POLYGON:
						resultSymbol= new SimpleFillSymbol(SimpleFillSymbol.STYLE_SOLID, fillColor, fillAlpha, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, lineColor, lineAlpha, lineWidth));
						graphic.symbol = resultSymbol;
						
						mapPoint = graphic.geometry.extent.center;
						break;
				}
				
				var att:Object=graphic.attributes;
				att["clickCallback"]=clickCallbackObj;
				//att["tipWindow"]=tipWindow;
				graphic.attributes=att;
				if(toolTip&&toolTip["enable"])
				{
					graphic.toolTip = toolTip["text"];
				}
				graphic.checkForMouseListeners=false;
				//graphic.addEventListener(MouseEvent.CLICK,graphicClick);
				//graphic.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void{onRegionMouseOver(event)});
				//graphic.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void{onRegionMouseOut(event, graphic)});
				//graphic.addEventListener(MouseEvent.MOUSE_MOVE, onRegionMouseMove);
				
				graphic.addEventListener(MouseEvent.MOUSE_OVER,MouseOverHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OUT,MouseOutHandler);
				graphic.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownHandler);
				graphic.addEventListener(MouseEvent.MOUSE_MOVE,MouseMoveHandler);
				graphic.addEventListener(MouseEvent.MOUSE_UP,MouseUpHandler);
//				
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.size = extentNameSize;
				textFormat.color = extentNameColor;
				
				var nameSymbol:TextSymbol = new TextSymbol();
				nameSymbol.text = extentName;
				nameSymbol.textFormat = textFormat;
				
				var nameGra:Graphic = new Graphic(mapPoint, nameSymbol);
				
				if(xMin>graphic.geometry.extent.xmin)
				{
					xMin=graphic.geometry.extent.xmin
				}
				if(yMin>graphic.geometry.extent.ymin)
				{
					yMin=graphic.geometry.extent.ymin
				}
				if(xMax<graphic.geometry.extent.xmax)
				{
					xMax=graphic.geometry.extent.xmax
				}
				if(yMax<graphic.geometry.extent.ymax)
				{
					yMax=graphic.geometry.extent.ymax
				}
				
				_renderGraphicsLayer.add(graphic);
				_renderNameLayer.add(nameGra);
			}
			var extent:Extent=new Extent(xMin,yMin,xMax,yMax);
			map.extent=extent;
			
		}
		private function graphicClick(event:MouseEvent):void
		{
			/* 
			派发鼠标点击事件
			*/
			//Alert.show("ddd","提示");
			var pointGra:Graphic = event.currentTarget as Graphic;
			
			var pointObj:Object = pointGra.attributes;
			var callback:Object = pointObj["clickCallback"];
			
			if(callback)
			{
				if(callback["enable"] != "false" && callback["enable"])
				{
					clickCallback(callback);
				}
			}
		}
		/**
		 * 回调js方法 
		 */
		private function clickCallback(callbackObj:Object):void
		{
			var funcName:String = callbackObj["funcName"];
			var param:Array = callbackObj["parameter"] as Array;
			
			ExternalInterface.call(funcName, param);
			
			
		}
		
		private function MouseOverHandler(event:MouseEvent):void
		{
			var _Graphic:Graphic = event.currentTarget as Graphic;
			
		}
		
		private function MouseOutHandler(event:MouseEvent):void
		{
			
			var _Graphic:Graphic = event.currentTarget as Graphic;
			
		}
		
		private function MouseDownHandler(event:MouseEvent):void
		{
			_GraphicMouseDown=true;
		}
		
		private function MouseMoveHandler(event:MouseEvent):void
		{
			if(_GraphicMouseDown)
			{
				_GraphicMouseDrag=true;
			}
			else
			{
				_GraphicMouseDrag=false;
			}
		}
		
		private function MouseUpHandler(event:MouseEvent):void
		{
			if(!_GraphicMouseDrag)
			{
				//Mouse Click Event
				//Alert.show("sss","提示");
				var pointGra:Graphic = event.currentTarget as Graphic;
				
				var pointObj:Object = pointGra.attributes;
				var callback:Object = pointObj["clickCallback"];
				
				if(callback)
				{
					if(callback["enable"] != "false" && callback["enable"])
					{
						clickCallback(callback);
					}
				}
				
			}
			//_GraphicMouseDown=false;
			_GraphicMouseDrag=false;	
		}
		
	}
}