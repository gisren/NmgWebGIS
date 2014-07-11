package com.mapUni.UtilComponent.Charts
{
	import flash.events.Event;

	public class UE_ChartEvent extends Event
	{
		public function UE_ChartEvent(type:String, data:Object=null, callback:Function=null)
		{
			super(type, false, false);
			this._data=data;
			this._callback=callback;
		}
		
		
		/** 截图完毕 */
		public static const CHART_ITEM_CLICK:String = "chartItemClick";
		
		
		//数据
		private var _data:Object;
		
		//回调函数
		private var _callback:Function;
		
		
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