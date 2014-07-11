package widgets.exInterface.WidgetsCommon
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.viewer.BaseWidget;
	import com.esri.viewer.ConfigData;
	import com.esri.viewer.ViewerContainer;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.filters.GlowFilter;
	
	import widgets.professionalWork.PolluteSources.Control.PolluteCommonMethod;
	import widgets.professionalWork.PolluteSources.DataSets.PolluteDataSetsFactory;
	import widgets.professionalWork.PolluteSources.DataSets.SummaryDataSet;
	
	/**
	 * 模块数据加载完毕 
	 */	
	[WidgetsCommonEvent(name="widgetDataLoad", type="widgets.exInterface.WidgetsCommon.WidgetsCommonEvent")]
	public class WidgetsMethodCommon
	{
		//		private var pollCommMeth:PolluteCommonMethod;
		/**
		 *模块参数集 
		 */
		private var _widgetParam:widgetsParams;
		
		private var _configData:ConfigData;
		
		/**
		 * 地图 
		 */
		private var _map:Map;
		
		/**
		 * 系统配置文件数据 
		 */
		public function get configData():ConfigData
		{
			return _configData;
		}
		
		public function set configData(value:ConfigData):void
		{
			_configData = value;
			//			pollCommMeth.widgetMethComm =this;//给polluteMeth传递参数
		}
		
		/**
		 *回调函数 
		 */
		private var _callback:Function;
		
		[Bindable]
		public function get widgetParam():widgetsParams
		{
			return _widgetParam;
		}
		
		public function set widgetParam(value:widgetsParams):void
		{
			_widgetParam = value;
			//			pollCommMeth.widgetMethComm =this;//给polluteMeth传递参数
		}
		
		public function get map():Map
		{
			return _map;
		}
		
		public function set map(value:Map):void
		{
			_map = value;
			//			pollCommMeth.widgetMethComm =this;//给polluteMeth传递参数
		}
		
		public function get callback():Function
		{
			return _callback;
		}
		
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		
		private static var _instance:WidgetsMethodCommon;
		
		public static function getinstance():WidgetsMethodCommon
		{
			if(_instance==null)
			{
				_instance = new WidgetsMethodCommon(new SingletonEnforcer())
			}
			return _instance;
		}
		/**
		 * 构造函数，初始化
		 * 
		 */		
		public function WidgetsMethodCommon(enforcer:SingletonEnforcer)
		{
			//			pollCommMeth = new PolluteCommonMethod();
		}
		
		/**
		 * 
		 * 调取WebService数据
		 * 
		 * <br/><br/>
		 * @param serviceConfigName 配置 WebService 的标识 
		 * @param httpFuncParam webService方法参数
		 * @param onResultFunction 回调函数
		 * 
		 */		
		//		protected function callWebServiceData(serviceConfigName:String, httpFuncParam:Array, onResultFunction:Function, resultParam:Object=null):void
		//		{
		//			var serviceLabel:String = configXML.webService[serviceConfigName].@serviceLabel;
		//			var funcName:String = configXML.webService[serviceConfigName].@functionName;
		//			var serviceUrl:String = configData.webService[serviceLabel];
		//			
		//			MapUni.callWebService(serviceUrl, funcName, httpFuncParam, onResultFunction, resultParam);
		//		}
		//		
		/**
		 * 功能：获取图层地址
		 */		
		public  function getLayerUrl(mapLabel:String, layerName:String):String
		{
			var mapLayer:Layer = map.getLayer(mapLabel);
			var layerUrl:String = MapUni.layerUrl(mapLayer, layerName);
			
			return layerUrl;
		}
		
		/**
		 * 功能：获取图层配置信息 
		 * configXML:xml文件
		 * layerId:configXML里面的图层id或名称
		 */		
		public static function getLayerParam(configXML:XML,layerId:String):XML
		{
			var layerList:XMLList = configXML.layers.layer;
			
			for (var i:int=0; i<layerList.length(); i++)
			{
				if(layerList[i].@id == layerId)
				{
					return layerList[i];
				}
			}
			return null;
		}
		/**
		 * 功能：区域带有滤镜的图形
		 */
		public static function getRegionGraphic(regionGeometry:Geometry):Graphic
		{
			//内发光滤镜
			var glowFilter:spark.filters.GlowFilter = new spark.filters.GlowFilter();
			glowFilter.color = 0xff0000;
			glowFilter.blurX = 30;
			glowFilter.blurY = 30;
			glowFilter.inner = true;
			glowFilter.knockout = true;
			glowFilter.alpha = 0.5;
			
			var regionSymbol:SimpleFillSymbol = new SimpleFillSymbol("solid", 0, 1);
			var regionGra:Graphic = new Graphic(regionGeometry, regionSymbol);
			regionGra.filters = [glowFilter];
			
			return regionGra;
		}
		/**
		 * 功能: 对数据进行排序
		 * 
		 * @param objAC 要进行排序的数据, object格式的数组集合
		 * @param orderField 排序依据字段
		 * @param orderRule 排序规则 0为从小到大(默认), 1为从大到小
		 * 
		 * @return 排序后的objAC
		 */		
		public static function orderByData(objAC:ArrayCollection, orderField:String, orderRule:uint=0):ArrayCollection
		{
			for(var i:int=0; i<objAC.length; i++)
			{
				for(var n:int=i; n<objAC.length; n++)
				{
					if(orderRule == 0)
					{
						
						if(objAC[i][orderField] > objAC[n][orderField])
						{
							var tObj:Object = objAC[i];
							objAC[i] = objAC[n];
							objAC[n] = tObj;
						}
					}
					else if(orderRule == 1)
					{
						if(objAC[i][orderField] < objAC[n][orderField])
						{
							var eObj:Object = objAC[i];
							objAC[i] = objAC[n];
							objAC[n] = eObj;
						}
					}
				}
			}
			return objAC;
		}

		
		public static function orderByNumber(obj:ArrayCollection, ordField:String, orderBy:uint=0):ArrayCollection
		{
			for(var i:int=0; i<obj.length; i++)
			{
			    if(obj[i][ordField]=="")
				{
					obj.removeItemAt(i);
				}
			}
			
			for(var i:int=0; i<obj.length; i++)
			{
				for(var n:int=i; n<obj.length; n++)
				{
				 
					
						if(orderBy == 0)
						{ 
							 if(ReObjNumber(obj[i][ordField]) > ReObjNumber(obj[n][ordField]))
							{
								var tObj:Object = obj[i];
								obj[i] = obj[n];
								obj[n] = tObj;
								
							}
						}
						else if(orderBy == 1)
						{
							if(ReObjNumber(obj[i][ordField]) < ReObjNumber(obj[n][ordField]))
							{
								var eObj:Object = obj[i];
								obj[i] = obj[n];
								obj[n] = eObj;
							}
						}
						 
					 
						
				}
			}
			return obj;
		}
	  
	 public static  function ReObjNumber(obj):Number
	 {
		     var objSplit:Array= obj.split("-");
		     var idx:Number=objSplit[(objSplit.length-1)];
	//		 var last:Number= obj.toString().length;
	//		 var str=obj.substring(idx,last);
		 
		 return idx;
	 }
		
    }
}
class SingletonEnforcer
{
	public function SingletonEnforcer()
	{
		
	}
}