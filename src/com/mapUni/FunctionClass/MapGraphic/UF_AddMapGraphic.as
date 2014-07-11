package com.mapUni.FunctionClass.MapGraphic
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.DrawEvent;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.events.MapEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.esri.ags.symbols.PictureFillSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.tools.DrawTool;
	import com.esri.ags.utils.JSON;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.rpc.AsyncResponder;
	import mx.utils.object_proxy;
	
	
	/**
	 * 点击地图上的点图标时派发事件
	 */	
	[Event(name="pointMouseClick", type="flash.events.Event")]
	
	/**
	 * 鼠标移动到地图上的点图标上时派发事件
	 */	
	[Event(name="pointMouseOver", type="flash.events.Event")]
	
	/**
	 * 鼠标移出地图上的点图标时派发事件
	 */	
	[Event(name="pointMouseOut", type="flash.events.Event")]
	
	
	/**
	 * 
	 * 向地图上加载 Graphic 
	 * 
	 * <p><b>方法：</b> AddMapPoint 向地图上加载点</p>
	 * 
	 * @author liuxl
	 * 
	 */	
	public class UF_AddMapGraphic extends EventDispatcher
	{
		public function UF_AddMapGraphic()
		{
			
		}
		
		
		/**
		 * 地图 若传入此参数则地图会自动缩放到所加载点的区域，若不传入也不影响 Graphic 的加载
		 */		
		public var map:Map = new Map();
		
		
		/**
		 * 在地图上被点击的点 
		 */		
		public var TargetPoint:Graphic = new Graphic();
		
		
		
		/**
		 * 点击地图上点的事件名称
		 */		
		public var POINT_MOUSE_CLICK:String = "pointMouseClick";	
		
		
		/**
		 * 点击地图上点的事件名称
		 */		
		public var POINT_MOUSE_OVER:String = "pointMouseOver";	
		
		
		/**
		 * 点击地图上点的事件名称
		 */		
		public var POINT_MOUSE_OUT:String = "pointMouseOut";	
		
		
		/**
		 * 点图层 
		 */		
		private var PointGraphicLayer:GraphicsLayer = new GraphicsLayer();

		
		/**
		 * 
		 * <p> 在地图上添加多点 </p>
		 * 
		 * @param dataProvider	点的数据源。可以为 JSON 格式的字符串、Object 格式的数据集合(Array、ArrayColl)或 MapPoint 格式的点的集合(Array、ArrayColl),
		 * 									当数据源为 MapPoint 格式的点的集合时，点的符号只能通过设置图层的点符号来设置，所有点将会是同一个符号
		 * @param xField	数据源中的经度字段名。当数据源是 MapPoint 格式的点的集合时可不传
		 * @param yField	数据源中的纬度字段名。当数据源是 MapPoint 格式的点的集合时可不传
		 * @param mapPointGraphicsLayer	要加载点的图层。如果所有点的显示符号相同，则可以设置为图层的符号，而不传 symbolField 的参数值。可选参数
		 * @param symbolField	数据源中的点的符号字段名。如果取出来的信息是地图符号，则直接加载，如果是图片存放相对路径则将生成图片点符号，symbolSizeField参数可以控制这一图片的大小。可选参数
		 * @param picParam	如果数据源的符号字段中存储的是图片符号的数据源地址，那么此参数数组用来控制这一图片符号的宽、高、x轴偏移、y轴偏移、旋转值。
		 * 
		 * @return 添加点的 Graphic 集合
		 *      
		 */		
		public function AddMapPoint(mapPointGraphicsLayer:GraphicsLayer, dataProvider:Object, xField:String="", yField:String="",
									 symbolField:String="", picParam:Array=null):ArrayCollection
		{
			var dataAryColl:ArrayCollection = new ArrayCollection();
			
			/*
			判断数据类型
			*/
			if(dataProvider is String)
			{
				var dataArray:Array = stringToJsonData(dataProvider as String);
				
				if(dataArray)
				{
					dataAryColl = new ArrayCollection(dataArray);
				}
			}
			else if(dataProvider is Array)
			{
				dataAryColl = new ArrayCollection(dataProvider as Array);
			}
			else if(dataProvider is ArrayCollection)
			{
				dataAryColl = ArrayCollection as ArrayCollection;
			}
			
			var symbolArray:Array = [20, 20, 0, 0, 0];
			if(picParam && picParam.length)
			{
				symbolArray = picParam;
			}
			
			var dataAry:ArrayCollection = createPointGraphic(dataAryColl, xField, yField, symbolField, mapPointGraphicsLayer, symbolArray);
			
			return dataAry;
		}
				
				
		/**
		 * 
		 * 创建 mapPoint Graphics 
		 * 
		 * @param dataProvider 数据源	
		 * @param xField 经度字段名
		 * @param yField 纬度字段名
		 * @param symbolField 符号字段名
		 * 
		 * @return 添加点的 Graphic 集合
		 * 
		 */			
		private function createPointGraphic(dataProvider:ArrayCollection, xField:String, yField:String, symbolField:String,
											pointGraphicLayer:GraphicsLayer, symbolArray:Array):ArrayCollection
		{
			var graColl:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<dataProvider.length; i++)
			{
				var graphic:Graphic = new Graphic();
				
				if(dataProvider[i] is Object)
				{
					graphic = creatGraphic(dataProvider[i], xField, yField, symbolField, symbolArray);
				}
				else if(dataProvider is MapPoint)
				{
					graphic = new Graphic(dataProvider[i]);
				}
				else
				{
					continue;
				}
				
				graphic.addEventListener(MouseEvent.CLICK, mouseClickGraphicHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OVER, mouseOverGraphicHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OUT, mouseOutGraphicHandler);
				
				if(pointGraphicLayer)
				{
					pointGraphicLayer.add(graphic);
				}
				else 
				{
					PointGraphicLayer.add(graphic);
				}
				
				graColl.addItem(graphic);
			}
			
			if(map)
			{
				MapUni.dataExtent(graColl, map);
			}
			
			return graColl;
		}
		
		
		/**
		 * 
		 *  功能:创建Graphic
		 * 
		 * 	参数：
		 * 		data：Object格式数据
		 *		longField：数据中的经度字段名称
		 * 		latField：数据中的纬度字段名称
		 * 		symbolField：数据中的符号地址字段
		 * 	返回：
		 * 		点Graphic
		 * 
		 */
		private function creatGraphic(dataObject:Object, xField:String, yField:String, symbolField:String, symbolArray:Array):Graphic
		{	
			var longitude:Number;
			var latitude:Number;
			var symbol:Symbol;
			
			var graphic:Graphic = new Graphic();
			
			if(dataObject && xField && yField)
			{
				longitude = dataObject[xField];
				latitude = dataObject[yField];
			}
			
			
			if(symbolField)
			{
				var sym:*;
				
				sym = dataObject[symbolField]; 
				
				if(sym is Symbol)
				{
					symbol = sym;
				}
				else if(sym is String)
				{
					var pos:Number = sym.length - 5;
					if(sym.substr(pos, 1)=="." || sym.substr(pos+1, 1)=="." || sym.substr(pos+2, 1)==".")
					{
						symbol = new PictureMarkerSymbol(sym);
					}
					
					if(symbol)
					{
						if(symbolArray[0])
						{
							PictureMarkerSymbol(symbol).width = symbolArray[0];
						}
						if(symbolArray[1])
						{
							PictureMarkerSymbol(symbol).height = symbolArray[1];
						}
						if(symbolArray[2])
						{
							PictureMarkerSymbol(symbol).xoffset = symbolArray[2];
						}
						if(symbolArray[3])
						{
							PictureMarkerSymbol(symbol).yoffset = symbolArray[3];
						}
						if(symbolArray[4])
						{
							PictureMarkerSymbol(symbol).angle = symbolArray[4];
						}
					}
				}
			}
			
			
			if(longitude && latitude)
			{
				var point:MapPoint = new MapPoint(longitude,latitude);
				
				graphic.geometry = point;
				graphic.attributes = dataObject;
				
				if(symbol)
				{
					graphic.symbol = symbol;
				}
				
				return graphic;
			}
			
			return null;
		}
		
		
		/**
		 * 
		 * <p>JSON格式字符串转换为数组</P> 
		 * 
		 * @param jsonData JSON格式字符串
		 * @return 数组
		 *  
		 */		
		public function stringToJsonData(jsonData:String):Array
		{
			var dataAry:Array = new Array();
			
			if(!jsonData)
			{
				return null;
			}
			
			try
			{
				dataAry = JSON.decode(jsonData);
			}
			catch(e:Error)
			{
				var error:String = "传入的 jsonData（" + jsonData + "） 字符串在转换为JSON格式时出现错误，请检查传入的字符串格式。";
				MapUni.errorWindow(error + "\n" + e.name + "\n" + e.message);	
				return null;
			}
			
			if(dataAry.length <= 0)
			{
				return null;
			}
			
			return dataAry;
		}
		
		
		/**
		 * 
		 * 事件：点击地图图标 
		 * 
		 */
		private function mouseClickGraphicHandler(event:MouseEvent):void
		{
			TargetPoint = event.currentTarget as Graphic;
			
			this.dispatchEvent(new Event(POINT_MOUSE_CLICK));
		}
		
		
		/**
		 * 
		 * 鼠标移动到地图点图标上
		 * 
		 */		
		private function mouseOverGraphicHandler(event:MouseEvent):void
		{
			TargetPoint = event.currentTarget as Graphic;
			
			this.dispatchEvent(new Event(POINT_MOUSE_OVER));
		}
		
		
		/**
		 * 
		 * 鼠标移出点在地图上的图标
		 * 
		 */		
		private function mouseOutGraphicHandler(event:MouseEvent):void
		{
			TargetPoint = event.currentTarget as Graphic;
			
			this.dispatchEvent(new Event(POINT_MOUSE_OUT));
		}
		
		
		/**
		 * 
		 * 清空加载的单点多点
		 * 
		 */
		public function clear():void
		{
			PointGraphicLayer.clear();
		}
		
		/**
		 * 
		 * 隐藏默认的图层
		 * 
		 */
		public function hide():void
		{
			PointGraphicLayer.visible = false;
		}
		
		/**
		 *
		 * 隐藏后重新显示隐藏的图层 
		 * 
		 */		
		public function show():void
		{
			PointGraphicLayer.visible = true;
		}
		
		
	}
}













