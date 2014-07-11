
package com.mapUni.BaseClass
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.mapUni.BaseClass.Buffer.Buffer;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	import com.mapUni.BaseClass.GetLayerUrl.GetLayerUrl;
	import com.mapUni.BaseClass.Graphic.PointGraphic;
	import com.mapUni.BaseClass.InfoWindow.PopUpInfoWindow;
	import com.mapUni.BaseClass.LayerRenderer.LayerRenderer;
	import com.mapUni.BaseClass.MapExtent.DataExtent;
	import com.mapUni.BaseClass.Relation.Relation;
	import com.mapUni.BaseClass.RiverRenderer.RiverRenderer;
	import com.mapUni.BaseClass.Search.Search;
	import com.mapUni.BaseClass.Search.Search_new;
	import com.mapUni.BaseClass.WebServices.CallWebServices;

	public class MapUni
	{
		
		/**
		 * 
		 * <p>对传入的几何图形进行缓冲并得到缓冲图形</p>
		 * 
		 * @param geomServUrl 几何服务地址
		 * @param geometry 要进行缓冲的几何图形。数组格式，可同时缓冲多个图形
		 * @param distances 要缓冲的距离。数组格式，可对每个几何图形进行不同距离的多层缓冲
		 * @param unit 缓冲距离的单位。从 GeometryService 中获取
		 * @param onResult 缓冲成功后要执行的方法, 参数为数组格式
		 * @param resultParam 要对缓冲成功后执行的方法传递的额外参数，可选
		 * @param onFault 缓冲失败后要执行的方法，可选
		 * @param faultParam 要对缓冲失败后执行的方法传递的额外参数，可选
		 * @param spatialReference 要缓冲的几何图形、缓冲方法、缓冲后的输出图形的空间参考坐标系，
		 * 							如果要缓冲的几何图形因为没有空间参考坐标系而报错，可以在此传入来解决，可选
		 * @return 判断值，判断传入几何数据是否有问题
		 * 
		 */	
		public static function buffer(geomServUrl:String, geometry:Array, distances:Array, unit:Number, onResult:Function, 
									  resultParam:Object=null, onFault:Function=null, faultParam:Object=null, 
									  spatialReference:SpatialReference=null):void
		{
			new Buffer(geomServUrl, geometry, distances, unit, onResult, resultParam, onFault, faultParam, spatialReference);
		}
		
		
		/**
		 * 
		 * <p>对指定地图图层进行条件查询</p>
		 * 
		 * @param layerUrl 图层地址 所要查询的地图图层地址
		 * @param qGeometry 图形查询条件 参数为 Geometry 格式的图形
		 * @param qWhere 属性查询条件 可以为针对字段的属性查询条件，如："name='好'"如果要查询所有记录，可以将此参数设置为"1=1" ，但效率很低，不推荐这样使用；
		 * @param result 查询成功后要执行的方法,参数 FeatureSet
		 * @param resultParam 要对查询成功后执行的方法传递的额外参数，可选
		 * @param outField 查询记录中返回的属性字段，默认为全部返回，可选
		 * @param useAMF 查询返回数据时是否使用 AMF 格式文件，当使用的 ArcGIS Server 10 以上的地图服务时把此参数改为true，可以明显提高查询的速度。默认为true。可选
		 * @param fault 查询失败后要执行的方法，可选
		 * @param faultParam 要对查询失败后执行的方法传递的额外参数，可选
		 * @param returnGeometry 是否返回几何图形，默认为true，可选
		 * 
		 */		
		public static function search(layerUrl:String, qGeometry:Geometry, qWhere:String, result:Function, resultParam:Object=null, 
									  outField:Array=null, useAMF:Boolean=true, fault:Function=null, faultParam:Object=null, 
									  returnGeometry:Boolean=true):void
		{
			new Search(layerUrl, qGeometry, qWhere, result, resultParam, outField, useAMF, fault, faultParam, returnGeometry);
		}
		
		public static function search_new(layerUrl:String, qGeometry:Geometry, qWhere:String, result:Function, resultParam:Object=null, 
										  outField:Array=null, useAMF:Boolean=true, fault:Function=null, faultParam:Object=null ,spatialRelationship:String=null):void
		{
			new  Search_new(layerUrl, qGeometry, qWhere, result, resultParam, outField, useAMF, fault, faultParam);
		}
		/**
		 *
		 * <p>显示传入数据所在的地图区域</p>
		 *  
		 * @param dataCollection 显示对象数据集合。支持 Array 和 ArrayCollection 格式，内容为 Graphic 或 MapPoint 的集合，
		 * @param map 要进行缩放的地图
		 * @param MapExtentProportion 地图向外延伸显示区域所占本身区域的比例，默认为0.3
		 * 
		 */			
		public static function dataExtent(dataCollection:Object, map:Map, MapExtentProportion:Number=0.3):void
		{
			new DataExtent(dataCollection, map, MapExtentProportion);
		}
		
		
		/**
		 * 
		 * <p>根据图层名称获取地图图层编号</p>
		 * 
		 * @param map 要从中检索的地图或图层，可以为 Map， 也可以为 ArcGISDynamicMapServiceLayer 或者 ArcGISTiledMapServiceLaye
		 * @param layerName 要获取的图层名称
		 * @param returnUrlType 返回的图层地址类型，1为普通地图服务的图层地址，2为"FeatureService"地图服务的图层地址,默认为1，
		 * 						若输入规定数据以外的参数，程序默认将以1来处理，可选参数
		 * @return 返回图层名对应的图层地址
		 * 
		 */		
		public static function layerUrl(mapOrLayer:Object, layerName:String, returnUrlType:uint=1):String
		{
			var layerUrlCalss:GetLayerUrl = new GetLayerUrl(mapOrLayer, layerName, returnUrlType);
			return layerUrlCalss.getUrl();
		}
		
		
		
		/**
		 *
		 * <p>创建图片符号的点信息</p>
		 *  
		 * @param x 地图上的x轴坐标
		 * @param y 地图上的y轴坐标
		 * @param picUrl 图片符号的所需图片的相对路径，可选参数
		 * @param attribute 要为点添加的属性信息，可选参数
		 * @param picWidth 图片符号的宽，可选参数
		 * @param picHeight 图片符号的高，可选参数
		 * @param picXoffset 图片符号在x轴的偏移值，可选参数
		 * @param picYoffset 图片符号在y轴的偏移值，可选参数
		 * @param picAngle 图片符号的旋转值，可选参数
		 * @return 对象为点的Graphic
		 * 
		 */		
		public static function pointGraphic(x:Number, y:Number, picUrl:String, attribute:Object=null, picWidth:Number=0, picHeight:Number=0,
												  picXoffset:Number=0, picYoffset:Number=0, picAngle:Number=0):Graphic
		{
			var pointClass:PointGraphic = new PointGraphic(x, y, picUrl, attribute, picWidth, picHeight, picXoffset, picYoffset, picAngle);
			return pointClass.getPointGraphic();
		}
		
		
		/**
		 *
		 * <p>气泡显示点位的信息</p>
		 *  
		 * @param map 地图
		 * @param graphic 目标图形
		 * @param title 标题
		 * @param content 内容。如果需要换行可以使用换行符来实现,可选参数
		 * @param isShow 是否要立即弹出信息框
		 * @param showLocated 气泡框显示的位置
		 * @param link 第一个超连接的地址,可选参数
		 * @param linkName 第一个超链接的名称,可选参数
		 * @param link2 第二个超连接的地址,可选参数
		 * @param linkName2 第二个超链接的名称,可选参数
		 * @param link3 第三个超连接的地址,可选参数
		 * @param linkName3 第三个超链接的名称,可选参数
		 * 
		 */	
		public static function popupInfoWindow(map:Map, graphic:Graphic, title:String, content:String="", 
											   isShow:Boolean=false, showLocated:MapPoint=null,
											   link:String="", linkName:String="", 
											   link2:String="", linkName2:String="",
											   link3:String="" ,linkName3:String=""):void
		{
			new PopUpInfoWindow(map, graphic, title, content, isShow, showLocated, link, linkName, link2, linkName2, link3, linkName3);
		}
		
		
		/**
		 * 
		 * <p>调用外部的WebService方法</p>
		 * 
		 * @param WebServiceURL WebService链接地址
		 * @param httpFunctionName 要调用的函数的名称
		 * @param httpFunctionParameter 调用函数所需的参数
		 * @param onResultFunction 成功调取数据后的响应函数,参数类型 ResultEvent
		 * @param onResultParameter 用于向成功调取数据后的响应函数中传递参数,可选参数
		 * @param onFaultfunction 没有成功调取数据后的响应函数,可选参数，参数类型 FaultEvent
		 * @param onFaultParameter 用于向没有成功调取数据后的响应函数中传递参数,可选参数
		 * 
		 */	
		public static function callWebService(WebServiceURL:String, httpFuncName:String, httpFuncParam:Array,
											  onResult:Function, onResultParam:Object = null,
											  onFault:Function = null, onFaultParam:Object =null):void
		{
			new CallWebServices(WebServiceURL, httpFuncName, httpFuncParam, onResult, onResultParam, onFault, onFaultParam);
		}
		
		
		/**
		 * 
		 * <p>错误、提示信息窗口</p>
		 * 
		 * @param errorString 要显示的错误或提示信息，如果需要换行可以使用换行符
		 * 
		 */		
		public static function errorWindow(errorString:String):void
		{
			new ErrorClass(errorString);
		}
		
		
		/**
		 * 
		 * <p>比较传入两组几何图形中各个图形间的空间关系</p>
		 * 
		 * @param geomServUrl 几何服务地址
		 * @param geometryList1 被搜索的几何图形集合
		 * @param geometryList2 搜索条件几何图形集合
		 * @param onResult 缓冲成功后要执行的方法,参数为一个数组
		 * @param resultParam 要对缓冲成功后执行的方法传递的额外参数
		 * @param onFault 缓冲失败后要执行的方法
		 * @param faultParam 要对缓冲失败后执行的方法传递的额外参数
		 * @param spatialRelationship 指定两组几何图形要素满足的空间关系，<br/>可以通过RelationParameters中的静态常量来指定此参数值，默认为完全包含。
		 * 
		 */
		public static function relation(geomServUrl:String, geometryList1:Array, geometryList2:Array, onResult:Function, 
										resultParam:Object, onFault:Function, faultParam:Object, 
										spatialRelationship:String="esriGeometryRelationIn"):void
		{
			new Relation(geomServUrl, geometryList1, geometryList2, onResult, resultParam, onFault, faultParam, spatialRelationship);
		}
		
		
		/**
		 * 
		 * <p>在地图上渲染指定的对象，返回鼠标选择的对象</p>
		 *  
		 * @param map 地图
		 * @param layerUrl 图层地址
 		 * @param layerNameField 图层中的名称字段
		 * @param callback 回调函数
		 * @param queryGeometry 几何图形查询条件
		 * @param queryWhere 属性查询条件
		 * 
		 */		
		public static function layerRenderer(map:Map, layerUrl:String, layerNameField:String, callback:Function, queryGeometry:Geometry=null, queryWhere:String="1=1"):void
		{
			new LayerRenderer(map, layerUrl, layerNameField, callback, queryGeometry, queryWhere);
		}
		
		
		public static function riverRenderer(map:Map, riverLayers:Array, callback:Function):void
		{
			new RiverRenderer(map, riverLayers, callback);	
		}
		
		
		
	}
}