package com.mapUni.FunctionClass.MapLevelRenderer
{
	import com.esri.ags.Graphic;

	public interface ILevelRenderTooltipContiner 
	{
		function set graphicName(value:String):void;
		function get graphicName():String;
		
		function set layerUrl(value:String):void;
		function get layerUrl():String;
		
		function set layerLevel(value:uint):void;
		function get layerLevel():uint;
		
		function set graphic(value:Graphic):void;
		function get graphic():Graphic;
		
		function set nameField(value:String):void;
		function get nameField():String;
		
		function set idField(vaule:String):void;
		function get idField():String;
	}
}