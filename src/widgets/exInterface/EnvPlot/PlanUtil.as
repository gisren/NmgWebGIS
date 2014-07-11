package widgets.exInterface.EnvPlot
{
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esrichina.dynamicplot.plot.IPlot;
	import com.esrichina.dynamicplot.tools.PlotFactory;
	
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.utils.NameUtil;
	
	public class PlanUtil
	{
		
		public static const EMPTY_PLAN:String = "<plan></plan>";
		
		public static function serializePlan(graphicsLayer:GraphicsLayer):String{
			var xmlStr:String = "<plan>";
			var graphics:ArrayCollection = graphicsLayer.graphicProvider as ArrayCollection;
			for each(var graphic:Graphic in graphics){
				xmlStr += serializeGraphic(graphic);
			}
			return xmlStr+"</plan>";
		}
		
		private static function serializeGraphic(graphic:Graphic):String
		{
			var xmlStr:String="";
			if(graphic.geometry is IPlot){
				var plotType:String = NameUtil.getUnqualifiedClassName(graphic.geometry);
				xmlStr += "<plot type='" + plotType + "'>";
				var plot:IPlot = graphic.geometry as IPlot;
				var points:Array = plot.getControlPoints();
				// 控制点信息
				xmlStr += "<controlpoints>";
				for each(var pnt:MapPoint in points){
					xmlStr += "<point x='" + pnt.x +"' y='" + pnt.y + "'/>";
				}
				xmlStr += "</controlpoints>";
				// 渲染信息
				xmlStr += "<symbol>";
				var symbol:SimpleFillSymbol = graphic.symbol as SimpleFillSymbol;
				var outline:SimpleLineSymbol = symbol.outline;
				xmlStr += "<fill color='" + symbol.color + "' alpha='" + symbol.alpha + "' style='" + symbol.style + "'/>";
				xmlStr += "<outline color='" + outline.color + "' alpha='" + outline.alpha + "' width='" + outline.width + "'/>" ;
				xmlStr += "</symbol>";
			}
			else if (graphic.geometry is Polygon){
				var polygon:Polygon = graphic.geometry as Polygon;
				xmlStr += "<plot type='Polygon'>";
				points = polygon.rings[0];
				xmlStr += "<points>";
				for each(pnt in points){
					xmlStr += "<point x='" + pnt.x + "' y='" + pnt.y + "'/>";
				}
				xmlStr += "</points>";
				xmlStr += "<symbol>";
				symbol = graphic.symbol as SimpleFillSymbol;
				outline = symbol.outline;
				xmlStr += "<fill color='" + symbol.color + "' alpha='" + symbol.alpha + "' style='" + symbol.style + "'/>";
				xmlStr += "<outline color='" + outline.color + "' alpha='" + outline.alpha + "' width='" + outline.width + "'/>" ;
				xmlStr += "</symbol>";
			}
			else if(graphic.geometry is Extent){
				var extent:Extent = graphic.geometry as Extent;
				xmlStr += "<plot type='Extent' xmin='" + extent.xmin + "' ymin='" + extent.ymin + "' xmax='" + extent.xmax + "' ymax='" + extent.ymax + "'>";
				xmlStr += "<symbol>";
				symbol = graphic.symbol as SimpleFillSymbol;
				outline = symbol.outline;
				xmlStr += "<fill color='" + symbol.color + "' alpha='" + symbol.alpha + "' style='" + symbol.style + "'/>";
				xmlStr += "<outline color='" + outline.color + "' alpha='" + outline.alpha + "' width='" + outline.width + "'/>" ;
				xmlStr += "</symbol>";
			}
			else if(graphic.geometry is Polyline){
				var polyline:Polyline = graphic.geometry as Polyline;
				xmlStr += "<plot type='Polyline'>";
				points = polyline.paths[0];
				xmlStr += "<points>";
				for each(pnt in points){
					xmlStr += "<point x='" + pnt.x + "' y='" + pnt.y + "'/>";
				}
				xmlStr += "</points>";
				xmlStr += "<symbol>";
				outline = graphic.symbol as SimpleLineSymbol;
				xmlStr += "<outline color='" + outline.color + "' alpha='" + outline.alpha + "' width='" + outline.width + "'/>" ;
				xmlStr += "</symbol>";
			}
			else if(graphic.geometry is MapPoint && graphic.symbol is PictureMarkerSymbol){
				pnt = graphic.geometry as MapPoint;
				xmlStr += "<plot type='MapPoint'>";
				xmlStr += "<point x='" + pnt.x + "' y='" + pnt.y + "'/>";
				xmlStr += "<symbol>";
				var markerSymbol:PictureMarkerSymbol = graphic.symbol as PictureMarkerSymbol;
				var source:String = markerSymbol.source as String;
				xmlStr += "<picture source='" + source + "'/>";
				xmlStr += "</symbol>";
			}
			else if (graphic.geometry is MapPoint && graphic.symbol is TextSymbol)
			{
				var textSymbol:TextSymbol=graphic.symbol as TextSymbol;
				var text:String=textSymbol.text;
				var textFormat:TextFormat=textSymbol.textFormat;
				var color:String=textFormat.color.toString();
				var font:String=textFormat.font.toString();
				var bold:String=textFormat.bold.toString();
				var italic:String=textFormat.italic.toString();
				var size:String = textFormat.size.toString();
				var underline:String = textFormat.underline.toString();
				
				var point:MapPoint = graphic.geometry as MapPoint;
				
				// 类型及ID信息
				xmlStr += "<plot type='Text'>";
				
				// 点位信息
				xmlStr += "<point x='" + point.x + "' y='" + point.y + "'/>";
				
				// 文本格式信息
				xmlStr+="<symbol>";
				xmlStr+="<text value='" + text + "'/>";
				xmlStr+="<color value='" + color + "'/>";
				xmlStr+="<font value='" + font + "'/>";
				xmlStr+="<bold value='" + bold + "'/>";
				xmlStr+="<italic value='" + italic + "'/>";
				xmlStr+="<size value='" + size + "'/>";
				xmlStr+="<underline value='" + underline + "'/>";
				xmlStr+="</symbol>";
			}
			return xmlStr+"</plot>";
		}
		
		public static function deserializePlan(graphicsLayer:GraphicsLayer, planXMLString:String):void{
			var xml:XML = new XML(planXMLString);
			for each(var plotXML:XML in xml.plot){
				var graphic:Graphic = deserializePlotXML(plotXML);
				graphicsLayer.add(graphic);
			}
		}
		
		private static function deserializePlotXML(plot:XML):Graphic{
			var geometry:Geometry;
			var symbol:Symbol;
			var type:String = plot.@type;
			switch(type){
				case "Polygon":
					var points:Array=[];
					var pntList:XMLList = plot..point;
					for each(var pnt:XML in pntList){
						var pntX:Number = pnt.@x;
						var pntY:Number = pnt.@y;
						points.push(new MapPoint(pntX, pntY));
					}
					geometry = new Polygon([points]);
					var fill:XML = plot.symbol.fill[0];
					var fillColor:int = fill.@color;
					var fillAlpha:Number = fill.@alpha;
					var fillStyle:String = fill.@style;
					var outline:XML = plot.symbol.outline[0];
					var lineColor:int = outline.@color;
					var lineWidth:Number = outline.@width;
					var lineAlpha:Number = outline.@alpha;
					symbol = new SimpleFillSymbol(fillStyle, fillColor, fillAlpha, new SimpleLineSymbol("solid", lineColor, lineAlpha, lineWidth));
					break;
				case "Extent":
					var xMin:Number = plot.@xmin;
					var xMax:Number = plot.@xmax;
					var yMin:Number = plot.@ymin;
					var yMax:Number = plot.@ymax;
					geometry = new Extent(xMin, yMin, xMax, yMax);
					fill = plot.symbol.fill[0];
					fillColor = fill.@color;
					fillAlpha = fill.@alpha;
					fillStyle = fill.@style;
					outline = plot.symbol.outline[0];
					lineColor = outline.@color;
					lineWidth = outline.@width;
					lineAlpha = outline.@alpha;
					symbol = new SimpleFillSymbol(fillStyle, fillColor, fillAlpha, new SimpleLineSymbol("solid", lineColor, lineAlpha, lineWidth));
					break;
				case "Polyline":
					points=[];
					pntList = plot..point;
					for each(pnt in pntList){
						x = pnt.@x;
						y = pnt.@y;
						points.push(new MapPoint(x, y));
					}
					geometry = new Polyline([points]);
					outline = plot.symbol.outline[0];
					lineColor = outline.@color;
					lineWidth = outline.@width;
					lineAlpha = outline.@alpha;
					symbol = new SimpleLineSymbol("solid", lineColor, lineAlpha, lineWidth);
					break;
				case "MapPoint":
					var pntXML:XML = plot.point[0];
					x = pntXML.@x;
					y = pntXML.@y;
					geometry = new MapPoint(x, y);
					var pictureXML:XML = plot..picture[0];
					var source:String = pictureXML.@source;
					symbol = new PictureMarkerSymbol(source);
					break;
				case "Text":
					var text:String=String(plot.symbol.text.@value);
					var color:Number=Number(plot.symbol.color.@value);
					var font:String=String(plot.symbol.font.@value);
					var bold:String=String(plot.symbol.bold.@value);
					var italic:String=String(plot.symbol.italic.@value);
					var size:Number = Number(plot.symbol.size.@value);
					var underline:String = String(plot.symbol.underline.@value);
					var textFormat:TextFormat=new TextFormat();
					textFormat.color = color;
					textFormat.font = font;
					textFormat.bold = bold == "true";
					textFormat.italic = italic == "true";
					textFormat.size = size;
					textFormat.underline = underline == "true";
					var textSymbol:TextSymbol=new TextSymbol();
					textSymbol.textFormat = textFormat;
					textSymbol.text = text;
					var x:Number = Number(plot.point.@x);
					var y:Number = Number(plot.point.@y);
					geometry = new MapPoint(x,y);
					symbol = textSymbol;
					break;
				default:
					points = [];
					for each(var xml:XML in plot..point){
						points.push(new MapPoint(Number(xml.@x), Number(xml.@y)));
					}
					var iPlot:IPlot = PlotFactory.createPlotGeometry(type);
					iPlot.setControlPoints(points);
					geometry = iPlot as Geometry;
					fill = plot.symbol.fill[0];
					fillColor = fill.@color;
					fillAlpha = fill.@alpha;
					fillStyle = fill.@style;
					outline = plot.symbol.outline[0];
					lineColor = outline.@color;
					lineWidth = outline.@width;
					lineAlpha = outline.@alpha;
					symbol = new SimpleFillSymbol(fillStyle, fillColor, fillAlpha, new SimpleLineSymbol("solid", lineColor, lineAlpha, lineWidth));
					break;
			}
			return new Graphic(geometry, symbol);
		}
	}
}