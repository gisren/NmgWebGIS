package com.pricklythistle.common.renderers
{
	
	import com.pricklythistle.common.components.CheckBoxTree;
	import com.pricklythistle.common.components.MixedCheckBox;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Tree;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	
	public class TreeCheckBoxRenderer extends TreeItemRenderer
	{
		protected var checkbox:MixedCheckBox;
	
		override protected function createChildren():void
		{	
			super.createChildren();
			
			if (!checkbox)
			{
				checkbox = new MixedCheckBox();
				checkbox.styleName = this;
				checkbox.addEventListener(MouseEvent.CLICK,onCheckBoxClick);
				addChild(checkbox);
			}
		}
		
		private function onCheckBoxClick(e:Event):void
		{
			var checkBox:MixedCheckBox = e.currentTarget as MixedCheckBox;
			if(data != null)
				data[CheckBoxTree(owner).checkField] = checkBox.value;
			
			if (data.hasOwnProperty("children") && data.children.length > 0)
			{
				updateChildrenChecked(data.children,checkBox.value);
			} else if (data is XML && data.children().length() > 0) {
				updateChildrenChecked(data.children(),checkBox.value);
			}
			
			//find out if all parents children are checked
			var itemParent:Object = CheckBoxTree(owner).getParentItem(data);
			if(itemParent != null)
				updateParentChecked(itemParent,checkBox.value);
			
			//invalidateDisplayList();
			Tree(owner).invalidateList();
		}
		
		private function updateParentChecked(parent:Object,isChecked:int):void
		{
			var allChecked:Boolean = true;
			var noneChecked:Boolean = true;
			
			var siblings:Object;
			if(parent is XML)
			{
				siblings = parent.children();
			} else {
				siblings = parent.children;
			} 
			
			for each (var currentSibling:Object in siblings)
			{
				if(currentSibling[CheckBoxTree(owner).checkField] != 1)
				{
					allChecked = false;
				} 
				if (currentSibling[CheckBoxTree(owner).checkField] != 0) {
					noneChecked = false;
				}
			}
			
			var checkValue:int;
			if(allChecked)
			{
				checkValue = 1;
			} else if (noneChecked)
			{
				checkValue = 0;
			} else {
				checkValue = 2;
			}
			
			parent[CheckBoxTree(owner).checkField] = checkValue;
			
			var itemParent:Object = CheckBoxTree(owner).getParentItem(parent);
			if(itemParent != null)
				updateParentChecked(itemParent,isChecked);
		}
		
		private function updateChildrenChecked(children:Object,isChecked:int):void
		{
			//loop through children and copy value
			for each (var currentChild:Object in children)
			{
				currentChild[CheckBoxTree(owner).checkField] = isChecked;
				
				if (currentChild.hasOwnProperty("children") && currentChild.children.length > 0)
				{
					updateChildrenChecked(currentChild.children,isChecked);
				} else if (currentChild is XML && currentChild.children().length() > 0) {
					updateChildrenChecked(currentChild.children(),isChecked);
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			checkbox.x = label.x + 2;
			checkbox.y = label.y + 10 ;
			label.x = checkbox.x + 15;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(data != null && data.hasOwnProperty(CheckBoxTree(owner).checkField))
			{
				checkbox.value = data[CheckBoxTree(owner).checkField];
			} else {
				checkbox.value = 0;
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			measuredWidth += 17;
		}
	}
}