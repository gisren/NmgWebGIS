package widgets.exInterface.WidgetsCommon
{
	import flash.events.Event;

	public class WidgetsCommonEvent extends Event
	{
		private static const WIDGET_DATA_LOAD:String = "widgetDataLoad";
		
		/** 模块公用 获取模块中的参数（ConfigXML,configData,Map） */
		public static const WIDGET_PARAM:String = "WidgetParam";
		
		/** 模块公用 模块的配置文件加载完成 */
		public static const WIDGETCOMMON_CONFIG_LOAD:String = "WidgetConfigLoad";
		/**
		 *事件传输的data */		
		private var _data:Object;

		/**
		 * 回调函数 
		 */
		private var _callback:Function;
		
		public function WidgetsCommonEvent(type:String, data:Object=null, callback:Function=null)
		{
			super(type, false, false);
			this._data=data;
			this._callback=callback;
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}
		
		public function get callback():Function
		{
			return _callback;
		}
		
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		
		public override function clone():Event
		{
			return new Event(this.type, this.data);
		}

	}
}