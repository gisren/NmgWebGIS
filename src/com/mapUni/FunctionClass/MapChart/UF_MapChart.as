package com.mapUni.FunctionClass.MapChart
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.components.supportClasses.InfoPlacement;
	import com.esri.ags.components.supportClasses.InfoSymbolWindow;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.InfoSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.UtilComponent.Charts.UC_ColumnChart;
	import com.mapUni.UtilComponent.Charts.UC_LineChart;
	import com.mapUni.UtilComponent.Charts.UC_PieChart;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	
	
	public class UF_MapChart extends EventDispatcher
	{
		public function UF_MapChart(map:Map, chartGraphicsLayer:GraphicsLayer)
		{
			_map = map;
			
			_chartGraphicLayer = chartGraphicsLayer;
			
			_map.addEventListener(ZoomEvent.ZOOM_END, onMapExtentChange);
		}
		
		
		private var _map:Map = new Map();
		
		private var _chartGraphicLayer:GraphicsLayer = new GraphicsLayer();
		
		private var _isFixedSize:Boolean = true;
		
		
		/**
		 * 图表类型 柱状图 
		 */		
		public static const CHART_TYPE_COLUMN:String = "columnChart";
		/**
		 * 图表类型 饼状图 
		 */		
		public static const CHART_TYPE_PIE:String = "pieChart";
		/**
		 * 图标类型 折线图 
		 */		
		public static const CHART_TYPE_LINE:String = "lineChart";
		
		
		/**
		 * 设置图形是否可以跟随地图的放大缩小一起放大缩小，默认为true
		 */		
		public function set V_isFixedSize(value:Boolean):void
		{
			if(!_isFixedSize && value)
			{
				_map.addEventListener(ZoomEvent.ZOOM_END, onMapExtentChange);
			}
			if(_isFixedSize && !value)
			{
				_map.removeEventListener(ZoomEvent.ZOOM_END, onMapExtentChange);
			}
		}
		
		
		public function F_addChartOnMap(chartLocate:MapPoint, chartSize:Number, chartType:String,
									 	dataProvider:ArrayCollection, nameField:String, valueFields:Array, valuesNameHashtable:Hashtable=null, fillColors:Array=null,
									 	chartAttributes:Object=null, chartMaxSize:Number=0, chartMinSize:Number=0):void
		{
			
			var chartSymbol:InfoSymbol = createChartSymbol(chartType, chartSize, dataProvider, nameField, valueFields, valuesNameHashtable, fillColors);
			
			chartAttributes = arrangeData(chartAttributes, chartMaxSize, chartMinSize);
			
			createChartOnMap(chartLocate, chartSize, chartSymbol, chartAttributes);
		}
		
		
		/**
		 * 创建图表符号
		 */		
		protected function createChartSymbol(chartType:String, chartSize:Number, dataProvider:ArrayCollection, nameField:String, valueFields:Array, valuesNameHashtable:Hashtable, fillColors:Array):InfoSymbol
		{
			var chartClass:* = null;
			
			if(chartType == "columnChart")
			{
				chartClass = UC_ColumnChart;
			}
			else if(chartType == "pieChart")
			{
				chartClass = UC_PieChart;
			}
			else if(chartType == "lineChart")
			{
				chartClass = UC_LineChart;
			}
			
			var classFactory:ClassFactory = new ClassFactory();
			classFactory.generator = chartClass;
			classFactory.properties = {
				V_dataProvider:dataProvider, 
				V_nameField:nameField,
				V_valueFields:valueFields,
				V_fillColors:fillColors,
				V_nameHashtable:valuesNameHashtable,
				height:chartSize,
				width:chartSize
			};
			
			var infoSymbol:InfoSymbol = creatInfoSymbol(classFactory);
			
			return infoSymbol;
		}
				
		
		/**
		 * 
		 * 创建infoSymbol
		 * 
		 */	
		protected function creatInfoSymbol(chartClass:ClassFactory):InfoSymbol
		{
			var infoSymbol:InfoSymbol = new InfoSymbol();
			infoSymbol.infoPlacement = InfoPlacement.CENTER;
			infoSymbol.infoRenderer = chartClass;
			
			return infoSymbol;
		}
		
		
		/**
		 * 
		 * 将图表的最大值和最小值整个加入属性数据中
		 * 
		 */		
		protected function arrangeData(chartAttributes:Object, chartMaxSize:Number, chartMinSize:Number):Object
		{
			if(!chartAttributes)
				chartAttributes = new Object();
				
			chartAttributes.chartMaxSize = chartMaxSize;
			chartAttributes.chartMinSize = chartMinSize;
			
			return chartAttributes;
		}
		
		
		/**
		 * 
		 * 在地图上加载图表符号
		 * 
		 */		
		protected function createChartOnMap(chartLocate:MapPoint, chartSize:Number, chartSymbol:InfoSymbol, chartAttributes:Object=null):void
		{
			if(!chartLocate)
			{
				return ;
			}
			
			var date:Date = new Date();
			var year:String = date.getFullYear().toString();
			var mouth:String = date.getMonth().toString();
			var day:String = date.getDate().toString();
			var hour:String = date.getHours().toString();
			var minutes:String = date.getMinutes().toString();
			var seconds:String = date.getSeconds().toString();
			var millSeconds:String = date.getMilliseconds().toString();
			
			var mark:String = year + mouth + day + hour + minutes + seconds + millSeconds;
			
			var chartGra:Graphic = new Graphic(chartLocate, chartSymbol, chartAttributes);
			chartGra.name = "mapChart" + mark ;
			
			var rulerGra:Graphic = createChartRuler(chartLocate, chartSize);
			rulerGra.name = "chartRuler" + mark ;
			rulerGra.mouseEnabled = false;
			
			/* 
			添加点
			*/
			_chartGraphicLayer.add(rulerGra);
			_chartGraphicLayer.add(chartGra);
		}
		
		
		
		/**
		 *
		 * 创建图表符号的缩放标尺
		 *  
		 * @param chartPoint 点
		 * @param initSize 图表大小
		 * @return 
		 * 
		 */		
		protected function createChartRuler(chartPoint:MapPoint, initSize:Number):Graphic
		{
			/* 
			图表地图区域
			*/
			var screenPoint:Point = _map.toScreen(chartPoint);
			
			var minScreenPointX:Number = screenPoint.x - initSize/2;
			var minScreenPointY:Number = screenPoint.y + initSize/2;
			
			var maxScreenPointX:Number = screenPoint.x + initSize/2;
			var maxScreenPointY:Number = screenPoint.y - initSize/2;
			
			var minMapPoint:MapPoint = _map.toMap(new Point(minScreenPointX, minScreenPointY));
			var maxMapPoint:MapPoint = _map.toMap(new Point(maxScreenPointX, maxScreenPointY));
			
			var extent:Extent = new Extent(minMapPoint.x, minMapPoint.y, maxMapPoint.x, maxMapPoint.y);
			var extSym:SimpleFillSymbol = new SimpleFillSymbol("solid",0,0);
			
			var rulerGra:Graphic = new Graphic(extent, extSym);
			
			return rulerGra;
			
		}
			
		
		/**
		 *
		 * 监听地图显示区域的变化
		 * 
		 */		
		protected function onMapExtentChange(event:ZoomEvent):void
		{
			for each (var graphic:Graphic in _chartGraphicLayer.graphicProvider)
			{
				var chartGra:Graphic;
				
				var marke:String ="";
				
				var graName:String = graphic.name.substr(0,8);
				
				if(graName == "mapChart")
				{
					chartGra = graphic;
					marke = graphic.name.substring(8);
					
					findChartRuler(chartGra, marke);
				}
			}
		}
		
		
		/**
		 *
		 * 查找图表的标尺图形
		 * 
		 */		
		protected function findChartRuler(chartGra:Graphic, marke:String):void
		{
			var rulerGra:Graphic;
			
			for each (var gra:Graphic in _chartGraphicLayer.graphicProvider)
			{
				var graphicName:String = gra.name.substr(0,10);
				var markRuler:String = gra.name.substring(10);
				
				if(graphicName == "chartRuler" && markRuler == marke)
				{
					rulerGra = gra;
					break;
				}
			}
			
			if(rulerGra && chartGra)
			{
				reSetChartSize(rulerGra, chartGra);
			}
		}
		
		
		/**
		 * 
		 * 重新设置图表的大小
		 * 
		 */		
		protected function reSetChartSize(rulerGra:Graphic, chartGra:Graphic):void
		{
			/*
			从标尺图形那里获取图表下一步要显示的宽高
			*/
			var extent:Extent = rulerGra.geometry as Extent;
			
			var minMapPoint:MapPoint = new MapPoint(extent.xmin, extent.ymin);
			var maxMapPoint:MapPoint = new MapPoint(extent.xmax, extent.ymax);
			
			var minScreenPoint:Point = _map.toScreen(minMapPoint);
			var maxScreenPoint:Point = _map.toScreen(maxMapPoint);
			
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
				chartWidth = minChartWidth;
				chartHeight = minChartHeight;
			}
			if(chartWidth > maxChartWidth || chartHeight >maxChartHeight)
			{
				chartWidth = maxChartWidth;
				chartHeight = maxChartHeight;
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