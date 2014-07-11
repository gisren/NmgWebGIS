package widgets.exInterface.StatisticalAnalysis.Control
{
	import flash.events.Event;
	
	public class StatEvent extends Event
	{
		
		public static const STAT_WIDGET_PARAM_GET:String = "statWidgetParamGet";
		
		
		public static const STAT_ITEM_CLICK:String = "statItemClick";
		
		
		public static const STAT_PARAM_SEND:String = "statParamSend";
		
		public static const STAT_PARAM_PROVIDER_SEND:String = "statParamProviderSend";
		
		public static const STAT_PARAM_CITY_SEND:String = "statParamCitySend";
		
		public static const STAT_PARAM_COUNTY_SEND:String = "statParamCountySend";
		
		
		public static const STAT_DATA_WINDOW_CHART:String = "statDataWindowChart";
		
		public static const STAT_DATA_MAP_CHART:String = "statDataMapChart";
		
		public static const STAT_DATA_MAP_RENDERER:String = "statDataMapRenderer";
		
		public static const STAT_DATA_RENDERER_TOOLTIP:String = "statDataRendererTooltip";
		
		
		public static const STAT_WINDOW_CHART_VISIBLE:String = "statWindowChartVisible";
		
		public static const STAT_MAP_VISIBLE:String = "statMapVisible";
		
		public static const STAT_CHART_CLICK:String = "statChartClick";
		
		private var _data:Object;
		private var _callback:Function;
		
		public function StatEvent(type:String, data:Object=null, callback:Function=null)
		{
			super(type, false, false);
			this._data=data;
			this._callback=callback;
		}
		
		public function set data(value:Object):void
		{
			this._data=value;
		}
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set callback(value:Function):void
		{
			this._callback=value;
		}
		
		public function get callback():Function
		{
			return this._callback;
		}
		
		public override function clone():Event
		{
			return new Event(this.type, this.data);
		}
	}
}