////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	创建图片符号的点信息
//
//	通过对 gis api 中的 使用 PictureMarkerSymbol 的 Graphic 功能进行基本封装实现
//
//  Author：liuXL
//  Date：2012-03-13
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.Graphic
{
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.symbols.PictureMarkerSymbol;

	
	/**
	 *
	 * <p>创建图片符号的点信息</p>
	 * <p>初始化传参，调用 getPointGraphic() 方法得到结果</p>
	 *  
	 * @author LiuXL
	 * 
	 */	
	public class PointGraphic
	{
		
		/**
		 * 最终创建好的点 
		 */		
		private var mapPointGra:Graphic = null;
		
		
		/**
		 *
		 * <p>创建 geometry 为点，symbol 为图片的 Graphic </p>
		 *  
		 * @param x 地图上的x轴坐标
		 * @param y 地图上的y轴坐标
		 * @param picUrl 图片符号的所需图片的相对路径，可选参数
		 * @param attribute 要为点添加的属性信息，可选参数
		 * @param picWidth 图片符号的宽，可选参数
		 * @param picHeight 图片符号的高，可选参数
		 * @param picXoffset 图片符号在x轴的偏移值，可选参数
		 * @param picYoffset 图片符号在y轴的偏移值，可选参数
		 * @param picAngle 图片符号的旋转值，可选参数
		 * @return 对象为点的Graphic
		 * 
		 */		
		public function PointGraphic(X:Number, Y:Number, picUrl:String, attribute:Object, picWidth:Number, picHeight:Number,
											 picXoffset:Number, picYoffset:Number, picAngle:Number):void
		{
			var mapPoint:MapPoint = new MapPoint(X, Y)
			
			var picSym:PictureMarkerSymbol;
				
			if(picUrl)
			{
				picSym = new PictureMarkerSymbol(picUrl);
				
				if(picWidth)
				{
					picSym.width = picWidth;
				}
				if(picHeight)
				{
					picSym.height = picHeight;
				}
				if(picXoffset)
				{
					picSym.xoffset = picXoffset;
				}
				if(picYoffset)
				{
					picSym.yoffset = picYoffset;
				}
				if(picAngle)
				{
					picSym.angle = picAngle;
				}
			}
			
			var pointGra:Graphic = new Graphic(mapPoint);
			
			if(picSym)
			{
				pointGra.symbol = picSym;
			}
			if(attribute)
			{
				pointGra.attributes = attribute;
			}
			
			mapPointGra = pointGra;
		}
		
		
		/**
		 * 
		 * 获取创建完成的图片符号的信息点
		 * 
		 * @return 图片符号信息点
		 * 
		 */		
		public function getPointGraphic():Graphic
		{
			return mapPointGra;
		}
		
		
	}
}