package widgets.elements.Legend
{
	public class LegendParam
	{
		/** 增加图例 */
		public static const ADD:String = "add";
		
		/** 删除图例 */
		public static const DELETE:String = "delete";
		
		/** 清空图例 */
		public static const CLEAR:String = "clear";
		
		/** 
		 * 图例操作符号
		 * 有"add"和"delete"
		 * 可由LegendParam的静态常量中获得 
		 */
		public var operate:String;
		
		/** 一组图例的名称 */
		public var legendName:String;
		
		/** 要获取图例的图层对象 */
		public var layerName:String;
		
		/** 图例符号 */
		public var legendSymbol:Array;
		
		/** 图例标签 */
		public var legendLabel:Array;
	}
}