package com.mapUni.BaseClass.RiverRenderer
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.components.supportClasses.InfoPlacement;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.InfoSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.RelationParameters;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	import com.mapUni.BaseClass.MapExtent.DataExtent;
	import com.mapUni.BaseClass.MapUni;
	import com.mapUni.BaseClass.Search.Search;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import mx.core.ClassFactory;
	
	import spark.filters.GlowFilter;
	
	
	public class RiverRenderer
	{
		public function RiverRenderer(map:Map, riverLayers:Array, callback:Function)
		{
			this.map = map;
			this.callback = callback;
			
			geometryLayer = new GraphicsLayer();
			map.addLayer(geometryLayer);
			
			nameLayer = new GraphicsLayer();
			nameLayer.mouseEnabled = false;
			nameLayer.mouseChildren = false;
			map.addLayer(nameLayer);
			
			graHashtable = new Hashtable();
			
			analyLayers(riverLayers);
		}
		
		
		private var map:Map;
		
		private var callback:Function;
		
		private var geometryLayer:GraphicsLayer;
		
		private var nameLayer:GraphicsLayer;
		
		private var graHashtable:Hashtable;
		
		
		private function analyLayers(layersArray:Array):void
		{
			for(var i:int=0; i<layersArray.length; i++)
			{
				var rendererParam:RiverRendererParam = layersArray[i] as RiverRendererParam;
				
				if(rendererParam)
				{
					var layerUrl:String = rendererParam.layerUrl;
					var layerCodeField:String = rendererParam.layerCodeField;
					var layerNameField:String = rendererParam.layerNameField;
					var queryGeometry:Geometry = rendererParam.queryGeometry;
					var queryWhere:String = rendererParam.queryWhere;
					
					searchLayerFeature(layerUrl, queryGeometry, queryWhere, layerCodeField, layerNameField);
				}
				else
				{
					showError("参数不对,应该是 RiverRendererParam 类型的数组");
				}
			}
		}
		
		
		/**
		 * 获取图层内满足查询条件的图形
		 */		
		private function searchLayerFeature(layerUrl:String, qGeometry:Geometry, qWhere:String, layerCodeField:String, layerNameField:String):void
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
						var regionGra:Graphic = addGeometryGraphic(graphic);
						
						//添加区域名称
						var nameGra:Graphic = addNameGraphic(graphic, layerCodeField, layerNameField);
						
						graHashtable.add(regionGra, nameGra);
					}
				}
			}
		}
		
		
		/**
		 * 添加图形
		 */		
		private function addGeometryGraphic(graphic:Graphic):Graphic
		{
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.blurX = 20;
			glowFilter.blurY = 20;
			glowFilter.strength = 3;
			glowFilter.knockout = true;
			glowFilter.color = 0x0000ff;
			
			var simpleFillSymbol:SimpleFillSymbol = new SimpleFillSymbol();
			simpleFillSymbol.color = 0x0000ff;
			simpleFillSymbol.alpha = 0.5;
			simpleFillSymbol.outline = new SimpleLineSymbol();
			simpleFillSymbol.outline.color = 0xffffff;
			
			var gra:Graphic = new Graphic(graphic.geometry, simpleFillSymbol, graphic.attributes);
			
			gra.addEventListener(MouseEvent.CLICK, onMouseClick);
			gra.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			gra.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			geometryLayer.add(gra);
			
			return gra;
			
			
			function onMouseClick(event:MouseEvent):void
			{
				var newMapPoint:MapPoint = map.toMapFromStage(event.stageX, event.stageY);
				
				var graphic:Graphic = event.currentTarget as Graphic;
				
				var nameGra:Graphic = graHashtable.find(graphic);
				nameGra.geometry = newMapPoint;
				
//				map.removeLayer(geometryLayer);
//				map.removeLayer(nameLayer);
			}
			
			function onMouseOver(event:MouseEvent):void
			{
				var graphic:Graphic = event.currentTarget as Graphic;
				
				graphic.filters = [glowFilter];
			}
			
			function onMouseOut(event:MouseEvent):void
			{
				var graphic:Graphic = event.currentTarget as Graphic;
				graphic.filters = null;
			}
		}
		
		
		/**
		 * 添加图形区域名称
		 */
		private function addNameGraphic(geometryGraphic:Graphic, layerCodeField:String, layerNameField:String):Graphic
		{
			var riverCode:String = geometryGraphic.attributes[layerCodeField];
			var riverName:String = geometryGraphic.attributes[layerNameField];
			
			var centerPoint:MapPoint = geometryGraphic.geometry.extent.center;
			
			var infoClass:ClassFactory = new ClassFactory(riverInfoWindow);
			infoClass.properties = 
				{
					riverName:riverName
				}
			
			var infoSymbol:InfoSymbol = new InfoSymbol();
			infoSymbol.infoRenderer = infoClass;
			infoSymbol.infoPlacement = InfoPlacement.TOP;
			
			var nameGraphic:Graphic = new Graphic(centerPoint, infoSymbol);
			nameGraphic.addEventListener(MouseEvent.CLICK, onClick);
			
			nameLayer.add(nameGraphic);
			
			return nameGraphic;
			
			function onClick(event:MouseEvent):void
			{
				callback(geometryGraphic);
			}
		}
		
		
		/**
		 * 显示错误信息
		 */		
		private function showError(error:String):void
		{
			var str:String = 
				"方法：RiverRenderer\n" +
				"功能：在地图上对河流等对象渲染，返回所选择的图形对象\n" + 
				"错误：" + error;
			new ErrorClass(str);
		}
		
		
	}
}