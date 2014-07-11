package com.mapUni.UtilComponent.pageNavigation
{
	import flash.events.Event;

	public class UE_PageNavigationEvent extends Event
	{
		private var _data:Object;
		private var _callback:Function;
		
		public static const PAGE_CHANGE:String = "pageChange";
		public static const Data_CHANGE:String = "dataChange";
		
		public function UE_PageNavigationEvent(type:String, data:Object=null, callback:Function=null)
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