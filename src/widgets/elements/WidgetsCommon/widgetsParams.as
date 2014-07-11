package widgets.exInterface.WidgetsCommon
{
	import com.esri.ags.Map;
	import com.esri.viewer.ConfigData;
	
	import widgets.professionalWork.EnvSpecial.Components.DataSets.SpecialDataSetsFactory;
	import widgets.professionalWork.PolluteSources.DataSets.PolluteDataSetsFactory;
	import widgets.professionalWork.Radiation.DataSets.RadiationDataSetsFactory;
	import widgets.professionalWork.WaterQuality.DataSets.WaterDataSetsFactory;

	public class widgetsParams
	{
		private var widgetsCommonMeth:WidgetsMethodCommon;

		private var _polluteDataSet:PolluteDataSetsFactory;
		private var _RadiationDataSet:RadiationDataSetsFactory;
		private var _SpecialDataSet:SpecialDataSetsFactory;
		private var _WaterDataSet:WaterDataSetsFactory;
		
		public function widgetsParams(enforcer:SingletonEnforcer)
		{
			widgetsCommonMeth=WidgetsMethodCommon.getinstance();
		}
		
		private static var _instance:widgetsParams;
		
		public static function getinstance():widgetsParams
		{
			if(_instance==null)
			{
				_instance = new widgetsParams(new SingletonEnforcer())
			}
			return _instance;
		}
		/**
		 *污染源模块参数集 
		 */	
		[Bindable]
		public function get polluteDataSet():PolluteDataSetsFactory
		{
			return _polluteDataSet;
		}

		public function set polluteDataSet(value:PolluteDataSetsFactory):void
		{
			_polluteDataSet = value;
			widgetsCommonMeth.widgetParam = this;//传递widgetParam
			widgetsCommonMeth.configData = polluteDataSet.configData;
//			widgetsCommonMeth.configXML = polluteDataSet.configXML;//不需要在此传递该参数，因为各个模块的configXML文件不一样
			widgetsCommonMeth.map = polluteDataSet.map;
		}

		[Bindable]
		public function get RadiationDataSet():RadiationDataSetsFactory
		{
			return _RadiationDataSet;
		}
		
		public function set  RadiationDataSet(value:RadiationDataSetsFactory):void
		{
			_RadiationDataSet = value;
			widgetsCommonMeth.widgetParam = this;//传递widgetParam
			widgetsCommonMeth.configData = RadiationDataSet.configData;
			//			widgetsCommonMeth.configXML = polluteDataSet.configXML;//不需要在此传递该参数，因为各个模块的configXML文件不一样
			widgetsCommonMeth.map = RadiationDataSet.map;
		}
		
		[Bindable]
		public function get SpecialDataSet():SpecialDataSetsFactory
		{
			return _SpecialDataSet;
		}
		
		public function set  SpecialDataSet(value:SpecialDataSetsFactory):void
		{
			_SpecialDataSet = value;
			widgetsCommonMeth.widgetParam = this;//传递widgetParam
			widgetsCommonMeth.configData = SpecialDataSet.configData;
			//			widgetsCommonMeth.configXML = polluteDataSet.configXML;//不需要在此传递该参数，因为各个模块的configXML文件不一样
			widgetsCommonMeth.map = SpecialDataSet.map;
		}
		
		
		[Bindable]
		public function get WaterDataSet():WaterDataSetsFactory
		{
			return _WaterDataSet;
		}
		
		public function set  WaterDataSet(value:WaterDataSetsFactory):void
		{
			_WaterDataSet = value;
			widgetsCommonMeth.widgetParam = this;//传递widgetParam
			widgetsCommonMeth.configData = WaterDataSet.configData;
			//			widgetsCommonMeth.configXML = polluteDataSet.configXML;//不需要在此传递该参数，因为各个模块的configXML文件不一样
			widgetsCommonMeth.map = WaterDataSet.map;
		}
	}
}
class SingletonEnforcer
{
	public function SingletonEnforcer()
	{
		
	}
}