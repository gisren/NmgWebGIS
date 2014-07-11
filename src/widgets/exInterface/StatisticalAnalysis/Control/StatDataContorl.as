package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.ags.Map;
	import com.esri.ags.utils.JSON;
	import com.esri.viewer.ConfigData;
	import com.esri.viewer.ViewerContainer;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import org.osmf.layout.AbsoluteLayoutFacet;

	public class StatDataContorl
	{
		public function StatDataContorl()
		{
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WIDGET_PARAM_GET, "map", onGetMap));
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WIDGET_PARAM_GET, "configXML", onGetConfigXML));
			ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_WIDGET_PARAM_GET, "configData", onGetConfigData));
			
			ViewerContainer.addEventListener(StatEvent.STAT_PARAM_SEND, onStatParamSend);
			ViewerContainer.addEventListener(StatEvent.STAT_PARAM_PROVIDER_SEND, onStatProvider);
			ViewerContainer.addEventListener(StatEvent.STAT_PARAM_CITY_SEND, onStatCity);
			ViewerContainer.addEventListener(StatEvent.STAT_PARAM_COUNTY_SEND, onStatCounty);
			
			init();
		}
		
		
		private var configXML:XML = new XML();
		
		private var configData:ConfigData = new ConfigData();
		
		private var map:Map = new Map();
		
		
		/**
		 * 监听：获取模块配置文件 
		 */		
		private function onGetConfigXML(value:XML):void
		{
			configXML = value;
		}
		
		/**
		 * 监听：获取主配置文件数据
		 */		
		private function onGetConfigData(value:ConfigData):void
		{
			configData = value;
		}
		
		/**
		 * 监听：获取地图   
		 */		
		private function onGetMap(value:Map):void
		{
			map = value;
		}
		
		
		/**
		 * 功能：初始化调取数据 
		 */		
		private function init():void
		{
			
		}
		
		
		/**
		 * 功能: 监听统计参数派发 
		 */		
		private function onStatParamSend(event:StatEvent):void
		{
			var dataObj:Object = event.data;
			
			searchStatData(dataObj, ["", ""], null);
		}
		
		
		/**
		 * 监听: 统计全省 
		 */		
		private function onStatProvider(event:StatEvent):void
		{
			var dataObj:Object = event.data;
			
			var statObj:Object = new Object();
			statObj.id = dataObj.id;
			statObj.label = dataObj.label;
			
			searchStatData(statObj, ["true", ""], "provinceLayer");
		}
		
		
		/**
		 * 监听：统计各市
		 */		
		private function onStatCity(event:StatEvent):void
		{
			var dataObj:Object = event.data;
			
			var statObj:Object = new Object();
			statObj.id = dataObj.id;
			statObj.label = dataObj.label;
			
			searchStatData(statObj, ["", ""], "cityLayer");
		}
		
		
		/**
		 * 监听: 统计市内区县 
		 */		
		private function onStatCounty(event:StatEvent):void
		{
			var dataObj:Object = event.data;
			
			var statObj:Object = new Object();
			statObj.id = dataObj.id;
			statObj.label = dataObj.label;
			
			searchStatData(statObj, ["", dataObj.regionCode], "countyLayer");
		}

		
		/**
		 * 功能:调取统计数据
		 */		
		private function searchStatData(itemObj:Object, serviceParam:Array, regionLayer:String):void
		{
			var serviceXML:XML = configXML.webService[itemObj.id][0];
			
			var serviceLabel:String = serviceXML.@serviceLabel;
			var functionName:String = serviceXML.@functionName;
			var serviceUrl:String = configData.webService[serviceLabel];
			
			MapUni.callWebService(serviceUrl, functionName, serviceParam, onSearchResult, [itemObj, regionLayer]);
		}
		
		
		/**
		 * 监听：调用成功 
		 */		
		private function onSearchResult(event:ResultEvent, token:Array):void
		{
			if(!event.result)
			{
				MapUni.errorWindow("调取数据失败");
			}
			
			try
			{
				var itemObj:Object = token[0];
				var regionLayer:String = token[1];
				
				var statId:String = itemObj.id;
				var statLabel:String = itemObj.label;
				
				var chartData:Array = JSON.decode(event.result.toString());
				
				var chartXML:XML = configXML.statParameter[statId][0];
				
				var windowChartType:String = chartXML.@windowChart.toString();
				var mapChartType:String = chartXML.@mapChart.toString();
				var regionIdField:String = chartXML.@regionIdField.toString();
				var nameField:String = chartXML.@nameField.toString();
				var valueFields:Array =  chartXML.@valueFields.toString().split(",");
				var valueNames:Array = chartXML.@valueNames.toString().split(",");
				var colors:Array = chartXML.@colors.toString().split(",");
				var isLevelLayer:Boolean = chartXML.@isLevelLayer.toString() == "true" ? true : false;
				
				if(!regionLayer)
				{
					regionLayer = chartXML.@regionLayer.toString();
				}
				
				//字段名称键值对表
				var codeNamesHashTable:Hashtable = new Hashtable();
				for(var i:int=0; i<valueFields.length; i++)
				{
					var code:String = valueFields[i];
					var name:String = valueNames[i];
					
					codeNamesHashTable.add(code, name);
				}
				
				var statChartParam:StatChartParam = new StatChartParam();
				statChartParam.statId = statId;
				statChartParam.statTitle = statLabel;
				statChartParam.nameField = nameField;
				statChartParam.dataProvider = chartData;
				statChartParam.valueFields = valueFields;
				statChartParam.codeNameHashtable = codeNamesHashTable;
				statChartParam.colors = colors;
				statChartParam.regionLayer = regionLayer;
				statChartParam.regionIdField = regionIdField;
				statChartParam.isLevelLayer = isLevelLayer;
				
				
				//窗体统计图
				if(windowChartType)
				{
					statChartParam.chartType = windowChartType;
					statChartParam.valueNames = valueNames;
					
					ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_DATA_WINDOW_CHART, statChartParam));
				}
				
				//地图统计图
				if(mapChartType)
				{
					if(mapChartType == "mapRenderer")		//地图区域渲染 
					{
						var colorLevelHashtable:Hashtable = new Hashtable();
						var legendArray:Array = new Array();
						var colorLevelXMLList:XMLList = configXML.colorLevels[statId].colorLevel;
						
						//编辑颜色等级
						for each(var obj:Object in chartData)
						{
							var value:Number = obj[valueFields[0]];
							var regionId:String = obj[regionIdField];
							
							for each(var colorLevel:XML in colorLevelXMLList)
							{
								var minValue:Number = colorLevel.@minValue;
								var maxValue:Number = colorLevel.@maxValue;
								var color:Number = colorLevel.@color;
								
								if(value >= minValue && value < maxValue)
								{
									colorLevelHashtable.add(regionId, color);
								}
							}
						}
						
						//编辑图例项
						for(var n:int=0; n<colorLevelXMLList.length(); n++)
						{
							var legendColorLevel:XML = colorLevelXMLList[n];
							
							var legendMinValue:Number = legendColorLevel.@minValue;
							var legendMaxValue:Number = legendColorLevel.@maxValue;
							var legendColor:Number = legendColorLevel.@color;
							
							var legendObj:Object = new Object();
							legendObj.symbol = legendColor;
							legendObj.label = legendMinValue + " - " + legendMaxValue;
							
							legendArray.push(legendObj);
						}
						
						statChartParam.chartType = mapChartType;
						statChartParam.colorHashtable = colorLevelHashtable;
						statChartParam.legendArray = legendArray;
						
						ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_DATA_MAP_RENDERER, statChartParam));
					}
					else	//地图统计图表
					{
						statChartParam.chartType = mapChartType;
						statChartParam.YAxisMaxNum = getMaxNum(chartData, valueFields);
						
						ViewerContainer.dispatchEvent(new StatEvent(StatEvent.STAT_DATA_MAP_CHART, statChartParam));
					}
				}
			}
			catch(e:Error)
			{
				MapUni.errorWindow("StatDataContorl 方法中，解析调取的图形数据时发生错误");
			}
		}
		
		
		private function getMaxNum(dataProvider:Array, valueFields:Array):Number
		{
			var maxNum:Number = 0;
			
			for each(var dataObject:Object in dataProvider)
			{
				for each(var valueField:String in valueFields)
				{
					var value:Number = dataObject[valueField];
					
					if(maxNum < value)
					{
						maxNum = value;
					}
				}
			}
			
			return maxNum;
		}
	}
}














