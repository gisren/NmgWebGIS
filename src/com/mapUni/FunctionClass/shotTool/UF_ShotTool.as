
package com.mapUni.FunctionClass.shotTool
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	
	
	/**
	 * 截取完毕
	 */	
	[Event(name="shotComplete", type="com.mapUni.FunctionClass.shotTool.ShotEvent")]
	
	/**
	 * 在截取过程中出错
	 */	
	[Event(name="shotError", type="com.mapUni.FunctionClass.shotTool.ShotEvent")]
	
	
	/**
	 * 
	 * @author LiuXL
	 * 
	 */	
	public class UF_ShotTool extends UF_DrawBox
	{
		public function UF_ShotTool(drawContainer:Container, shotComponent:UIComponent)
		{
			super(drawContainer);
			
			toShotImage = shotComponent;
		}
		
		//被截取UI界面
		private var toShotImage:UIComponent;
		
		//保存文件的方法类
		private var fileReference:FileReference;
		
		//图片数据
		private var imgBD:BitmapData;
		
		//截图结果
		private var _shotResult:ShotResult;
		
		//截图错误
		private var _shotError:Error = new Error();
		
		//输出的图片格式
		private var _imageFormate:String = "PNGEncoder";
		
		
		/** 保存 JPEG 格式图片 */
		public const jpegEnc:String = "JPEGEncoder";
		
		/** 保存 PNG 格式图片 */	
		public const pngEnc:String = "PNGEncoder";
		
		
		
		/**
		 * 
		 * <p>定义输出的图片格式，默认为 PNG 格式</p>  
		 * 
		 */		
		public function set imageFormate(value:String):void
		{
			_imageFormate = value;
		}
		public function get imageFormate():String
		{
			return _imageFormate;
		}
		
		
		/**
		 *
		 * 截图结果
		 * 
		 */		
		public function set shotResult(value:ShotResult):void
		{
			_shotResult = value;
		}
		public function get shotResult():ShotResult
		{
			return _shotResult;
		}
		
		
		/**
		 *
		 * 截图错误 
		 * @return 
		 * 
		 */		
		public function get shotError():Error
		{
			return _shotError;
		}
		
		
		
		/**
		 * 
		 * 覆盖拉框完成后清除拉框图形的方法 
		 * 
		 */		
		protected override function reSeletedBox():void
		{
			container.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			//截取图片
			shotImage();
			
			//保存图片
			saveImage();
			
			//派发事件
			displayShotCompleteEvent();
		}
		
		
		/**
		 * 
		 * 截取图片
		 * 
		*/
		protected function shotImage():void
		{
			try
			{
				if(rect)
				{
					//设置被剪切的图形
					//用bitmapdata全部获取预览图片的像素
					var initBD:BitmapData = new BitmapData(container.width, container.height);
					initBD.draw(toShotImage);
					
					//截取出所选区域的像素集合
					//矩形为要截取区域 
					var bytearray:ByteArray = new ByteArray();
					var re:Rectangle = new Rectangle(rect.x, rect.y, rect.width, rect.height);
					bytearray = initBD.getPixels(re); 
					bytearray.position = 0; 		//必须的，当前的bytearray.position为最大长度，要设为从0开始读取
					
					//将截取出的像素集合存在新的bitmapdata里，大小和截取区域一样
					if(rect.width && rect.height)
					{
						imgBD = new BitmapData(rect.width, rect.height);
						var fillre:Rectangle = new Rectangle(0, 0, rect.width, rect.height);
						imgBD.setPixels(fillre, bytearray); 
						
						_shotResult = new ShotResult();
						_shotResult.shotRect = rect;
						_shotResult.shotBitmapData = imgBD;
					}
				}
			}
			catch(error:Error)
			{
				displayShotErrorEvent(error);	
			}
		}
		
		
		/**
		 * 
		 * 将截图保存在本地  保存格式为png格式
		 * 
		 */		
		protected function saveImage():void
		{
			try
			{
				if(imgBD)
				{
					var bitmap:Bitmap = new Bitmap(imgBD);
					
					var imgshot:ImageSnapshot = new ImageSnapshot();
					
					if(_imageFormate == "PNGEncoder")
					{
						imgshot = ImageSnapshot.captureImage(bitmap, 0, new PNGEncoder());
					}
					else if(_imageFormate == "JPEGEncoder")
					{
						imgshot = ImageSnapshot.captureImage(bitmap, 0, new JPEGEncoder());
					}
					
					_shotResult.shotImage = imgshot.data;
				}
			}
			catch(error:Error)
			{
				displayShotErrorEvent(error);	
			}
				
			
		}
		
		
		/**
		 *
		 * 重新选择截图区域 
		 * 
		 */		
		public function reSelectRect():void
		{
			drawBox(false);
			
			container.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		
		/**
		 * 
		 * 派发截图完成事件 
		 * 
		 */		
		protected function displayShotCompleteEvent():void
		{
			this.dispatchEvent(new ShotEvent(ShotEvent.SHOT_COMPLETE, _shotResult));
		}
		
		
		/**
		 *
		 * 派发截图报错事件 
		 * 
		 */		
		protected function displayShotErrorEvent(error:Error):void
		{
			this.dispatchEvent(new ShotEvent(ShotEvent.SHOT_ERROR, error));
		}
		
		
		
		
		
		
		
		
		
	}
}