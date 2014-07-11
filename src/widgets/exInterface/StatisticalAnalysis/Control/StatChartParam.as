package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.viewer.utils.Hashtable;

	public class StatChartParam
	{
		/** 统计项的id值 */
		public var statId:String;
		
		/** 统计图表类型 */
		public var chartType:String;
		
		/** 统计名称 */
		public var statTitle:String;
		
		/** 统计数据源 */
		public var dataProvider:Array;
		
		/** 数据源中的名称字段 */
		public var nameField:String;
		
		/** 数据源中要统计的字段 */
		public var valueFields:Array;
		
		/** 统计图形位置图层 */
		public var regionLayer:String;
		
		/** 统计图形位置图层中的id字段 */
		public var regionIdField:String;
		
		/** 统计字段对应名称的哈希表 */
		public var codeNameHashtable:Hashtable;
		
		/** 统计图表颜色备选值 */
		public var colors:Array;
		
		/** 统计图表柱状图 折线图y轴的最大值 */
		public var YAxisMaxNum:Number;
		
		/** 是否使用等级渲染 */		
		public var isLevelLayer:Boolean;
		
		
		
		/** 统计值对应颜色的哈希表 图层渲染统计使用 */
		public var colorHashtable:Hashtable;
		
		/** 图例值 图层渲染统计使用 */
		public var legendArray:Array;
		
		
		
		/** 统计列表的标题名称 图表窗体使用 */
		public var valueNames:Array;
		
		
		
		
	}
}