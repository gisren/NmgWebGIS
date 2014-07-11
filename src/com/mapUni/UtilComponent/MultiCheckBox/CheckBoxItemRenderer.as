package com.mapUni.UtilComponent.MultiCheckBox
{	
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.List;
	
	public class CheckBoxItemRenderer extends CheckBox{  
		private var currentData:Object; //保存当前一行值的对象  
		
		public function CheckBoxItemRenderer(){  
			super();  
			this.addEventListener(Event.CHANGE,onClickCheckBox);  
//			this.toolTip = "选择"; 
		}
		
		override public function set data(value:Object):void{  
			//this.selected = value.dgSelected;  
			this.currentData = value; //保存整行的引用  
			this.label=value.label;
			this.currentData.checked=value.checked;
			this.selected=value.checked;
		} 

		
		//点击check box时，根据状况向selectedItems array中添加当前行的引用，或者从array中移除  
		private function onClickCheckBox(e:Event):void{
			var listTemp:List=List(listData.owner);
			
			//listTemp.collection
			var cbir:CheckBoxItemRenderer=CheckBoxItemRenderer(e.currentTarget);
			//cbir.selected;
			this.currentData.checked=cbir.selected;
		}  
	}  

}