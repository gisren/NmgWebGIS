package com.mapUni.FunctionClass.MapLevelRenderer
{
	import com.esri.ags.geometry.Geometry;

	public class LevelRenderLayerParam
	{
		/** 编号 */
		public var id:String;
		
		/** 图层地址(必填) */
		public var layerUrl:String;
		
		/** 属性查询条件 */
		public var searchWhere:String;
		
		/** 几何查询的图形 */
		public var searchGeometry:Geometry;
		
		/** 图层中的名称字段 */		
		public var layerNameField:String;
		
		/** 图层中的编号字段 */
		public var layerIdField:String;
	}
}