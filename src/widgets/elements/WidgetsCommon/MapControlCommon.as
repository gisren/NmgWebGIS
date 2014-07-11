package widgets.exInterface.WidgetsCommon
{
	import com.esri.ags.Map;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.viewer.AppEvent;
	import com.esri.viewer.ConfigData;
	import com.esri.viewer.ViewerContainer;
	
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import widgets.professionalWork.EnvSpecial.Control.SpecialMapLayers;
	import widgets.professionalWork.PolluteSources.Control.PolluteMapLayers;
	import widgets.professionalWork.Radiation.Control.RadiationMapLayers;
	import widgets.professionalWork.WaterQuality.Control.WaterQualityMapLayers;
	
	
	
	public class MapControlCommon
	{
		private static var map:Map;
		private var widgetMethComm:WidgetsMethodCommon;
		public function MapControlCommon()
		{
			ViewerContainer.addEventListener(AppEvent.MAP_LOADED, onMapLoad);//获得MAP的对象
//			ViewerContainer.addEventListener(AppEvent.CLEAR_MAP,onClearMap);
			widgetMethComm = WidgetsMethodCommon.getinstance();//初始化WidgetsMethodCommon,以便获得公共方法
			//			SubmitData();
		}
		
		public function SubmitData():void
		{     
			var request:HTTPService = new HTTPService();
			request.url ='http://218.60.147.56/raeadmin/Ajax/maindatalink.aspx?data={"Func":6, "Type":1, "Data":"coffee!coffee!70810003,70810002"}';
			request.useProxy = false;
			request.resultFormat = "e4x";
			request.method= "POST";
			request.contentType = "application/octet-stream";
			request.addEventListener(ResultEvent.RESULT, configResult);
			request.addEventListener(FaultEvent.FAULT, configFault);
			request.send();
		} 
		private function configResult(event:ResultEvent):void
		{
			Alert.show(event.toString());
			Alert.show("11","提示");
		}
		private function configFault(event:mx.rpc.events.FaultEvent):void
		{
			Alert.show("获取信息失败","提示");
		}  
		
		private var _SpecialMapLayer:SpecialMapLayers=SpecialMapLayers.getinstance();
		private var _polluteMapLayer:PolluteMapLayers =  PolluteMapLayers.getinstance();
		private var _waterQualityMapLayer:WaterQualityMapLayers = WaterQualityMapLayers.getinstance();
		
		public function get waterQualityMapLayer():WaterQualityMapLayers
		{
			return _waterQualityMapLayer;
		}
		
		public function set waterQualityMapLayer(value:WaterQualityMapLayers):void
		{
			_waterQualityMapLayer = value;
		}
		
		
		public function get polluteMapLayer():PolluteMapLayers
		{
			return _polluteMapLayer;
		}
		
		public function set polluteMapLayer(value:PolluteMapLayers):void
		{
			_polluteMapLayer = value;
		}
		
		
		private var _RadiationMapLayer:RadiationMapLayers =  RadiationMapLayers.getinstance();
		
		public function get RadiationMapLayer():RadiationMapLayers
		{
			return _RadiationMapLayer;
		}
		
		public function set RadiationMapLayer(value:RadiationMapLayers):void
		{
			_RadiationMapLayer = value;
		}
		
		
		
		public function get SpecialMaplayer():SpecialMapLayers
		{
			return _SpecialMapLayer;
		}
		
		public function set SpecialMapLayer(value:SpecialMapLayers):void
		{
			_SpecialMapLayer = value;
		}
 
		
		/**获得map*/
		private function onMapLoad(event:AppEvent):void
		{
			map = event.data as Map;
		}
		
		/**
		 * 按照模块的图层类添加操作图层
		 * @param layerClassName 模块中的图层类
		 * 例如：PolluteMapLayers类
		 */
		public static function AddOperationsLayer(layerClassName:*):void
		{
			/**添加污染源模块的graphicslayer*/
			for each(var obj:Object in getClassProperty(layerClassName))
			{
				var gralayer:GraphicsLayer = obj["layer"] as GraphicsLayer;
				map.addLayer(gralayer);
			}
		}
		/**
		 * 
		 * @param layerClassName 模块中的图层类
		 * @param layerVisible 图层可见性
		 * 
		 */		
		public static function changeLayerVisible(layerClassName:*, layerVisible:Boolean):void
		{
			/**添加污染源模块的graphicslayer*/
			for each(var obj:Object in getClassProperty(layerClassName))
			{
				var gralayer:GraphicsLayer = obj["layer"] as GraphicsLayer;
				if(gralayer)
				{
					gralayer.visible = layerVisible;
				}
			}
		}
		
		
		/**
		 *功能：通过类反射获得类的相关属性，方法等 
		 * 
		 */
		private static function getClassProperty(className:*):ArrayCollection
		{
			var AC:ArrayCollection = new ArrayCollection();
			var properties:XML = describeType(className);
			for each(var propertyInfo:XML in properties)
			{
				var propertyVariable:XMLList = propertyInfo.variable;//获取变量
				for each(var propertyVari:XML in propertyVariable)
				{
					var propertyType:String = propertyVari.@type;
					var orderObj:Object = new Object();
					for each(var agsxml:XML in propertyVari..arg)
					{
						if(agsxml.@key == "pos")
						{
							orderObj["pos"]= agsxml.@value;
							break;
						}
					}
					if(propertyType.match("GraphicsLayer"))
					{
						var propertyName:String = propertyVari.@name;
						if(className.hasOwnProperty(propertyName))
						{
							var gralayer:GraphicsLayer = className[propertyName];
							orderObj["layer"] = gralayer;
							AC.addItem(orderObj);
						}
					}
				}
			}
			AC=WidgetsMethodCommon.orderByData(AC,"pos");
			return AC;
		}
		
		/**
		 * 按照模块的图层类进行——不显示
		 * @param LayerClassName graphicsLayer图层类名
		 * 
		 */
		public static  function HideOperationLayer(LayerClassName:*):void
		{
			/** 隐藏制定图层类的graphicslayer*/
			for each(var obj:Object in getClassProperty(LayerClassName))
			{
				var gralayer:GraphicsLayer = obj["layer"] as GraphicsLayer;
				gralayer.visible =false;
			}
		}
		/**
		 * 按照模块的图层类进行——显示
		 * @param LayerClassName graphicsLayer图层类名
		 * 
		 */
		public static function ShowOperationLayer(LayerClassName:*):void
		{
			/** 显示制定图层类的graphicslayer*/
			for each(var obj:Object in getClassProperty(LayerClassName))
			{
				var gralayer:GraphicsLayer = obj["layer"] as GraphicsLayer;
				gralayer.visible =true;
			}
		}
		
		/**
		 *按照模块中的图层类进行清除操作 
		 * @param LayerClassName 模块图层类
		 * 例如：PolluteMapLayers类
		 */
		public static function ClearOperLayer(LayerClassName:*):void
		{
			switch(LayerClassName)
			{
				/**污染源模块图层类*/
				case PolluteMapLayers.getinstance():
				{
					/**清除污染源模块常使用的graphicslayer*/
					for each(var obj:Object in getClassProperty(LayerClassName))
					{
						var gralayer:GraphicsLayer = obj["layer"] as GraphicsLayer;
						if(gralayer.id=="summaryLayer")
						{
							//					gralayer.visible = false;
							continue;
						}
						else
						{
							gralayer.clear();
						}
						
					}
					break;
				}
				case WaterQualityMapLayers.getinstance():
				{
					
				}
				default:
				{
					break;
				}
			}
			
		}
		
		/**
		 *侦听地图清除按钮的派发事件 （此方法可以清除所有的map中的GraphicLayer）
		 * @param event
		 * 
		 */		
		private function onClearMap(event:AppEvent):void
		{
			/**第二种清除方式*/
			for each(var obj:Object in map.layers)
			{
				if(obj is GraphicsLayer)
				{
					var gralayers:GraphicsLayer = obj as GraphicsLayer;
					gralayers.visible = false;
				}
			}
		}
		public function ClearSearchLayer():void
		{
			//			/**清除污染源模块的graphicslayer*/
			/**第二种清除方式*/
			for each(var obj:Object in widgetMethComm.map.layers)
			{
				if(obj is GraphicsLayer)
				{
					var gralayers:GraphicsLayer = obj as GraphicsLayer;
					if(gralayers.id=="searchLayer")
					{
						//						gralayers.visible = false;
						gralayers.clear();
					}
					if(gralayers.id=="summaryLayer")
					{
						gralayers.visible = true;
					}
					else
					{
						gralayers.clear();
					}
					//					(obj as GraphicsLayer).clear();
				}
			}
		}
	}
}