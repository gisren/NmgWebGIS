package com.mapUni.FunctionClass.TrackPlay
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.utils.JSON;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.managers.CursorManager;

	
	/**
	 * 点击地图上的点图标时派发事件
	 */	
	[Event(name="moveLocate", type="flash.events.Event")]
	
	/**
	 * 鼠标对移动的轨迹有操作时派发事件 
	 */	
	[Event(name="lineMouseOperation", type="flash.events.Event")]
	
	/**
	 * 运行完毕后派发事件
	 */
	[Event(name="runEnd", type="flash.events.Event")]
	
	
	public class UF_TrackPlay extends EventDispatcher
	{
		/**
		 *
		 * 初始化 
		 * 
		 */		
		public function UF_TrackPlay() 
		{
			PointGraphicLayer.add(MoveGraphic);
			
			map.addLayer(LineGraphicsLayer);
			map.addLayer(PointGraphicLayer); 
		}
		
		
		/**
		 * 地图
		 */		
		private var map:Map = new Map();
		
		/**
		 * 要移动的点
		 */		
		private var MoveGraphic:Graphic = new Graphic();
		
		/**
		 * 数据源 点的 object 集合
		 */		
		private var MoveData:ArrayCollection = new ArrayCollection();
		
		/**
		 * X 轴坐标字段
		 */		
		private var xField:String = "";
		
		/**
		 * Y 轴坐标字段
		 */		
		private var yField:String = "";
		
		/**
		 * 计时器
		 */		
		private var MoveTimer:Timer = new Timer(0);
		
		/**
		 * 轨迹移动中的点位计数器
		 */		
		private var MoveNum:Number = 1;
		
		/**
		 * 点图层 
		 */		
		private var PointGraphicLayer:GraphicsLayer = new GraphicsLayer();
		
		/**
		 * 线图层
		 */		
		private var LineGraphicsLayer:GraphicsLayer = new GraphicsLayer();
		
		
		/**
		 * 移动轨迹（线）的符号样式 
		 */		
		public var TrackLineSymbol:SimpleLineSymbol = new SimpleLineSymbol("solid",0xFF0000,1,2);
		
		/**
		 * 点击地图上点的事件名称
		 */		
		public static const MOVE_LOCATE:String = "moveLocate";	
		
		/**
		 * 鼠标对轨迹线段单击操作的事件名称 
		 */		
		public static const LINE_MOUSE_CLICK:String = "lineMouseClick";	
		
		/**
		 * 鼠标移动到轨迹线段操作的事件名称 
		 */		
		public static const LINE_MOUSE_OVER:String = "lineMouseOver";
		
		/**
		 * 鼠标移出轨迹线段操作的事件名称 
		 */		
		public static const LINE_MOUSE_OUT:String = "lineMouseOut";
		
		/**
		 * 运行结束的事件名称 
		 */		
		public static const RUN_END:String = "runEnd";
		
		/**
		 * 当前运行到点的信息 
		 */		
		public var GraphicMoveObject:Object = new Object();
		
		/**
		 * 鼠标操作的轨迹线段 
		 */		
		public var LineMouseOperation:Graphic = new Graphic();
		
		/**
		 * 是否已经暂停 
		 */		
		public var isPause:Boolean = false;
		
		/**
		 * TrackMove 的当前状态，“notStart”表示还没有开始 “runing”表示正在运行 “pause”表示已经暂停 “end”表示已经运行完毕 
		 */		
		public var MoveState:String = "notStart";
		
		/**
		 * 计时器间隔 以毫秒为单位 可用来控制轨迹移动的速度
		 */		
		public var TimeInterval:Number = 50;
		
		/**
		 * 移动间隔 单位：米 默认值：10
		 */		
		public var MoveInterval:Number = 10;
		
		
		/**
		 *
		 * <b>功能：</b>轨迹移动是否正在运行
		 * <br/><b>返回：</b>布尔类型
		 * 
		 */	
		public function get isRuning():Boolean
		{
			if(MoveTimer.running)
			{
				return true;
			}
			
			return false;
		}
		
		
		/**
		 * 可用来设置轨迹移动的位置
		 */	
		public function get runCount():Number
		{
			return MoveNum;
		}
		public function set runCount(value:Number):void
		{
			MoveNum = value;
			runDesignatedLocation();
		}
		
		
		/**
		 *
		 * 执行轨迹移动
		 * 
		 */		
		public function trackPlay(_map:Map, _MoveGraphic:Graphic, 
								  _MoveData:ArrayCollection, _xField:String, _yField:String):void
		{
			map = _map;
			MoveGraphic = _MoveGraphic;
			MoveData = _MoveData;
			xField = _xField;
			yField = _yField;
			
			checkParamter();
		}
		

		/**
		 *
		 * <b>功能：</b>暂停轨迹移动 
		 * 如果轨迹移动正在运行则会暂停，如果已经暂停则再此调用此方法时会继续运行 
		 * 
		 */		
		public function pause():void
		{
			if(!isPause && MoveTimer.running)
			{
				MoveTimer.stop();
				
				MoveState = "pause";
			}
			else if(isPause && !MoveTimer.running)
			{
				MoveTimer.start();
			}
		}
		
		
		/**
		 * 
		 * <b>功能：</b>停止轨迹移动，清空轨迹图层
		 * 
		 */		
		public function stop():void
		{
			PointGraphicLayer.clear();
			LineGraphicsLayer.clear();
			if(MoveTimer.running)
			{
				MoveTimer.stop();
				MoveTimer.reset();
			}
		}
		
		
		/**
		 *
		 * 功能：检查执行轨迹移动前的参数和必要设置 
		 * 
		 */		
		private function checkParamter():void
		{
			if(MoveData && MoveData.length)
			{
				if(MoveData.length > 1)
				{
					toExtent();
					readyMove();
				}
				else
				{
					var mapPoint:MapPoint = createMapPoint(MoveData[0], xField, yField);
					
					map.centerAt(mapPoint);
				}
			}
		}
		
		
		/**
		 * 
		 * 功能：运行到指定地点
		 * 
		 */		
		private function runDesignatedLocation():void
		{
			var isMoveRun:Boolean = false;
			
			LineGraphicsLayer.clear();
			
			if(MoveTimer.running)
			{
				MoveTimer.stop();
				isMoveRun = true;
			}
			else
			{
				if(isPause)
				{
					readyMove();
					MoveTimer.stop();
				}
			}
			
			/*
			添加指定地点之前的轨迹
			*/
			for(var i:int=0;i<MoveNum;i++)
			{
				var oldMapPoint:MapPoint = createMapPoint(MoveData[i], xField, yField);
				var newMapPoint:MapPoint = createMapPoint(MoveData[i + 1], xField, yField);
				
				var lineGraphic:Graphic = drawPolyline(oldMapPoint, newMapPoint, TrackLineSymbol);
				lineGraphic.addEventListener(MouseEvent.CLICK, disPathTrackOnClick);
				lineGraphic.addEventListener(MouseEvent.MOUSE_OVER, disPathTrackOnOver);
				lineGraphic.addEventListener(MouseEvent.MOUSE_OUT,disPathTrackOnOut);
				
				LineGraphicsLayer.add(lineGraphic);
			}
			
			/*
			如果指定运行地点时轨迹移动正在运行，
			则指定完成后轨迹移动会从指定的位置继续运行
			*/
			if(isMoveRun)
			{
				readyMove();
			}
		}
		
		
		/**
		 * 
		 * 功能：配置要移动的两个点
		 * 
		 */		
		private function readyMove():void
		{
			MoveState = "runing";
			
			var oldMapPoint:MapPoint = createMapPoint(MoveData[MoveNum - 1], xField, yField);
			var newMapPoint:MapPoint = createMapPoint(MoveData[MoveNum], xField, yField);
			
			disPatchMoveLocate();
			
			smoothMove(oldMapPoint, newMapPoint);
		}
			
			
		/**
		 * 
		 * 功能：两点间的平滑移动
		 * 
		 * 参数：oldMapPoint	出发点
		 * 		newMapPoint	目标点
		 * 返回：无
		 * 
		 */		
		private function smoothMove(oldMapPoint:MapPoint, newMapPoint:MapPoint):void
		{
			/*
			计算两点间的经度、纬度差值
			*/
			var oldLong:Number = oldMapPoint.x;
			var oldLat:Number = oldMapPoint.y;
			
			var newLong:Number = newMapPoint.x;
			var newLat:Number = newMapPoint.y;
			
			var longLength:Number = newLong - oldLong;
			var latLength:Number = newLat - oldLat;
			
			/*
			计算两点间的实际距离差值
			*/
			var num:Number = getToPointDistance(oldMapPoint, newMapPoint);
			num = Math.round(num);
			
			/*
			计算两点间要实现平滑移动所需的点经度、纬度单次移动距离
			*/
			var longEvery:Number = longLength/num*MoveInterval;
			var latEvery:Number = latLength/num*MoveInterval;
			
			/*
			用 Timer 来实现规定时间内点的移动和线的绘制
			*/
			MoveTimer = new Timer(TimeInterval,num);
			MoveTimer.addEventListener(TimerEvent.TIMER, onTimer_run);
			MoveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer_complete);
			MoveTimer.start();
			
			
			var midelOldPoint:MapPoint = MoveGraphic.geometry as MapPoint;
			
			/*
			timer 到达指定的时间间隔后调用此方法
			*/
			function onTimer_run(event:TimerEvent):void
			{
				var midelNewPoint:MapPoint = getNextMidelPoint(midelOldPoint, longEvery, latEvery);
				
				var midelLineGra:Graphic = drawPolyline(midelOldPoint, midelNewPoint, TrackLineSymbol);
				
				LineGraphicsLayer.add(midelLineGra);
				
				MoveGraphic.geometry = midelNewPoint;
				
				midelOldPoint = midelNewPoint;
			}
			
			/*
			timer 计时结束
			*/		
			function onTimer_complete(newMapPoint:MapPoint):void
			{
				GraphicMoveObject = MoveData[MoveNum];
				
				if(MoveNum < MoveData.length - 1)
				{
					var lineGraphic:Graphic = drawPolyline(oldMapPoint, newMapPoint, TrackLineSymbol);
					lineGraphic.addEventListener(MouseEvent.CLICK, disPathTrackOnClick);
					lineGraphic.addEventListener(MouseEvent.MOUSE_OVER, disPathTrackOnOver);
					lineGraphic.addEventListener(MouseEvent.MOUSE_OUT,disPathTrackOnOut);
					
					LineGraphicsLayer.add(lineGraphic);
					
					MoveNum++;
					readyMove();
				}
				else
				{
					disPatchMoveLocate();
					disPathMoveEnd();
				}
			}
		}
		
		
		/**
		 * 
		 * 功能：计算出平滑移动中要移动到的下一个点
		 * 
		 * 参数：midelOldPoint 当前点
		 * 		long 	目标点与当前点的经度差值
		 * 		lat		目标点与当前点的纬度差值
		 * 返回：目标点
		 * 
		 */
		private function getNextMidelPoint(midelOldPoint:MapPoint, long:Number, lat:Number):MapPoint
		{
			var longitude:Number = midelOldPoint.x + long;
			var latiude:Number = midelOldPoint.y + lat;
			
			var midelNewPoint:MapPoint = new MapPoint(longitude,latiude,map.spatialReference);
			
			return midelNewPoint;
		}
		
		
		/**
		 *
		 * 功能：画直线
		 * 
		 * 参数：传入直线的两个端点
		 * 返回：直线的Graphic
		 * 
		 */		
		private function drawPolyline(mapPointA:MapPoint, mapPointB:MapPoint, lineSymbol:SimpleLineSymbol):Graphic
		{
			var array:Array = new Array();
			array.push(mapPointA);
			array.push(mapPointB);
			
			var newPolyline:Polyline = new Polyline();
			newPolyline.addPath(array);
			
			var object:Object = {
				firstPoint:mapPointA,
				last:mapPointB
			}
			
			var lineGraphic:Graphic = new Graphic(newPolyline, lineSymbol, object);
			
			return lineGraphic;
		}
		
		
		/**
		 * 
		 * 功能：计算两点间的实际距离
		 * 
		 * 参数：要计算的两个点
		 * 返回：两点间的实际距离，单位：米
		 * 
		 */		
		private function getToPointDistance(oldMapPoint:MapPoint, newMapPoint:MapPoint):Number
		{
			var oldLong:Number = oldMapPoint.x;
			var oldLat:Number = oldMapPoint.y;
			
			var newLong:Number = newMapPoint.x;
			var newLat:Number = newMapPoint.y;
			
			var longLength:Number = newLong - oldLong;
			var latLength:Number = newLat - oldLat;
			
			var mapUnit:String = getMapUnits();
			
			var z:Number;
			
			if(mapUnit == "esriDecimalDegrees")
			{
				var x:Number = longLength * 111000 * Math.cos((newLat+oldLat)/2*Math.PI/180);
				var y:Number = latLength * 111000;
				
				z = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
			}
			else if(mapUnit == "esriMeters")
			{
				z = Math.sqrt(Math.pow(longLength,2) + Math.pow(latLength,2));
			}
			
			return z;
		}
		
		
		/**
		 * 
		 * 功能：创建点
		 * 
		 * 参数：object 信息集合
		 * 		xField	信息集合中的经度字段
		 * 		yField	信息集合中的纬度字段
		 * 返回：MapPoint点
		 * 
		 */			
		private function createMapPoint(object:Object, xField:String, yField:String):MapPoint
		{
			try
			{
				var longitude:Number = object[xField];
				var latitude:Number = object[yField];
				
				if(longitude && latitude)
				{
					var mapPoint:MapPoint = new MapPoint(longitude, latitude, map.spatialReference);
					
					return mapPoint;
				}
			}
			catch(e:Error)
			{
				MapUni.errorWindow("提取" + object.toString() + "经纬度信息，并转为点时出错。" + e.name + e.message);
			}
			
			return null;
		}
		
		
		/**
		 * 
		 * 功能：获取地图单位 
		 * 
		 */		
		private function getMapUnits():String
		{
			var mapUnit:String = "";
			
			var layers:ArrayCollection = map.layers as ArrayCollection;
			
			for(var t:int=0;t<layers.length;t++)
			{
				if(layers[t] is ArcGISDynamicMapServiceLayer || layers[t] is ArcGISTiledMapServiceLayer)
				{
					mapUnit = layers[t].units;
					
					return 	mapUnit;			
				}
			}
			return "";
		}
		
		
		/**
		 *
		 * 功能：缩放到当前位置
		 * 
		 */		
		private function toExtent():void
		{
			MapUni.dataExtent(MoveData, map);
		}
		
		
		/**
		 * 
		 * 功能：派发轨迹当前移动到的位置
		 * 
		 */		
		private function disPatchMoveLocate():void
		{
			GraphicMoveObject = MoveData[MoveNum - 1];
			this.dispatchEvent(new Event(MOVE_LOCATE));
		}
		
		
		/**
		 * 
		 * 功能：派发鼠标单击轨迹线段的事件
		 * 
		 */	
		private function disPathTrackOnClick(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			LineMouseOperation = graphic;
			
			this.dispatchEvent(new Event(LINE_MOUSE_CLICK));
		}
		
		
		/**
		 * 
		 * 功能：派发鼠标移动到轨迹线段上的事件
		 * 
		 */	
		private function disPathTrackOnOver(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			LineMouseOperation = graphic;
			
			this.dispatchEvent(new Event(LINE_MOUSE_OVER));
		}
		
		
		/**
		 * 
		 * 功能：派发鼠标移出轨迹线段的事件
		 * 
		 */		
		private function disPathTrackOnOut(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			LineMouseOperation = graphic;
			
			this.dispatchEvent(new Event(LINE_MOUSE_OUT));
		}
		
		
		/**
		 * 
		 * 功能：派发轨迹移动事件运行完成
		 * 
		 */		
		private function disPathMoveEnd():void
		{
			MoveState = "end";
			
			this.dispatchEvent(new Event(RUN_END));
		}
		
		
		
		
		
		
	}
}