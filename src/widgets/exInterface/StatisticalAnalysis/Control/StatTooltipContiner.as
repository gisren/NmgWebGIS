package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.mapUni.BaseClass.MapUni;
	import com.mapUni.FunctionClass.MapLevelRenderer.ILevelRenderTooltipContiner;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Group;
	
	public class StatTooltipContiner extends Group implements ILevelRenderTooltipContiner
	{
		public function StatTooltipContiner()
		{
			super();
		}
		
		private var  _graphicName:String = "";
		
		private var _layerUrl:String = "";
		
		private var _layerLevel:uint;
		
		private var  _graphic:Graphic = new Graphic();
		
		private var  _nameField:String = "";
		
		private var  _idField:String = "";
		
		private var _configXML:XML = new XML();
		
		private var _map:Map = new Map();
		
		private var _regionRadiaAC:ArrayCollection = new ArrayCollection();
		
		
		[Bindable]
		public function set graphicName(value:String):void
		{
			_graphicName = value;
		}
		public function get graphicName():String
		{
			return _graphicName;
		}
		
		public function set layerUrl(value:String):void
		{
			_layerUrl = value;
			
//			searchRadiaByMap();
		}
		public function get layerUrl():String
		{
			return _layerUrl;
		}
		
		public function set layerLevel(value:uint):void
		{
			_layerLevel = value;
		}
		public function get layerLevel():uint
		{
			return _layerLevel;
		}
		
		public function set graphic(value:Graphic):void
		{
			_graphic = value;
			
		}
		public function get graphic():Graphic
		{
			return _graphic;
		}
		
		public function set nameField(value:String):void
		{
			_nameField = value;
		}
		public function get nameField():String
		{
			return _nameField;
		}
		
		public function set idField(value:String):void
		{
			_idField = value;
		}
		public function get idField():String
		{
			return _idField;
		}
		
		
		public function set configXML(value:XML):void
		{
			_configXML = value;
		}
		public function get configXML():XML
		{
			return 	_configXML;
		}
		
		public function set map(value:Map):void
		{
			_map = value;
		}
		public function get map():Map
		{
			return _map;
		}
		
		
		
	}
}


























