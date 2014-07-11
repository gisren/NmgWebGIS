package widgets.exInterface.EnvPlot
{
	import flash.events.Event;

	public class PlotEvent extends Event
	{
		private var _data:Object;
		private var _callback:Function;

		public static const PLOT_MAP_LOADED:String="plotMapLoaded";
		
		public static const PLOT_SELECTED:String="plotSelected";
		public static const POINT_SELECTED:String="pointSelected";
		public static const TEXT_SELECTED:String="textSelected";
		
		public static const FILL_SYMBOL_CHANGE:String="fillSymbolChange";
		public static const LINE_SYMBOL_CHANGE:String="lineSymbolChange";
		public static const TEXT_SYMBOL_CHANGE:String="textSymbolChange";
		
		public static const CLEAR_ALL_PLOT:String = "clearAllPlot";
		public static const CLEAR_SELECT_PLOT:String = "clearSelectPlot";
		public static const CLEAR_SELECT_POINT:String = "clearSelectPoint";
		public static const CLEAR_SELECT_TEXT:String = "clearSelectText";
		

		public function PlotEvent(type:String, data:Object=null, callback:Function=null)
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