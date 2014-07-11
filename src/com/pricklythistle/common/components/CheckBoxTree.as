package com.pricklythistle.common.components
{
	import com.pricklythistle.common.renderers.TreeCheckBoxRenderer;
	
	import mx.core.ClassFactory;
	
	public class CheckBoxTree extends AutoSizeTree
	{
		public var checkField:String = "checked";
		
		public function CheckBoxTree()
		{
			super();
			
			this.itemRenderer = new ClassFactory(TreeCheckBoxRenderer);
			this.rendererIsEditor = true;
		}
		
	}
}