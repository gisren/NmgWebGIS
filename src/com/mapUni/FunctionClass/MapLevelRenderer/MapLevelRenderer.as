package com.mapUni.FunctionClass.MapLevelRenderer
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import spark.effects.Move;
	import spark.filters.GlowFilter;
	
	
	public class MapLevelRenderer
	{
		public function MapLevelRenderer(map:Map=null, layerParamArray:Array=null)
		{
			this.map = map;
			this.layerParamArray = layerParamArray;
			
			init();
		}
		
		private var _map:Map = new Map;
		
		private var _layerParamArray:Array = new Array();
		
		private var _layerFillSymbol:SimpleFillSymbol;
		
		private var _graphicFilters:Array;
		
		private var _graphicToolTipCom:UIComponent;
		
		private var _graphicInfoCom:UIComponent;
		
		private var _layerTextSymbol:TextSymbol;
		
		
		private var renderBackgroundLayer:GraphicsLayer;
		
		protected var renderGraLayer:GraphicsLayer;
		
		protected var renderNameLayer:GraphicsLayer;
		
		private var moveTimer:Timer;
		
		private var currentStageX:Number;
		private var currentStageY:Number;
		
		private var appTopWindow:Object;
		
		private var _currentLayerLevel:uint = 0;
		
		private var isTooltipComHave:Boolean = false;
		private var isInfoComHave:Boolean = false;
		
		
		/**
		 * 地图
		 */		
		public function set map(value:Map):void
		{
			_map = value;
		}
		public function get map():Map
		{
			return _map;
		}
		
		
		/**
		 * 图层参数，LevelRenderLayerParam 的数组集合
		 */		
		public function set layerParamArray(value:Array):void
		{
			_layerParamArray = value;
		}
		public function get layerParamArray():Array
		{
			return _layerParamArray;
		}
		
		
		/**
		 * 图层的填充符号
		 */		
		public function set layerFullSymbol(value:SimpleFillSymbol):void
		{
			_layerFillSymbol = value;
		}
		public function get layerFullSymbol():SimpleFillSymbol
		{
			return _layerFillSymbol;
		}
		
		
		/**
		 * 图层文本符号
		 */		
		public function set layerTextSymbol(value:TextSymbol):void
		{
			_layerTextSymbol = value;
		}
		public function get layerTextSymbol():TextSymbol
		{
			return _layerTextSymbol;
		}
		
		
		/**
		 * 鼠标移动到图层中的图形对象时应用的效果
		 */		
		public function set graphicFilters(value:Array):void
		{
			_graphicFilters = value;
		}
		public function get graphicFilters():Array
		{
			return _graphicFilters;
		}
		
		
		/**
		 * 鼠标移动到图形对象上时的提示信息框
		 * 提示框的必须实现 ITooltipContiner 接口
		 * 并且继承UIComponent基类
		 */		
		public function set graphicToolTipCom(value:ILevelRenderTooltipContiner):void
		{
			_graphicToolTipCom = value as UIComponent;
			
			_graphicToolTipCom.visible = false;
			appTopWindow.addElement(_graphicToolTipCom);
			
			_graphicToolTipCom.mouseEnabled = false;
			_graphicToolTipCom.mouseChildren = false;
			
			isTooltipComHave = true;
		}
		public function get graphicToolTipCom():ILevelRenderTooltipContiner
		{
			return _graphicToolTipCom as ILevelRenderTooltipContiner;
		}
		
		
		/**
		 * 鼠标移动到图形名称上时的信息框
		 * 信息框的必须实现 ITooltipContiner 接口
		 */		
		public function set graphicInfoCom(value:ILevelRenderTooltipContiner):void
		{
			_graphicInfoCom = value as UIComponent;
			
			_graphicInfoCom.visible = false;
			_graphicInfoCom.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			appTopWindow.addElement(_graphicInfoCom);
			
			isInfoComHave = true;
			
			function onRollOut(event:MouseEvent):void
			{
				_graphicInfoCom.visible = false;
			}
		}
		public function get graphicInfoCom():ILevelRenderTooltipContiner
		{
			return _graphicInfoCom as ILevelRenderTooltipContiner;
		}
		
		public function get currentLayerLevel():uint
		{
			return _currentLayerLevel;
		}
		
		/**
		 * 隐藏区域信息窗口
		 */		
		public function hideRegionInfo():void
		{
			_graphicInfoCom.visible = false;
		}
		
		
		/**
		 * 隐藏等级渲染的图层
		 */		
		public function hideLayer():void
		{
			renderBackgroundLayer.visible = false;
			renderGraLayer.visible = false;
			renderNameLayer.visible = false;
			
			if(isTooltipComHave)
			{
				appTopWindow.removeElement(_graphicToolTipCom);
				isTooltipComHave = false;
			}
			if(isInfoComHave)
			{
				appTopWindow.removeElement(_graphicInfoCom);
				isInfoComHave = false;
			}
		}
		
		
		/**
		 * 重新显示等级渲染的图层
		 */		
		public function showLayer():void
		{
			renderBackgroundLayer.visible = true;
			renderGraLayer.visible = true;
			renderNameLayer.visible = true;
			
			if(!isTooltipComHave)
			{
				if(_graphicToolTipCom)
				{
					appTopWindow.addElement(_graphicToolTipCom);
					isTooltipComHave = true;
				}
			}
			if(!isInfoComHave)
			{
				if(_graphicInfoCom)
				{
					appTopWindow.addElement(_graphicInfoCom);
					isInfoComHave = true;
				}
			}
		}
		
		
		/**
		 * 清空等级渲染所有图层对象 
		 */		
		public function clear():void
		{
			renderBackgroundLayer.clear();
			renderGraLayer.clear();
			renderNameLayer.clear();
			
			if(_graphicToolTipCom)
			{
				_graphicToolTipCom.visible = false;
			}
			
			if(_graphicInfoCom)
			{
				_graphicInfoCom.visible = false;
			}
		}
		
		
		protected function init():void
		{
			//添加图层
			renderBackgroundLayer = new GraphicsLayer();
			renderGraLayer = new GraphicsLayer();
			renderNameLayer = new GraphicsLayer();
			_map.addLayer(renderBackgroundLayer); 
			_map.addLayer(renderGraLayer);
			_map.addLayer(renderNameLayer);
			
			
			//计时器
			moveTimer = new Timer(50);
			moveTimer.addEventListener(TimerEvent.TIMER, onTimer);
			
			//顶级窗口
			appTopWindow = FlexGlobals.topLevelApplication;
			
			//图形对象图层的简单填充符号
			_layerFillSymbol = new SimpleFillSymbol();
			_layerFillSymbol.color = 0x0000ff;
			_layerFillSymbol.alpha = 0.5;
			_layerFillSymbol.outline = new SimpleLineSymbol();
			_layerFillSymbol.outline.color = 0xffffff;
			renderGraLayer.symbol = _layerFillSymbol;
			
			//图层对象名称的符号样式
//			_layerTextSymbol = new TextSymbol();
//			_layerTextSymbol.textFormat = new TextFormat();
//			_layerTextSymbol.textFormat.bold = true;
//			_layerTextSymbol.textFormat.color = 0xff0000;
//			_layerTextSymbol.textFormat.size = 16;
//			_layerTextSymbol.textFunction = layerTextSymbolSelectText;
			
			//图形发光效果
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xffffff;
			glowFilter.strength = 1;
			glowFilter.quality = 2;
			_graphicFilters = [glowFilter];
		}
		
		
		
		
		
		/**
		 * 
		 * <p>开始地图渲染</p>
		 * 
		 * @param layerLevel 要渲染地图的图层等级
		 * @param searchWhere 属性查询条件
		 * 
		 */
		public function startLevelRenderer(layerLevel:uint, searchGeometry:Geometry=null, searchWhere:String=""):void
		{
			this.showLayer();
			
			if(layerLevel >= 0 && layerLevel < _layerParamArray.length)
			{
				var layerParam:LevelRenderLayerParam = _layerParamArray[layerLevel] as LevelRenderLayerParam;
				
				if(searchGeometry){
					layerParam.searchGeometry = searchGeometry;
				}
				if(searchWhere){
					layerParam.searchWhere = searchWhere;
				}
				
				if(!searchGeometry && !searchWhere)
				{
					layerParam.searchWhere = "1=1";
				}
				
				layerRendererStart(layerParam, layerLevel);
			}
		}
		
		
		protected function layerRendererStart(layerParam:LevelRenderLayerParam, layerLevel:uint):void
		{
			if(layerParam)
			{
				var layerUrl:String = layerParam.layerUrl;
				var nameField:String = layerParam.layerNameField;
				var idField:String = layerParam.layerIdField;
				var searchWhere:String = layerParam.searchWhere; 
				var searchGeometry:Geometry = layerParam.searchGeometry;
				
				searchLayer(layerUrl, searchGeometry, searchWhere, idField, nameField);
				
				_currentLayerLevel = layerLevel;
			}
			else
			{
				showError(_layerParamArray.toString() + "图层参数中第" + layerLevel + "个图层不是LevelRenderLayerParam类型，或是为空的数值");
			}
		}
		
		
		/**
		 * 查询要进行渲染的对象 
		 */
		protected function searchLayer(layerUrl:String, searchGeometry:Geometry, searchWhere:String, idField:String, nameField:String):void
		{
			MapUni.search(layerUrl, searchGeometry, searchWhere, onLayerSearchEnd);
			
			function onLayerSearchEnd(featureSet:FeatureSet):void
			{
				renderNameLayer.clear();
				renderGraLayer.clear();
				renderBackgroundLayer.clear();
				
				//缩放地图
				MapUni.dataExtent(featureSet.features, _map, 0.2);
				
				createBackGroundGraphic();
				
				for each(var graphic:Graphic in featureSet.features)
				{
					regionRenderer(graphic, idField, nameField, layerUrl);
					
					createNameSymbol(graphic, idField, nameField, layerUrl);
				}
			}
		}
		
		
		/**
		 * 创建背景透明图形
		 */
		protected function createBackGroundGraphic():void
		{
			var mapPoint1:MapPoint = _map.toMapFromStage(appTopWindow.x, appTopWindow.y);
			var mapPoint2:MapPoint = _map.toMapFromStage(appTopWindow.x + appTopWindow.width, appTopWindow.y);
			var mapPoint3:MapPoint = _map.toMapFromStage(appTopWindow.x + appTopWindow.width, appTopWindow.y + appTopWindow.height);
			var mapPoint4:MapPoint = _map.toMapFromStage(appTopWindow.x, appTopWindow.y + appTopWindow.height);
			
			var ringArray:Array = [mapPoint1, mapPoint2, mapPoint3, mapPoint4];
			
			var polygon:Polygon = new Polygon();
			polygon.addRing(ringArray);
			
			var graphic:Graphic = new Graphic();
			graphic.geometry = polygon;
			graphic.symbol = _layerFillSymbol;
			graphic.alpha = 0.1;
			graphic.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			renderBackgroundLayer.add(graphic);
			
			function onMouseClick(event:MouseEvent):void
			{
				var layerLevel:uint = _currentLayerLevel - 1;
				
				if(layerLevel >= 0 &&  layerLevel < _layerParamArray.length)
				{
					var layerParam:LevelRenderLayerParam = _layerParamArray[layerLevel] as LevelRenderLayerParam;
					layerParam.searchWhere = "1=1"
					
					layerRendererStart(layerParam, layerLevel);
				}
			}
		}
		
		
		/**
		 * 对面状图形进行渲染 
		 */
		protected function regionRenderer(graphic:Graphic, idField:String, nameField:String, layerUrl:String):void
		{
			graphic.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{onRegionMouseClick(event, graphic)});
			graphic.addEventListener(MouseEvent.MOUSE_MOVE, onRegionMouseMove);
			graphic.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void{onRegionMouseOver(event, graphic, idField, nameField, layerUrl)});
			graphic.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void{onRegionMouseOut(event, graphic)});
			
			graphic.symbol = _layerFillSymbol;
			renderGraLayer.add(graphic);
		}
		
		
		/**
		 * 监听：渲染区域对象的单击事件 
		 */		
		protected function onRegionMouseClick(event:MouseEvent, graphic:Graphic):void
		{
			var layerLevel:uint = _currentLayerLevel + 1;
			
			if(layerLevel >= 0 &&  layerLevel < _layerParamArray.length)
			{
				var layerParam:LevelRenderLayerParam = _layerParamArray[layerLevel] as LevelRenderLayerParam;
				layerParam.searchGeometry = graphic.geometry;
				
				layerRendererStart(layerParam, layerLevel);
			}
		}
		
		
		/**
		 * 监听：渲染区域对象的鼠标移入事件
		 */		
		protected function onRegionMouseOver(event:MouseEvent, graphic:Graphic, idField:String, nameField:String, layerUrl:String):void
		{
			var graphicName:String = graphic.attributes[nameField];
			
			var iContiner:ILevelRenderTooltipContiner = _graphicToolTipCom as ILevelRenderTooltipContiner
			
			iContiner.graphicName = graphicName;
			iContiner.idField = idField;
			iContiner.nameField = nameField;
			iContiner.layerUrl = layerUrl;
			iContiner.layerLevel = _currentLayerLevel;
			iContiner.graphic = graphic;
			
			_graphicToolTipCom.x = event.stageX;
			_graphicToolTipCom.y = event.stageY;
			
			moveTimer.start();
			
			_graphicToolTipCom.visible = true;
			
			graphic.filters = _graphicFilters;
		}
		
		
		/**
		 * 监听：渲染区域对象的鼠标在其上移动的事件
		 */		
		protected function onRegionMouseMove(event:MouseEvent):void
		{
			currentStageX = event.stageX;
			currentStageY = event.stageY;
		}
		
		
		/**
		 * 监听：渲染区域对象的鼠标移出事件
		 */		
		protected function onRegionMouseOut(event:MouseEvent, graphic:Graphic):void
		{
			moveTimer.stop();
			
			_graphicToolTipCom.visible = false;
			
			graphic.filters = null;
		}
		
		
		/**
		 * 监听计时器
		 * 移动提示框 
		 */
		protected function onTimer(event:TimerEvent):void
		{
			var moveEffect:Move = new Move(_graphicToolTipCom);
			moveEffect.xFrom = _graphicToolTipCom.x;
			moveEffect.xTo = currentStageX;
			moveEffect.yFrom = _graphicToolTipCom.y;
			moveEffect.yTo = currentStageY;
			moveEffect.duration = 100;
			moveEffect.play();
		}
		
		
		/**
		 * 在地图上加载信息符号图形 
		 */
		protected function createNameSymbol(graphic:Graphic, idField:String, nameField:String, layerUrl:String):void
		{
			var polygon:Polygon = graphic.geometry as Polygon;
			var regionCenter:MapPoint = polygon.extent.center;
			
			var regionName:String = graphic.attributes[nameField];
			
			//定义文本符号
			//var infoGraphic:Graphic = createInfoGraphic(regionCenter, regionName);
			var layerTextSymbol:TextSymbol = new TextSymbol();
			layerTextSymbol.text = regionName;
			layerTextSymbol.textFormat = new TextFormat();
			layerTextSymbol.textFormat.bold = true;
			layerTextSymbol.textFormat.color = 0xff0000;
			layerTextSymbol.textFormat.size = 16;
			
			//创建地图图形并加载
			var infoGraphic:Graphic = new Graphic();
			infoGraphic.geometry = regionCenter;
			infoGraphic.symbol = layerTextSymbol;
			infoGraphic.attributes = graphic.attributes;
			
			infoGraphic.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
//			infoGraphic.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			renderNameLayer.add(infoGraphic);
			
//			_graphicInfoCom.addEventListener(MouseEvent.ROLL_OUT, onComRollOut);
			
			function onMouseOver(event:MouseEvent):void
			{
				//传参赋值
				var point:Point = map.toScreen(regionCenter);
				_graphicInfoCom.x = point.x - 30;
				_graphicInfoCom.y = point.y - 50;
				_graphicInfoCom.visible = true;
//				_graphicInfoCom.x = event.stageX;
//				_graphicInfoCom.y = event.stageY;
				
				var iContiner:ILevelRenderTooltipContiner = _graphicInfoCom as ILevelRenderTooltipContiner
				iContiner.graphic = graphic;
				iContiner.layerUrl = layerUrl;
				iContiner.graphicName = regionName;
				iContiner.idField = idField;
				iContiner.nameField = nameField;
				iContiner.layerLevel = _currentLayerLevel;
				
				
				
//				appTopWindow.addElement(_graphicInfoCom);
				
//				irisEffect(true);
			}
			
			/*function onComRollOut(event:MouseEvent):void
			{
//				irisEffect(false);
				
				appTopWindow.removeElement(_graphicInfoCom);
			}*/
			
			/*function irisEffect(isShow:Boolean):void
			{
				var iris:Iris = new Iris(_graphicInfoCom);
				iris.duration = 800;
				iris.showTarget = isShow;
//				iris.scaleXFrom = 0;
//				iris.scaleYFrom = 0;
//				iris.scaleXTo = _graphicInfoCom.width;
//				iris.scaleYTo = _graphicInfoCom.height;
//				iris.play();
			}*/
		} 
		
		
		/**
		 * 创建信息符号图形
		 */
		 /*protected function createInfoGraphic(regionCenter:MapPoint, regionName:String):Graphic
		{
			var infoSymbolClass:ClassFactory = new ClassFactory(RadiaInfoSymbol);
			infoSymbolClass.properties = {regionName:regionName};
			infoSymbolClass.properties = {width:204};
			infoSymbolClass.properties = {height:86};
			
			var infoSymbol:InfoSymbol = new InfoSymbol();
			infoSymbol.infoPlacement = InfoPlacement.CENTER;
			infoSymbol.infoRenderer = infoSymbolClass;
			
			var graphic:Graphic = new Graphic();
			graphic.geometry = regionCenter;
			graphic.symbol = infoSymbol;
			
			return graphic;
		}*/ 
		 
		 
		 /**
		  * 显示错误提示窗口
		  */
		 protected function showError(errorString:String):void
		 {
			 MapUni.errorWindow(
				 "名称：地图等级渲染\n" +
				 "功能：实现地图的多层渲染，并可以自由切换\n" + 
				 "错误：" + errorString
				 );
		 }
	}
}