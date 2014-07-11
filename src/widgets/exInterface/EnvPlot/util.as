package widgets.exInterface.EnvPlot
{
	public class util
	{
		
		public static function toPictureCurrentScreen():void{			
			var rect:Rectangle=screen;			
			
			//用bitmapdata全部获取预览图片的像素
			var initBD:BitmapData = new BitmapData(screen.width, screen.height);
			initBD.draw(map);
			
			//截取出所选区域的像素集合
			//矩形为要截取区域 
			var bytearray:ByteArray = new ByteArray();
			var re:Rectangle = new Rectangle(rect.x, rect.y, rect.width, rect.height);
			bytearray = initBD.getPixels(re); 
			bytearray.position = 0; 		//必须的，当前的bytearray.position为最大长度，要设为从0开始读取
			
			//将截取出的像素集合存在新的bitmapdata里，大小和截取区域一样
			if(rect.width && rect.height)
			{
				var imgBD:BitmapData;
				imgBD = new BitmapData(rect.width, rect.height);
				var fillre:Rectangle = new Rectangle(0, 0, rect.width, rect.height);
				imgBD.setPixels(fillre, bytearray); 
				
				if(imgBD)
				{
					var bitmap:Bitmap = new Bitmap(imgBD);
					
					var imgshot:ImageSnapshot = new ImageSnapshot();
					var _imageFormate:String = "PNGEncoder";
					if(_imageFormate == "PNGEncoder")
					{
						imgshot = ImageSnapshot.captureImage(bitmap, 0, new PNGEncoder());
					}
					else if(_imageFormate == "JPEGEncoder")
					{
						imgshot = ImageSnapshot.captureImage(bitmap, 0, new JPEGEncoder());
					}
					
					fileReference.save(imgshot.data, "未命名.png");
				}
				
			}
		}
	
	
	
	}
}