package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.viewer.AppEvent;
	import com.esri.viewer.ViewerContainer;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.FunctionClass.MapLevelRenderer.MapLevelRenderer;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import spark.filters.GlowFilter;
	
	public class StatLayerRenderer extends MapLevelRenderer
	{
		public function StatLayerRenderer(map:Map=null, layerParamArray:Array=null)
		{
			super(map, layerParamArray);
			
			renderNameLayer.mouseEnabled = false;
			renderNameLayer.mouseChildren = false;
			
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xffffff;
			glowFilter.blurX = 30;
			glowFilter.blurY = 30;
			glowFilter.strength = 1.5;
			graphicFilters = [glowFilter];
		}
		
		
		public var renererParam:StatChartParam = new StatChartParam();
		
		
		public var layerIdField:String = "";
		
		
		/**
		 * 覆盖添加背景区域的方法,不再添加背景区域
		 */		
		protected override function createBackGroundGraphic():void
		{
		}
		
		protected override function regionRenderer(graphic:Graphic, idField:String, nameField:String, layerUrl:String):void
		{
			super.regionRenderer(graphic, idField, nameField, layerUrl);
			
			var regionId:String = graphic.attributes[idField];
			var regionColor:Number;
			
			if(renererParam.colorHashtable.containsKey(regionId))
				regionColor = renererParam.colorHashtable.find(regionId);
			
			if(regionColor)
			{
				var oldSymbol:SimpleFillSymbol = graphic.symbol as SimpleFillSymbol;
				
				var newFillSymbol:SimpleFillSymbol = new SimpleFillSymbol();
				newFillSymbol.alpha = oldSymbol.alpha;
				newFillSymbol.color = regionColor;
				newFillSymbol.outline = oldSymbol.outline;
				
				graphic.symbol = newFillSymbol;
			}
		}
		
		protected override function onRegionMouseClick(event:MouseEvent, graphic:Graphic):void
		{
			var graObj:Object = graphic.attributes;
			
			if(renererParam.isLevelLayer)
			{
				var dataObj:Object = new Object();
				dataObj.id = renererParam.statId;
				dataObj.label = renererParam.statTitle;
				dataObj.regionLayer = renererParam.regionLayer;
				dataObj.regionCode = graObj[layerIdField];		
				
				if(renererParam.regionLayer == "provinceLayer")
				{
					ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_PARAM_CITY_SEND, dataObj));
				}
				else if(renererParam.regionLayer == "cityLayer")
				{
					ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_PARAM_COUNTY_SEND, dataObj));
				}
			}
		}
		
		
		protected override function onRegionMouseOver(event:MouseEvent, graphic:Graphic, idField:String, nameField:String, layerUrl:String):void
		{
			super.onRegionMouseOver(event, graphic, idField, nameField, layerUrl);
			
			var regionId:String = graphic.attributes[idField];
			
			for each(var object:Object in renererParam.dataProvider)
			{
				var objId:String = object[renererParam.regionIdField];
				
				if(regionId == objId)
				{
					var regionName:String = object[renererParam.nameField];
					
					var valueField:String = renererParam.valueFields[0];
					var value:String = object[valueField];
					
					var valueName:String = renererParam.codeNameHashtable.find(valueField);
					
					var tooltipObj:Object = new Object();
					tooltipObj.regionName = regionName;
					tooltipObj.valueName = valueName;
					tooltipObj.value = value;
					
					ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_DATA_RENDERER_TOOLTIP, tooltipObj));
					
					break;
				}
			}
		}
	}
}