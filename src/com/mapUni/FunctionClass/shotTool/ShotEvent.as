package com.mapUni.FunctionClass.shotTool
{
	import flash.events.Event;

	public class ShotEvent extends Event
	{
		public function ShotEvent(type:String, data:Object=null, callback:Function=null)
		{
			super(type, false, false);
			this._data=data;
			this._callback=callback;
		}
		
		//数据
		private var _data:Object;
		
		//回调函数
		private var _callback:Function;
		
		
		/** 截图完毕 */
		public static const SHOT_COMPLETE:String = "shotComplete";
		
		/** 截图错误 */
		public static const SHOT_ERROR:String = "shotError";
		
		
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