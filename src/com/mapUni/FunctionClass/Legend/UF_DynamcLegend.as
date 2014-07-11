////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	动态图例显示组件。
//
//	此组件用来动态显示图例,当只传入图层名称时程序向后台调取此图层的图例；当没有传入图层
//	名称，只传入图例符号和图例说明时程序将直接根据参数创建图例；当既传入图层名又传入图
//	例符号和说明时，或着是图例或说明中的一项时，程序将会用传入的符号或说明去替换调取来的
//	图层图例中的对应项。
//
//  Author：liuXL
//  Date：2012-01-16
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.FunctionClass.Legend
{
	import com.esri.ags.Map;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.LayerLegendInfo;
	import com.esri.ags.layers.supportClasses.LegendItemInfo;
	import com.esri.ags.symbols.PictureFillSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.viewer.utils.Hashtable;
	import com.mapUni.BaseClass.MapUni;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.effects.AddItemAction;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	import mx.events.ResizeEvent;
	import mx.rpc.AsyncResponder;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.effects.Fade;
	import spark.effects.Resize;

	
	/**
	 * 当图例的数量改变时派发，可通过 V_NumLegendItem 属性获取最新显示图例的个数
	 */	
	[Event(name="E_legendNumChange", type="flash.events.Event")]
	
	
	/**
	 * 
	 * <p>
	 * <b>名称：</b>
	 * 动态图例
	 * </p>
	 * <p>
	 * <b>功能：</b>
	 * 实现图例的动态显示。
	 * 可根据图层名称获取对应的图层图例，还可对调取来的图例符号和名称进行修改。
	 * 也可以不去后台调取图层，直接传入图例符号和名称加载图例。
	 * </p>
	 * <p>
	 * <b>方法：</b><br/>
	 * &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * <b>legendControl</b> 图例控制，用来添加、移除图例
	 * </p>
	 * <p>
	 * <b>参数:</b>
	 * <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * <b>V_map</b> 基础地图 当需要根据图层的图例时的必须参数。
	 * <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * <b>V_LegItemGap</b> 单个图例中符号和名称的间隙
	 * <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * <b>V_legItemHeight</b> 单个图例的高度
	 * <br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * <b>V_legGroupGap</b> 单个图例间的间隙
	 * </p>
	 * 
	 * 
	 */	
	public class UF_DynamcLegend extends Group
	{
		
		/**
		 *
		 * 初始化 
		 * 
		 */		
		public function UF_DynamcLegend()
		{
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			legendTopGroup.percentHeight = 100;
//			legendTopGroup.percentWidth = 100;
			legendTopGroup.gap = 20;
			
			var scroller:Scroller = new Scroller();
			scroller.percentHeight = 100;
			scroller.percentWidth = 100;
			
			scroller.viewport=legendTopGroup;
			
			this.addElement(scroller);
		}
		
		
		/**
		 * 地图
		 */
		public var V_map:Map = new Map();
		
		
		/**
		 * 当前显示图例的个数
		 */		
		public var V_NumLegendItem:Number = 0;
		
		
		/**
		 * 单个图例中符号和名称的间隙
		 */
		public var V_LegItemGap:Number = 10;
		/**
		 * 单个图例的高度
		 */	
		public var V_legItemHeight:Number = 20;
		/**
		 * 单个图例间的间隙
		 */		
		public var V_legGroupGap:Number = 10;
		
		/**
		 * 图例内容的高度
		 */		
		public function get legendHeight():Number
		{
			var legendGroupHeight:Number = 0;
			
			for(var i:int=0; i<legendTopGroup.numElements; i++)
			{
				var legendItem:VGroup = legendTopGroup.getElementAt(i) as VGroup;
				
				legendGroupHeight += legendItem.height;
				
				legendGroupHeight += legendTopGroup.gap;
			}
			
			return legendGroupHeight;
		}
		
		
		/**
		 * 顶级容器
		 */		
		private var legendTopGroup:VGroup = new VGroup();
		
		
		/**
		 * 请求图例参数列表，添加图例的请求在这里储存，然后按序执行
		 */		
		private var RequestList:ArrayCollection = new ArrayCollection();
		
		
		/**
		 * 图例管理哈希表
		 */
		private var legendHashtable:Hashtable = new Hashtable();
		
		
		/**
		 * 图例数量改变事件名称
		 */		
		public static const E_LEGEND_NUM_CHANGE:String = "E_legendNumChange";
		
		
		/**
		 * 图例信息
		 * 存放调取来的图例信息
		 */
		private var LegendAry:Array = new Array();  
		
		
		/**
		 * 传入的图例集合名称
		 */		
		private var LegendName:String = "";
		/**
		 * 传入的自定义图例图标 
		 */		
		private var LegendImageAry:Array = new Array();
		/**
		 * 传入的自定义图例名称
		 */				
		private var LegendLabelAry:Array = new Array();
		
		
		/**
		 * 前一个图例加载程序是否完成
		 */		
		private var isBeforeEnd:Boolean = true;
			
		
		
		/**
		 * 
		 * <p>
		 * <b>功能：</b>
		 * 图例控制,对图例进行增加、修改、移除的操作
		 * </p>
		 * 
		 * @param operate 操作符 "add"为添加图例；"delete"为移除图例
		 * @param legendName 图例集合名称 一个模块或类型的的图例集合的名称，如：污染源管理模块中的图例
		 * @param layerName 图层名称 要获取图例图层的名称
		 * @param legendSymbolSource 图例符号图片的数据源 同于Image.source的数据源 也可以是颜色值格式的十六进制数字，会自动生成区域符号 如果输入了"layerName"参数，会对调取来的图例中的符号进行替换
		 * @param legendLabel 图例名称 如果输入了"layerName"参数，会对调取来的图例中的名称进行替换
		 * 
		 */
		public function F_legendControl(operate:String, legendName:String,
									  layerName:String=null, legendSymbolSource:Array=null, legendLabel:Array=null):void
		{
			var paramerAry:Array = [operate, legendName, layerName, legendSymbolSource, legendLabel];
			
			RequestList.addItem(paramerAry);
			
			sortLegendList();
		}
		
		
		/**
		 * 
		 * 功能：组织添加图例的请求
		 * 
		 */		
		private function sortLegendList():void
		{
			if(isBeforeEnd && RequestList.length)
			{
				isBeforeEnd = false;
				
				getLegend(RequestList[0][0], RequestList[0][1], RequestList[0][2], RequestList[0][3], RequestList[0][4]);
			}
		}
		
		
		/**
		 *
		 * 功能：开始执行添加图例，传入的请求排队执行此方法
		 *  
		 * 参数：同于 legendControl 方法的参数
		 * 返回：空
		 */		
		private function getLegend(operate:String, legendName:String,
								  	layerName:String=null, legendSymbolUrl:Array=null, legendLabel:Array=null):void
		{
			LegendAry = [];
			LegendImageAry = [];
			LegendLabelAry = [];
			LegendName = "";
			
			LegendName = legendName;
			
			switch(operate)
			{
				case "add":
					
//					if(legendHashtable.containsKey(LegendName))
//					{
//						var legendGroup:VGroup = legendHashtable.find(LegendName);
//						
//						legendTopGroup.addElement(legendGroup);
//						
//						functionEnd();
//					}
//					else
//					{
						/*
						加载图例符号
						*/
						if(legendSymbolUrl)
						{
							for(var i:int=0;i<legendSymbolUrl.length;i++)
							{
								if(legendSymbolUrl[i])
								{
									var image:Image = analysisImageSource(legendSymbolUrl[i]);
									
									LegendImageAry.push(image);
								}
								else
								{
									LegendImageAry.push(null);
								}
							}
						}
						
						/*
						加载图例名称
						*/
						if(legendLabel)
						{
							for(var n:int=0;n<legendLabel.length;n++)
							{
								if(legendLabel[n])
								{
									var label:Label = new Label();
									label.text = legendLabel[n];
									
									LegendLabelAry.push(label);
								}
								else
								{
									LegendLabelAry.push(null);
								}
							}
						}
						
						/* 
						通过图层向后台调取图例
						*/
						if(layerName && V_map)
						{
							var layerUrl:String = MapUni.layerUrl(V_map, layerName);
							if(layerUrl)
							{
								getLegendInfo(layerUrl);
							}
							else
							{
								functionEnd(false);
							}
						}
						else
						{
							replaceLegendInfo();
						}
//					}
					
					break;
				
				case "delete":
					
					try
					{
						if(legendHashtable.containsKey(LegendName))
						{
							var target:VGroup = legendHashtable.find(LegendName);
							
							legendHashtable.remove(LegendName);
							
							addElementEffect(target, false, target.height);
							
						}
						else
						{
							functionEnd(false);
						}
					}
					catch(e:Error)
					{
						showError(e.toString());
					}
					
					break;
				
				case "clear":
					
					legendTopGroup.removeAllElements();
					
					functionEnd();
					
					break;
				
			}
		}
		
		
		/**
		 *
		 * 功能：分析传入的图片数据源是图片路径还是颜色值，并生成图片返回
		 * 		 如果是十六进制的颜色值格式的数据，则生产矩形的填充符号，
		 * 		 如果是其它的则直接给图片做数据源
		 * 
		 * 参数：imgSource 图片的数据源
		 * 返回：生产的图片
		 * 
		 */		
		private function analysisImageSource(imgSource:Object):Image
		{
			var image:Image = new Image();
			
			if(imgSource is Number)
			{
				var symbol:SimpleFillSymbol = new SimpleFillSymbol("solid", imgSource as Number, 1, new SimpleLineSymbol("solid", 0x828282) );
				var symbolClass:UIComponent = symbol.createSwatch(V_legItemHeight+V_legItemHeight/2, V_legItemHeight);
				
				image.source = symbolClass;
			}
			else
			{
				image.source = imgSource;
			}
			
			return image;
		}
		
		
		/**
		 * 
		 * 功能：替换图例。如果条件满足，用传入的自定义图标、名称替换调取的图标、名称
		 * 
		 */		
		private function replaceLegendInfo():void
		{
			/*
			替换图例符号、名称
			*/
			if(LegendAry.length && LegendImageAry.length || LegendAry.length && LegendLabelAry.length)
			{
				for(var t:int=0;t<LegendAry.length;t++)
				{
					var object:Object = LegendAry[t];
					
					if( t < LegendImageAry.length )
					{
						if(LegendImageAry[t])
						{
							object.image = LegendImageAry[t];
						}
					}
					
					if( t < LegendLabelAry.length )
					{
						if(LegendLabelAry[t])
						{
							object.label = LegendLabelAry[t];
						}
					}
				}
			}
			else
			{
				var array:Array = LegendImageAry.length > LegendLabelAry.length ? LegendImageAry : LegendLabelAry;
				
				for(var i:int=0;i<array.length;i++)
				{
					var legendObj:Object = new Object();
					
					if(i < LegendImageAry.length)
					{
						if(LegendImageAry[i])
						{
							legendObj.image = LegendImageAry[i];
						}
					}
					if(i <LegendLabelAry.length)
					{
						if(LegendLabelAry[i])
						{
							legendObj.label = LegendLabelAry[i];
						}
					}
					
					LegendAry.push(legendObj);
				}
			}
			
			addLegend();
		}
		
		
		/**
		 * 
		 * 功能：调取传入图层的图例信息
		 * 
		 * 参数：要获取图例图层的 featureLayer 地址
		 * 返回：空
		 *  
		 */
		private function getLegendInfo(featureLayerUrl:String):void
		{
			var featureLayer:FeatureLayer = new FeatureLayer();
			featureLayer.url = featureLayerUrl;
			featureLayer.useAMF = true;
			featureLayer.addEventListener(LayerEvent.LOAD,onLayerLoad);
			featureLayer.addEventListener(LayerEvent.LOAD_ERROR,onLayerLoadError);
			
			function onLayerLoad(event:LayerEvent):void
			{
				featureLayer.getLegendInfos(new AsyncResponder(result,fault));
			}
			
			function onLayerLoadError(event:LayerEvent):void
			{
				showError("在加载" + featureLayerUrl + "图层时失败");
				
				functionEnd(false);
			}	
			
			function result(event:Array,token:Object):void
			{
				if(event[0])
				{
					var lengnddItemInfos:Array = LayerLegendInfo(event[0]).legendItemInfos;
					
					for(var i:int=0;i<lengnddItemInfos.length;i++)
					{
						var legendItem:LegendItemInfo = lengnddItemInfos[i];
						
						analyMapLegend(legendItem);
					}
					
					replaceLegendInfo();
				}
			}
			
			function fault(error:Object,token:Object):void
			{
				showError("在调取" + featureLayerUrl + "的图例时失败");
				
				functionEnd(false);
			}
		}
		
		
		private function showError(errorString:String):void
		{
			MapUni.errorWindow(
				"方法：UF_DynamcLegend \n" +
				"功能：动态显示图例 \n" + 
				"错误:" + errorString
			);
		}
		
		
		/**
		 * 
		 * 功能：对从图层中调取来的图例进行解析
		 * 
		 * 参数：调取图层的图例集 LegendItemInfo
		 * 返回：空
		 * 
		 */
		private function analyMapLegend(legendItem:LegendItemInfo):void
		{
			var object:Object = new Object();
			
			var picImage:Image = new Image();
			var simpImage:UIComponent = new UIComponent();
			
			var label:Label = new Label();
			
			
			if(legendItem.symbol is PictureMarkerSymbol || legendItem.symbol is PictureFillSymbol)
			{
				picImage.source = Object(legendItem.symbol).source;
				label.text = legendItem.label;
				
				object.image = picImage;
			}
			else if(legendItem.symbol is SimpleFillSymbol || legendItem.symbol is SimpleLineSymbol || legendItem.symbol is SimpleMarkerSymbol)
			{
				simpImage= legendItem.symbol.createSwatch(V_legItemHeight+V_legItemHeight/2, V_legItemHeight);
				label.text = legendItem.label;
				
				object.image = simpImage;
			}
			
			object.label = label;
			
			LegendAry.push(object);
		}
		
		
		/**
		 *  
		 * 功能：组合图例并添加到顶级容器中
		 * 
		 */
		private function addLegend():void
		{
			var legendVGroup:VGroup = new VGroup();
//			legendVGroup.percentWidth = 100;
			legendVGroup.id = LegendName;
			legendVGroup.alpha = 0;
			legendVGroup.height = 0;
			
			var legendVGroupHeight:Number = legendVGroup.height;
			
			/*
			图例名称
			*/
			var legNameLabel:Label = new Label();
			legNameLabel.percentWidth = 100;
			legNameLabel.text = LegendName;
			
			legendVGroup.addElement(legNameLabel);
			legendVGroupHeight += legNameLabel.height;
			legendVGroupHeight += legendVGroup.gap;
			/*
			添加图例
			*/
			for(var i:int=0;i<LegendAry.length;i++)
			{
				var legendItem:HGroup = new HGroup();
				legendItem.paddingLeft=15;
				legendItem.horizontalAlign = "left";
				legendItem.gap = V_LegItemGap;
				legendItem.height = V_legItemHeight;
				
				if(LegendAry.length > 6)
				{
					legendVGroup.width = 235;
					var j:int = 2*i+1;
					if(j<LegendAry.length || j==LegendAry.length)
					{
						legendVGroupHeight += V_legItemHeight;
						legendVGroupHeight += legendVGroup.gap;
						var legendItem1:HGroup = new HGroup();
						var legendItem2:HGroup = new HGroup();
						var objectMul:Object = LegendAry[j]; 
						var object:Object = LegendAry[2*i];
						if(objectMul)
						{
							legendItem1.width = 100;
							if(objectMul.image is Image)
							{
								var picImageMul:Image = creatImage(objectMul,V_legItemHeight);
								legendItem1.addElement(picImageMul);
							}
						
						    else if(objectMul.image is UIComponent)
						    {
							    var simImage:UIComponent = creatUI(objectMul,V_legItemHeight);
							
							    legendItem1.addElement(simImage);
						    }
							var label1:Label = creatLabel(objectMul);
							legendItem1.addElement(label1);
							legendItem.addElement(legendItem1);
						}
						
						if(object)
						{
							legendItem2.width = 100;
							if(object.image is Image)
							{
								var picImage:Image = creatImage(object,V_legItemHeight);
								legendItem2.addElement(picImage);
							}
							else if(object.image is UIComponent)
							{
								var simpleUIImage:UIComponent = creatUI(object,V_legItemHeight);
								
								legendItem2.addElement(simpleUIImage);
							}
							var label2:Label = creatLabel(object);
							legendItem2.addElement(label2);
							legendItem.addElement(legendItem2);
						}
						
					}
					
				}
				else
				{
					
					var object:Object = LegendAry[i];
					legendVGroupHeight += V_legItemHeight;
					legendVGroupHeight += legendVGroup.gap;
					
					/*
					图例符号
					*/
					if(object.image is Image)
					{
						var picImage:Image = creatImage(object,V_legItemHeight);
						legendItem.addElement(picImage);
					}
					else if(object.image is UIComponent)
					{
						var UIImage:UIComponent = creatUI(object,V_legItemHeight);
						legendItem.addElement(UIImage);
					}
					
					
					/*
					图例名称
					*/
					var label:Label = creatLabel(object);
					legendItem.addElement(label);
				}
				
				legendVGroup.addElement(legendItem);
			}
			
			legendVGroup.height = legendVGroupHeight;
			
			legendHashtable.add(LegendName, legendVGroup);
			
			legendTopGroup.addElementAt(legendVGroup,0);
			
			addElementEffect(legendVGroup, true, legendVGroupHeight);
		}
		
		/**
		 *  创建文本标签 
		 */
		private function creatLabel(object:Object):Label
		{
			var label:Label = object.label;
			label.percentWidth = 100;
			label.percentHeight = 100;
			label.setStyle("verticalAlign","middle");
			//请将 lineBreak 样式设置为“explicit”。设置此样式文本内容将不会换行
			label.setStyle("lineBreak", "explicit");
			return label;
		}
		
		/**
		 *  创建图片组件 
		 */
		private function creatImage(object:Object,V_legItemHeight:Number):Image
		{
			var picImageMul:Image = object.image;
			picImageMul.percentHeight = 100;
			picImageMul.width = V_legItemHeight+V_legItemHeight/2;
			return picImageMul;
		}
		
		/**
		 *  创建UI
		 */
		private function creatUI(object:Object,V_legItemHeight:Number):UIComponent
		{
			var simpImage:UIComponent = object.image;
			simpImage.percentHeight = 100;
			simpImage.width = V_legItemHeight+V_legItemHeight/2;
			return simpImage;
		}
		
		/**
		 * 
		 * 功能：实现渐变显示或隐藏的效果
		 * 
		 */		
		private function addElementEffect(target:VGroup, isAdd:Boolean, legendItemHeight:Number):void
		{
			animateProperty();
			dofade();
			
			function animateProperty():void
			{
				var propertyEffect:AnimateProperty = new AnimateProperty(target);
				propertyEffect.property = "height";
				propertyEffect.fromValue = isAdd == true ? 0 : legendItemHeight;
				propertyEffect.toValue =  isAdd == true ? legendItemHeight : 0;
				propertyEffect.duration = 500;
				propertyEffect.addEventListener(EffectEvent.EFFECT_END, onPropertyEnd);
				propertyEffect.play();
				
				function onPropertyEnd(event:EffectEvent):void
				{
					target.height = isAdd == true ? legendItemHeight : 0;
					
					if(!isAdd){
						legendTopGroup.removeElement(target);
					}
					
					functionEnd();
				}
			}
			
			function dofade():void
			{
				var fade:Fade = new Fade(target);
				fade.alphaFrom = isAdd == true ? 0 : 1;
				fade.alphaTo = isAdd == true ? 1 : 0;
				fade.duration = 500;
				fade.addEventListener(EffectEvent.EFFECT_END, onFadeEnd);
				fade.play();
				
				function onFadeEnd(event:EffectEvent):void
				{
					target.alpha = isAdd == true ? 1 : 0;
				}
			}
			
			
		}
		
		
		/**
		 * 
		 * 功能：完成一个请求，准备执行下一个
		 * 
		 */
		private function functionEnd(succeed:Boolean = true):void
		{
			if(succeed)
			{
				V_NumLegendItem = legendTopGroup.numElements;
				
				this.dispatchEvent(new Event(E_LEGEND_NUM_CHANGE));
			}
			
			isBeforeEnd = true;
			
			RequestList.removeItemAt(0);
			
			sortLegendList();
		}
		
		
	}
}