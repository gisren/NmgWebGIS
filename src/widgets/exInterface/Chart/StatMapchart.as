package widgets.exInterface.Chart
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.components.supportClasses.InfoPlacement;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.InfoSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.FunctionClass.MapChart.UF_MapChart;
	import com.mapUni.UtilComponent.Charts.UC_ColumnChart;
	import com.mapUni.UtilComponent.Charts.UC_LineChart;
	import com.mapUni.UtilComponent.Charts.UC_PieChart;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.graphics.SolidColorStroke;
	
	public class StatMapchart extends UF_MapChart
	{
		public function StatMapchart(map:Map, chartGraphicsLayer:GraphicsLayer)
		{
			super(map, chartGraphicsLayer);
			
			this.map = map;
		}
		
		public var YAxisMaxNum:Number = 0;
		
		public var chartTitle:String = "";
		
		private var map:Map = new Map();
		
		private var widthScale:Number = 1;
		private var heightScale:Number = 1;
		
		
		
		
		protected override function createChartSymbol(chartType:String, chartSize:Number, dataProvider:ArrayCollection, nameField:String, valueFields:Array, valuesNameHashtable:Hashtable, fillColors:Array):InfoSymbol
		{
			var properties:Object = new Object();
			
			
			var chartClass:* = null;
			
			if(chartType == "columnChart")
			{
				chartClass = UC_ColumnChart;
				
				properties.V_dataProvider = dataProvider;
				properties.V_nameField = nameField;
				properties.V_valueFields = valueFields;
				
//				properties.V_title = dataProvider[0][nameField];
				properties.V_textColor = 0xff0000;
				properties.V_xAxisVisible = false;
				properties.V_yAxisVisible = false;
				properties.V_lineAxisVisible = false;
				properties.V_maximum = YAxisMaxNum;
				properties.V_xAxisStroke = getStroke();
				properties.V_columnWidthRatio = 1;
				
				widthScale = 0.8;
				heightScale = 1.5;
			}
			else if(chartType == "pieChart")
			{
				chartClass = UC_PieChart;
				
				properties.V_dataProvider = reSetPiechartData(dataProvider, nameField, valueFields, valuesNameHashtable);
				properties.V_nameField = "name";
				properties.V_valueFields = ["value"];
			}
			else if(chartType == "lineChart")
			{
				chartClass = UC_LineChart;
			}
			
			
			properties.V_fillColors = fillColors;
			properties.V_nameHashtable = valuesNameHashtable;
			properties.height = chartSize*heightScale;
			properties.width = chartSize*widthScale;
			
			var classFactory:ClassFactory = new ClassFactory();
			classFactory.generator = chartClass;
			classFactory.properties = properties;
			
			var infoSymbol:InfoSymbol = creatInfoSymbol(classFactory);
			
			return infoSymbol;
		}

		
		private function getStroke():SolidColorStroke
		{
			var solidColorStroke:SolidColorStroke = new SolidColorStroke();
			solidColorStroke.caps = "square";
			solidColorStroke.color = 0x09C81D;
			solidColorStroke.weight = 4;
			
			return solidColorStroke;
		}
		
		
		private function reSetPiechartData(dataProvider:ArrayCollection, nameField:String, valueFields:Array, valuesNameHashtable:Hashtable):ArrayCollection
		{
			var dataObj:Object = dataProvider[0];
			
			var pieDataProvider:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<valueFields.length; i++)
			{
				var valueField:String = valueFields[i];
				var valueName:String = valuesNameHashtable.find(valueField);
				var value:Number = dataObj[valueField];
				
				var itemObj:Object = new Object();
				itemObj.name = valueName;
				itemObj.value = value;
				
				pieDataProvider.addItem(itemObj);
			}
			
			return pieDataProvider;
			
		}
		
		
		protected override function createChartRuler(chartPoint:MapPoint, initSize:Number):Graphic
		{
			/* 
			图表地图区域
			*/
			var screenPoint:Point = map.toScreen(chartPoint);
			
			var minScreenPointX:Number = (screenPoint.x - initSize/2)*widthScale;
			var minScreenPointY:Number = (screenPoint.y + initSize/2)*heightScale;
			
			var maxScreenPointX:Number = (screenPoint.x + initSize/2)*widthScale;
			var maxScreenPointY:Number = (screenPoint.y - initSize/2)*heightScale;
			
			var minMapPoint:MapPoint = map.toMap(new Point(minScreenPointX, minScreenPointY));
			var maxMapPoint:MapPoint = map.toMap(new Point(maxScreenPointX, maxScreenPointY));
			
			var extent:Extent = new Extent(minMapPoint.x, minMapPoint.y, maxMapPoint.x, maxMapPoint.y);
			var extSym:SimpleFillSymbol = new SimpleFillSymbol("solid",0,0);
			
			var rulerGra:Graphic = new Graphic(extent, extSym);
			
			return rulerGra;
		}

		
		protected override function reSetChartSize(rulerGra:Graphic, chartGra:Graphic):void
		{
			/*
			从标尺图形那里获取图表下一步要显示的宽高
			*/
			var extent:Extent = rulerGra.geometry as Extent;
			
			var minMapPoint:MapPoint = new MapPoint(extent.xmin, extent.ymin);
			var maxMapPoint:MapPoint = new MapPoint(extent.xmax, extent.ymax);
			
			var minScreenPoint:Point = map.toScreen(minMapPoint);
			var maxScreenPoint:Point = map.toScreen(maxMapPoint);
			
			var chartWidth:Number = Math.abs(maxScreenPoint.x -  minScreenPoint.x);
			var chartHeight:Number = Math.abs(maxScreenPoint.y -  minScreenPoint.y);
			
			
			var minChartWidth:Number = 50;
			var minChartHeight:Number = 50;
			var maxChartWidth:Number = 300;
			var maxChartHeight:Number = 300;
			
			
			var chartAttributes:Object = chartGra.attributes as Object;
			var maxSize:Number = chartAttributes.chartMaxSize;
			var minSize:Number = chartAttributes.chartMinSize;
			
			if(maxSize)
			{
				maxChartHeight = maxSize;
				maxChartWidth = maxSize;
			}
			if(minSize)
			{
				minChartWidth = minSize;
				minChartHeight = minSize;
			}
			
			if(chartWidth < minChartWidth || chartHeight < minChartHeight)
			{
				chartWidth = minChartWidth*widthScale;
				chartHeight = minChartHeight*heightScale;
			}
			if(chartWidth > maxChartWidth || chartHeight >maxChartHeight)
			{
				chartWidth = maxChartWidth*widthScale;
				chartHeight = maxChartHeight*heightScale;
			}
			
			
			/*
			重新定义图表的大小
			*/
			var charSymbol:InfoSymbol = chartGra.symbol as InfoSymbol;
			
			var chartClass:ClassFactory = charSymbol.infoRenderer as ClassFactory;
			
			var charProperties:Object = chartClass.properties;
			
			if(chartWidth != charProperties.width || chartHeight != charProperties.height)
			{
				charProperties.width = chartWidth;
				charProperties.height = chartHeight;
				
				var newSybl:InfoSymbol = new InfoSymbol();
				newSybl.infoPlacement = InfoPlacement.CENTER;
				newSybl.infoRenderer = chartClass;
				
				chartGra.symbol = newSybl;
			}
		}
	}
}












