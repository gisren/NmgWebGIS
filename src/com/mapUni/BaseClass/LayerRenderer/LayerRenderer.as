package com.mapUni.BaseClass.LayerRenderer
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.RelationParameters;
	import com.esri.viewer.AppEvent;
	import com.esri.viewer.ViewerContainer;
	import com.mapUni.BaseClass.MapExtent.DataExtent;
	import com.mapUni.BaseClass.Search.Search;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.validators.ValidationResult;
	
	import spark.filters.GlowFilter;
	
	import widgets.exInterface.Reseau.ReseauWidget;
	import widgets.exInterface.Reseau.SpecialDetail;
	
	
	public class LayerRenderer
	{
		public function LayerRenderer(map:Map, layerUrl:String, layerNameField:String, callback:Function, queryGeometry:Geometry=null, queryWhere:String="1=1",pageType:String="")
		{
			this.map = map;
			this.callback = callback;
			this.layerNameField = layerNameField;
			this.layerUrl = layerUrl;
			this.queryGeometry = queryGeometry;
			this.queryWhere = queryWhere;
			this.pageType=pageType;
			
			geometryLayer = new GraphicsLayer();
			map.addLayer(geometryLayer,1);
			
			nameLayer = new GraphicsLayer();
			nameLayer.mouseEnabled = true;
			nameLayer.mouseChildren = true;
			map.addLayer(nameLayer,1);
			
			
			//			if(queryGeometry || queryWhere)
			//			{
			
			//			}
			//			else
			//			{
			//				loadFeatureLayer(layerUrl);
			//			}
		}
		
		private var map:Map;
		private var layerNameField:String;
		private var callback:Function;
		private var geometryLayer:GraphicsLayer;
		private var nameLayer:GraphicsLayer;
		private var layerUrl:String;
		private var queryGeometry:Geometry;
		private var queryWhere:String;
		private var pageType:String;
		
		
		
		
		private var graphicClick:Graphic=new Graphic();
		private var SpecialWindow:SpecialDetail= new SpecialDetail();
		
		public function addRenderer():void
		{
			searchLayerFeature(layerUrl, queryGeometry, queryWhere);
		}
		
		
		/**
		 * 获取图层内满足查询条件的图形
		 */		
		private function searchLayerFeature(layerUrl:String, qGeometry:Geometry, qWhere:String):void
		{
			new Search(layerUrl, qGeometry, qWhere, onSearchResult);
			
			function onSearchResult(featureSet:FeatureSet):void
			{
				var GraphicArray:Array = featureSet.features;
				
				new DataExtent(GraphicArray, map);
				
				for(var i:int=0; i<GraphicArray.length; i++)
				{
					var graphic:Graphic = GraphicArray[i] as Graphic;
					if(graphic)
					{
						//添加区域图形
						addGeometryGraphic(graphic)
						
						//添加区域名称
						addNameGraphic(graphic);
					}
				}
			}
		}
		
		
		/**
		 * 获取整个图层的图形对象
		 */		
		/*private function loadFeatureLayer(layerUrl:String):void
		{
		var featureLayer:FeatureLayer = new FeatureLayer(layerUrl);
		featureLayer.addEventListener(LayerEvent.LOAD, onLayerLoad);
		featureLayer.addEventListener(GraphicEvent.GRAPHIC_ADD, onGraphicAdd);
		featureLayer.outFields = ['*'];
		featureLayer.useAMF = true;
		featureLayer.alpha = 0;
		featureLayer.mouseEnabled = false;
		featureLayer.mouseChildren = false;
		map.addLayer(featureLayer);
		
		function onLayerLoad(event:LayerEvent):void
		{
		var layer:Layer = event.layer;
		map.extent = layer.initialExtent;
		}
		
		function onGraphicAdd(event:GraphicEvent):void
		{
		var graphic:Graphic = event.graphic;
		
		//添加区域图形
		addGeometryGraphic(graphic)
		
		//添加区域名称
		addNameGraphic(graphic);
		}
		}*/
		
		
		/**
		 * 添加图形
		 */		
		private function addGeometryGraphic(graphic:Graphic):void
		{
			var simpleFillSymbol:SimpleFillSymbol = new SimpleFillSymbol();
			simpleFillSymbol.color = 0x0000ff;
			simpleFillSymbol.alpha = 0.3;
			simpleFillSymbol.outline = new SimpleLineSymbol();
			simpleFillSymbol.outline.color = 0xffffff;
			
			var gra:Graphic = new Graphic(graphic.geometry, simpleFillSymbol, graphic.attributes);
			gra.checkForMouseListeners = false;
			gra.addEventListener(MouseEvent.CLICK, onGraphicMouseClick);
			gra.addEventListener(MouseEvent.MOUSE_OVER, onGraphicMouseOver);
			gra.addEventListener(MouseEvent.MOUSE_OUT, onGraphicMouseOut);
			
			geometryLayer.add(gra);
		}
		
		
		/**
		 * 添加图形区域名称 
		 */		
		private function addNameGraphic(geometryGraphic:Graphic):void
		{
			var centerPoint:MapPoint = geometryGraphic.geometry.extent.center;
			
			var textSymbol:TextSymbol = new TextSymbol();
			textSymbol.text = geometryGraphic.attributes[layerNameField];
			textSymbol.textFormat = new TextFormat();
			textSymbol.textFormat.bold = true;
			textSymbol.textFormat.color = 0xFF00FF;
			textSymbol.textFormat.size = 18;
			
			var nameGraphic:Graphic = new Graphic(centerPoint, textSymbol);
			
			nameLayer.add(nameGraphic);
		}
		
		
		/**
		 * 监听图形鼠标点击 
		 */		
		private function onGraphicMouseClick(event:MouseEvent):void
		{
			graphicClick= event.currentTarget as Graphic;
			//clearLayer();
			//editFunction();
			//callback(graphic);
			if(pageType=="ReseauType")
			{
				PopUpManager.removePopUp(SpecialWindow);
				SpecialWindow= new SpecialDetail();
				SpecialWindow.graphicClick=graphicClick;
				SpecialWindow.callback=callback;
				SpecialWindow.visible = true;
				SpecialWindow.title="您要查看的内容";
				PopUpManager.addPopUp(SpecialWindow,map,true);  
				PopUpManager.centerPopUp(SpecialWindow);
				
			}else{
				callback(graphicClick);
			}
			
			
		}
		
//		private var alert:Alert; 
//		public function editFunction():void{
//			Alert.yesLabel = "显示网格信息";
//			Alert.noLabel = "查询污染源";
//			Alert.buttonWidth=60;
//			Alert.buttonHeight=20;
//			
//			var flags:uint = Alert.OK | Alert.YES;
//			alert = Alert.show("您要执行的操作","功能提示",Alert.YES|Alert.NO);//|Alert.NONMODAL非模式化窗体
//			alert.addEventListener(CloseEvent.CLOSE,alert_edittable);
//			
//		}
//		
//		private function alert_edittable(event:CloseEvent):void{
//			switch(event.detail){
//				case Alert.YES:			
//					callback(graphicClick);
//					break;
//				case Alert.NO:
//					ViewerContainer.dispatchEvent(new AppEvent(AppEvent.Reseau_Type,graphicClick));
//					break;
//			}
//		}
		public function clearLayer():void
		{
			map.removeLayer(geometryLayer);
			map.removeLayer(nameLayer);
		}
		
		
		
		/**
		 * 监听图形鼠标移入 
		 */		
		private function onGraphicMouseOver(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.blurX = 20;
			glowFilter.blurY = 20;
			glowFilter.strength = 3;
			glowFilter.knockout = true;
			glowFilter.color = 0xffffff;
			graphic.filters = [glowFilter];
		}
		
		
		/**
		 * 监听图形鼠标移出
		 */		
		private function onGraphicMouseOut(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			graphic.filters = null;
		}
		
	}
}