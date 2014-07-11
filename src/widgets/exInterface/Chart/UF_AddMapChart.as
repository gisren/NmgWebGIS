package widgets.exInterface.Chart
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.GraphicsLayer;
	import com.mapUni.BaseClass.MapChart.ColumnChart.UC_MapColumnChart1;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import com.mapUni.FunctionClass.MapChart.UF_MapChart;

	public class UF_AddMapChart
	{
		public function UF_AddMapChart()
		{
			
		}
		
		public var V_chartGraphicLayer:GraphicsLayer = new GraphicsLayer();
		
		public var V_isFixedSize:Boolean = false;
		
		public function set V_map(value:Map):void
		{
			map = value;
			map.addEventListener(ExtentEvent.EXTENT_CHANGE, onExtentChange);
		}
		public function get V_map():Map
		{
			return map;
		}
		private var map:Map = new Map();
		
		public var V_chartSize:Number = 0.12; 
		
		
		/**
		 *
		 * <p>添加单个图表</p>
		 *  
		 * @param chartLocate
		 * @param chartData
		 * @param XAxisDataField
		 * @param YAxisDataField
		 * @param chartTitle
		 * 
		 */		
		public function F_AddMapColumnChartSingle(chartType:String, chartLocate:Object, chartData:ArrayCollection, chartTitle:String, XAxisDataField:String, YAxisDataField:String, 
												    toolTipField:String, colorField:String):void
		{
			if(chartLocate is Array)
			{
				var array:Array = chartLocate as Array;
				
				searchChartLocatePoint(array[0], array[1], [chartType, chartData, XAxisDataField, YAxisDataField, chartTitle, toolTipField, colorField]);
			}
			else if(chartLocate is String || chartLocate is MapPoint)
			{
				createMapChart(chartLocate,[chartType, chartData, XAxisDataField, YAxisDataField, chartTitle, toolTipField, colorField]);
			}
		}
		
		
		
		/**
		 *
		 * <p>添加多个图表</p>
		 *  
		 * @param chartCollection
		 * @param chartLocateField
		 * @param chartDataField
		 * @param XAxisDataField
		 * @param YAxisDataField
		 * @param chartTitleField
		 * 
		 */		
		public function F_AddMapChartList(chartCollection:ArrayCollection, chartTypeField:String, chartLocateField:String, chartDataField:String, 
												chartTitleField:String, clickCallbackField:String, callbackParamField:String, XAxisDataField:String, chartSeriesField:String, seriesDataField:String,
												seriesNameField:String, seriesColorField:String, seriesToolTipField:String):void
		{
			for(var i:int=0;i<chartCollection.length;i++)
			{
				var chartParam:Object = chartCollection[i];
				
				var chartType:String = chartParam[chartTypeField];
				
				var chartLocate:Object = chartParam[chartLocateField];
				var chartData:ArrayCollection = new ArrayCollection(chartParam[chartDataField]);
				var chartTitle:String = chartParam[chartTitleField];
				var callbackName:String = chartParam[clickCallbackField];
				var callbackParamName:Array = chartParam[callbackParamField];
				var chartSize:Number = chartParam["chartSize"]["initialSize"];
				
				
				if(chartLocate is Array)
				{
					var array:Array = chartLocate as Array;
					
					searchChartLocatePoint(array[0], array[1], [chartType, chartData, chartTitle, callbackName, callbackParamName, XAxisDataField, chartSeriesField, seriesDataField, seriesNameField, seriesColorField, seriesToolTipField, chartSize]);
				}
				else if(chartLocate is String || chartLocate is MapPoint)
				{
					createMapChart(chartLocate, [chartType, chartData, chartTitle, callbackName, callbackParamName, XAxisDataField, chartSeriesField, seriesDataField, seriesNameField, seriesColorField, seriesToolTipField, chartSize]);
				}
			}
		}
		
		
		/**
		 * 
		 * 查询图表所在位置
		 * 
		 * @param layerName
		 * @param searchWhere
		 * @return 
		 * 
		 */		
		private function searchChartLocatePoint(layerName:String, searchWhere:String, chartParam:Array):void
		{
			var layerUrl:String = MapUni.layerUrl(map, layerName);
			
			if(layerUrl)
			{
				MapUni.search(layerUrl, null, searchWhere, onSearchRest, chartParam);
			}
			else
			{
				MapUni.errorWindow("没有找到"+ layerName + "图层地址");
			}
		}
		
		
		/**
		 * 
		 * 响应成功查询到图标所在位置的点
		 * 
		 */		
		private function onSearchRest(rest:ArrayCollection, chartParam:Array):void
		{
			if(rest && rest.length)
			{
				var mapPoint:MapPoint = null;
				
				var geometry:Geometry = Graphic(rest[0]).geometry;
				
				switch(geometry.type)
				{
					case Geometry.MAPPOINT:
						mapPoint = geometry as MapPoint;
						break;
					case Geometry.POLYGON:
					case Geometry.EXTENT:
						mapPoint = geometry.extent.center;
						break;
					default:
						return;
				}
				
				createMapChart(mapPoint, chartParam);
			}
		}
		
		
		/**
		 *
		 * 创建图表
		 *  
		 * @param mapPoint
		 * @param chartParam
		 * 
		 */		
		private function createMapChart(chartLocate:Object,chartParam:Array):void
		{
			var chartType:String = chartParam[0];
			
			var chartData:ArrayCollection = chartParam[1];
			var chartTitle:String = chartParam[2];
			var clickCallback:String = chartParam[3];
			var callbackParam:Array = chartParam[4];
			var XAxisDataField:String = chartParam[5];
			var seriesField:String = chartParam[6];
			
			var dataField:String = chartParam[7];
			var nameField:String = chartParam[8];
			var colorField:String = chartParam[9];
			var toolTipField:String = chartParam[10];
			var chartSize:Number = chartParam[11];
			
			var MapChart:UF_MapChart = new UF_MapChart(map, V_chartGraphicLayer);
			
			MapChart.addEventListener(MapChart.V_CHART_MOUSE_CLICK, onChartClick);
			
			switch(chartType)
			{
				case "ColumnChart":
					MapChart.F_CreateMapColumnChart(chartLocate, chartSize, chartTitle, chartData, XAxisDataField, seriesField, dataField, nameField, colorField, toolTipField);
					break;
				case "PieChart":
					MapChart.F_CreateMapPieChart(chartLocate, chartSize, chartTitle, chartData, XAxisDataField, seriesField, dataField, nameField, colorField, toolTipField);
					break;
				case "LineChart":
					MapChart.F_CreateMapLineChart(chartLocate, chartSize, chartTitle, chartData, XAxisDataField, seriesField, dataField, nameField, colorField, toolTipField);
					break;
			}
			
			
			function onChartClick(event:Event):void
			{
				var p:Array = callbackParam;
				
				ExternalInterface.call(clickCallback, p[0], p[1], p[2], p[3], p[4]);
			}
			
		}
		
		
		/**
		 * 
		 * 响应对地图显示区域变化的监听事件
		 * 重新设置图表在地图上的显示大小
		 * 
		 */		
		private function onExtentChange(event:ExtentEvent):void
		{
			if(!V_isFixedSize)
			{
				for each (var graphic:Graphic in V_chartGraphicLayer.graphicProvider)
				{
					if(graphic.geometry.type == Geometry.POLYGON)
					{
						var polygon:Polygon = graphic.geometry as Polygon;
						var extent:Extent =polygon.extent;
						
						var mPointMin:MapPoint = new MapPoint(extent.xmin,extent.ymin,map.spatialReference);
						var mPointMax:MapPoint = new MapPoint(extent.xmax,extent.ymax,map.spatialReference);
						
						var pPointMin:flash.geom.Point= map.toScreen(mPointMin);
						var pPointMax:flash.geom.Point= map.toScreen(mPointMax);
						
						//得到宽度和高度
						var w:Number= Math.abs(pPointMax.x-pPointMin.x);
						var h:Number= Math.abs(pPointMin.y-pPointMax.y);		
						
						graphic.getChildAt(0).width = w;	
						graphic.getChildAt(0).height = h;
					}
				}
			}
		}
		
		
		
		
		
		
		
		
		
	}
}
