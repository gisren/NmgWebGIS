package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.viewer.AppEvent;
	import com.esri.viewer.ViewerContainer;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.BaseClass.MapUni;
	import com.mapUni.FunctionClass.MapChart.UF_MapChart;
	import com.mapUni.FunctionClass.MapLevelRenderer.ILevelRenderTooltipContiner;
	import com.mapUni.FunctionClass.MapLevelRenderer.LevelRenderLayerParam;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import widgets.elements.Legend.LegendParam;
	import widgets.exInterface.StatisticalAnalysis.Components.StatTooltip;
	

	public class StatMapContorl
	{
		public function StatMapContorl()
		{
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WIDGET_PARAM_GET, "configXML", onGetConfigXML));
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WIDGET_PARAM_GET, "map", onGetMap));
			
			ViewerContainer.addEventListener(StatEvent.STAT_DATA_WINDOW_CHART, clear);
			ViewerContainer.addEventListener(StatEvent.STAT_DATA_MAP_CHART, onChartDataSend);
			ViewerContainer.addEventListener(StatEvent.STAT_DATA_MAP_RENDERER, onRenderDataSend);
			
			ViewerContainer.addEventListener(StatEvent.STAT_MAP_VISIBLE, setMapVisible);
			
			ViewerContainer.addEventListener(AppEvent.CLEAR_MAP, onToolbarClearButtonclick);
			
			init();
		}
		
		private var configXML:XML;
		
		private var map:Map;
		
		private var chartLayer:GraphicsLayer = new GraphicsLayer();
		
		private var chartBackGroundRenderer:GraphicsLayer = new GraphicsLayer();
		
		private var layerRenderer:StatLayerRenderer;
		
		private var currLegend:Array = new Array();
		
		
		private function onGetConfigXML(value:XML):void
		{
			configXML = value;
		}
		
		private function onGetMap(value:Map):void
		{
			map = value;
			
			map.addLayer(chartBackGroundRenderer);
			map.addLayer(chartLayer);
		}
		
		
		private function init():void
		{
			var layerParamArray:Array = createLayerLevel();
			layerRenderer = new StatLayerRenderer(map, layerParamArray);
			layerRenderer.graphicToolTipCom = new StatTooltip() as ILevelRenderTooltipContiner;
		}
		
		
		/**
		 * 监听：工具条上清空按钮的点击 
		 */		
		private function onToolbarClearButtonclick(event:AppEvent):void
		{
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WINDOW_CHART_VISIBLE, false))
			
			clear();
		}
		
		
		/**
		 * 功能：设置图层可见性 
		 */		
		private function setMapVisible(event:StatEvent):void
		{
			var mapVisible:Boolean = event.data as Boolean;
			
			chartLayer.visible = mapVisible;
			chartBackGroundRenderer.visible = mapVisible;
			
			if(mapVisible)
			{
				layerRenderer.showLayer();
				
				for each(var legendParamAdd:LegendParam in currLegend)
				{
					legendParamAdd.operate = LegendParam.ADD;
					ViewerContainer.dispatchEvent(new AppEvent(AppEvent.LEGEND_EDIT, legendParamAdd));
				}
			}
			else
			{
				layerRenderer.hideLayer();
				
				for each(var legendParamDelete:LegendParam in currLegend)
				{
					legendParamDelete.operate = LegendParam.DELETE;
					ViewerContainer.dispatchEvent(new AppEvent(AppEvent.LEGEND_EDIT, legendParamDelete));
				}
			}
		}
		
		
		/**
		 * 清空地图和图例 
		 */		
		private function clear(event:Event=null):void
		{
			chartLayer.clear();
			
			chartBackGroundRenderer.clear();
			
			layerRenderer.clear();
			
			clearLegend();
		}
		
		
		/**
		 * 清空图例 
		 */		
		private function clearLegend():void
		{
			//清空图例
			for each(var legendParam:LegendParam in currLegend)
			{
				legendParam.operate = LegendParam.DELETE;
				//ViewerContainer.dispatchEvent(new AppEvent(AppEvent.LEGEND_EDIT, legendParam));
			}
			currLegend = [];
		}
		
		
		/**
		 * 监听：地图图表显示数据的派发 
		 */		
		private function onChartDataSend(event:StatEvent):void
		{
			var chartParam:StatChartParam = event.data as StatChartParam;
			var regionLayer:String = chartParam.regionLayer;
			
			var layerXML:XML = getLayerParam(regionLayer);
			var layerUrl:String = getLayerUrl(layerXML.@mapLabel, layerXML.@layerName);
			
			MapUni.search(layerUrl, null, "1=1", onSearchResult);
			
			function onSearchResult(featureSet:FeatureSet):void
			{
				var regionGraArray:Array = featureSet.features; 
				
				setRegionExtent(regionGraArray, chartParam, layerXML.@idField);
				
				for each(var chartObj:Object in chartParam.dataProvider)
				{
					for each(var regionGra:Graphic in regionGraArray)
					{
						if(chartObj[chartParam.regionIdField] == regionGra.attributes[layerXML.@idField])
						{
							var centerPoint:MapPoint = regionGra.geometry.extent.center;
							
							var graAttriObj:Object = new Object();
							graAttriObj.id = chartParam.statId;
							graAttriObj.label = chartParam.statTitle;
							graAttriObj.regionLayer = chartParam.regionLayer;
							graAttriObj.regionCode = regionGra.attributes[layerXML.@idField];
							
							var mapChartCalss:StatMapchart = new StatMapchart(map, chartLayer);
							mapChartCalss.YAxisMaxNum = chartParam.YAxisMaxNum;
							if(chartParam.isLevelLayer){
								mapChartCalss.addEventListener(StatEvent.STAT_CHART_CLICK, onChartClick);
							}
							mapChartCalss.F_addChartOnMap(centerPoint, 90, chartParam.chartType, new ArrayCollection([chartObj]), chartParam.nameField, chartParam.valueFields, chartParam.codeNameHashtable, chartParam.colors, graAttriObj);
							
							break;
						}
					}
				}
				addChartLegend(chartParam);
			}
		}
		
		
		/**
		 * 功能: 设置地图显示区域
		 * 备注: 必须在地图上加载图表之前先设置好地图的显示区域
		 */		
		private function setRegionExtent(regionGraArray:Array, chartParam:StatChartParam, layerIdField:String):void
		{
			var fillSymbol:SimpleFillSymbol = new SimpleFillSymbol();
			fillSymbol.alpha = 0.3;
			fillSymbol.color = 0xffffff;
			fillSymbol.outline = new SimpleLineSymbol();
			fillSymbol.outline.alpha = 0.5;
			fillSymbol.outline.color = 0x0000ff;
			fillSymbol.outline.width = 1;
			
			var extentGraArray:Array = new Array();
			
			for each(var chartObj:Object in chartParam.dataProvider)
			{
				for each(var regionGra:Graphic in regionGraArray)
				{
					if(chartObj[chartParam.regionIdField] == regionGra.attributes[layerIdField])
					{
						extentGraArray.push(regionGra);
						
						regionGra.symbol = fillSymbol;
						
						chartBackGroundRenderer.add(regionGra);
					}
				}
			}
			
			MapUni.dataExtent(extentGraArray, map);
		}
		
		
		/**
		 * 监听: 图形的点击
		 */		
		private function onChartClick(event:StatEvent):void
		{
			var graphic:Graphic = event.data as Graphic;
			var graObj:Object = graphic.attributes;
			
			if(graObj.regionLayer == "provinceLayer")
			{
				ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_PARAM_CITY_SEND, graObj));
			}
			else if(graObj.regionLayer == "cityLayer")
			{
				ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_PARAM_COUNTY_SEND, graObj));
			}
			/*else if(graObj.regionLayer == "countyLayer")
			{
				ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_PARAM_CITY_SEND, graObj));
			}*/
		}
		
		
		/**
		 * 监听：地图渲染数据的派发 
		 */		
		private function onRenderDataSend(event:StatEvent):void
		{
			var rendererParam:StatChartParam = event.data as StatChartParam;
			layerRenderer.renererParam = rendererParam;
			
			var layerXML:XML = getLayerParam(rendererParam.regionLayer);
			layerRenderer.layerIdField = layerXML.@idField;
			
			var searchWhere:String = getRendererSearchWhere(rendererParam, layerXML.@idField);
			
			var layerLevel:uint = getLayerIndex(rendererParam.regionLayer);
			layerRenderer.startLevelRenderer(layerLevel, null, searchWhere);
			
			addRendererLegend(rendererParam);
		}
		
		
		/**
		 * 功能: 获取图层渲染的查询语句 
		 */		
		private function getRendererSearchWhere(rendererParam:StatChartParam, layerIdField:String):String
		{
			var whereStr:String = "";
			
			for each(var obj:Object in rendererParam.dataProvider)
			{
				var regionId:String = obj[rendererParam.regionIdField];
				
				whereStr += layerIdField + " = '" +  regionId + "' or ";
			}
			
			if(whereStr)
			{
				whereStr = whereStr.substr(0, whereStr.length-4);
			}
			
			return whereStr;
		}
		
		
		/**
		 * 功能：添加地图渲染图例 
		 */		
		private function addRendererLegend(rendererParam:StatChartParam):void
		{
			var legendSymbol:Array = new Array();
			var legendLabel:Array = new Array();
			
			for(var i:int=0; i<rendererParam.legendArray.length; i++)
			{
				var legendObj:Object = rendererParam.legendArray[i];
				
				legendSymbol.push(legendObj.symbol);
				legendLabel.push(legendObj.label);
			}
			
			var legendParam:LegendParam = new LegendParam();
			legendParam.operate = LegendParam.ADD;
			legendParam.legendName = rendererParam.statTitle;
			legendParam.legendSymbol = legendSymbol;
			legendParam.legendLabel = legendLabel;
			
			currLegend.push(legendParam);
			
			ViewerContainer.dispatchEvent(new AppEvent(AppEvent.LEGEND_EDIT, legendParam));
		}
		
		
		/**
		 * 功能：添加地图图表图例 
		 */		
		private function addChartLegend(chartParam:StatChartParam):void
		{
			var legendSymbol:Array = new Array();
			var legendLabel:Array = new Array();
			
			for(var i:int=0; i<chartParam.valueFields.length; i++)
			{
				var valueCode:String = chartParam.valueFields[i];
				var valueName:String = chartParam.codeNameHashtable.find(valueCode);
				
				var valueColor:Number = chartParam.colors[i];
				
				legendSymbol.push(valueColor);
				legendLabel.push(valueName);
			}
			
			var legendParam:LegendParam = new LegendParam();
			legendParam.operate = LegendParam.ADD;
			legendParam.legendName = chartParam.statTitle;
			legendParam.legendSymbol = legendSymbol;
			legendParam.legendLabel = legendLabel;
			
			currLegend.push(legendParam);
			
			ViewerContainer.dispatchEvent(new AppEvent(AppEvent.LEGEND_EDIT, legendParam));
		}
		
		
		/**
		 * 创建等级图层参数集合
		 */
		private function createLayerLevel():Array
		{
			var layerParamArray:Array = new Array();
			
			var layerList:XMLList = configXML.regionLayers.layer;
			
			for(var i:int=0; i<layerList.length(); i++)
			{
				var layerXML:XML = layerList[i];
				
				var layer:Layer = map.getLayer(layerXML.@mapLabel.toString());
				var layerUrl:String = MapUni.layerUrl(layer, layerXML.@layerName.toString());
				
				var layerParam:LevelRenderLayerParam = new LevelRenderLayerParam();
				layerParam.id = layerXML.@id.toString();
				layerParam.layerUrl = layerUrl;
				layerParam.layerIdField = layerXML.@idField.toString();
				layerParam.layerNameField = layerXML.@nameField.toString();
				
				layerParamArray.push(layerParam);
			}
			
			return layerParamArray;
		}
		
		
		/**
		 * 获取图层地址
		 */		
		private function getLayerUrl(mapLabel:String, layerName:String):String
		{
			var mapLayer:Layer = map.getLayer(mapLabel);
			var layerUrl:String = MapUni.layerUrl(mapLayer, layerName);
			
			return layerUrl;
		}
		
		
		/**
		 * 功能：获取图层序号 
		 */		
		private function getLayerIndex(layerId:String):uint
		{
			var layerList:XMLList = configXML.regionLayers.layer;
			
			for (var i:int=0; i<layerList.length(); i++)
			{
				if(layerList[i].@id == layerId)
				{
					return i;
				}
			}
			return null;
		}
		
		
		/**
		 * 功能：获取图层配置信息 
		 */		
		private function getLayerParam(layerId:String):XML
		{
			var layerList:XMLList = configXML.regionLayers.layer;
			
			for (var i:int=0; i<layerList.length(); i++)
			{
				if(layerList[i].@id == layerId)
				{
					return layerList[i];
				}
			}
			return null;
		}
		
		
	}
}









