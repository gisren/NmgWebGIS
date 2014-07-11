package com.mapUni.BaseClass.RiverRenderer
{
	import com.esri.ags.geometry.Geometry;

	public class RiverRendererParam
	{
		public var layerUrl:String;
		
		public var layerNameField:String;
		
		public var layerCodeField:String;
		
		public var queryGeometry:Geometry;
		
		public var queryWhere:String = "1=1";
	}
}