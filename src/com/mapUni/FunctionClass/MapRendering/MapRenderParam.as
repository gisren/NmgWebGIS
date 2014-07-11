package com.mapUni.FunctionClass.MapRendering
{
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	
	import flash.text.TextFormat;

	public class MapRenderParam
	{
		/** 查询图层的地址 */
		public var qLayerUrl:String;
		
		/** 图形查询条件 */
		public var qGeometry:Geometry;
		
		/** 属性查询条件 */
		public var qWhere:String;
		
		/**
		 * <p>要渲染的几何图形<p/>
		 *  如果设置了此属性，就是直接给予了要进行渲染的图形，
		 *  则 layerUrl、qGeometry、qWhere 组成的对几何图形查询将不再有意义，
		 */		
		public var geometry:String;
		
		/** 渲染对象显示名称 */
		public var graphName:String;
		
		/** 鼠标提示 */
		public var toolTip:String;
		
		/** 区域填充符号 */
		public var fillSymbol:SimpleFillSymbol;
		
		/** 线状符号 */
		public var lineSymbol:SimpleLineSymbol;
		
		/** extentName属性的字体样式 */
		public var textFormat:TextFormat;
	}
}