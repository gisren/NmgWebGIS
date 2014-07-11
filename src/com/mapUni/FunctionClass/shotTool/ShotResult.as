package com.mapUni.FunctionClass.shotTool
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class ShotResult
	{
		/** 截图区域 */
		public var shotRect:Rectangle;
		
		/** 截取到的带图片格式的二进制数据 */
		public var shotImage:ByteArray;
		
		/** 截取到的未带图片格式的图片数据 */
		public var shotBitmapData:BitmapData;
		
	}
}