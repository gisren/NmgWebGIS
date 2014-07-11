package widgets.exInterface.trackPlay.track
{
	//作者： jyx 
	//时间：2012年08月06日
	//描述：主要通过外面传入的参数进行轨迹回放，并提供开始、暂停、继续、停止四个功能
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import spark.components.List;
	
	import widgets.exInterface.trackPlay.real.realInfoWindow;

	public class TrackPlay
	{
		
			//轨迹点层
			public  var HistoryPointGraphicsLayer:GraphicsLayer;
			//轨迹线层
			public var HistoryLineGraphicsLayer:GraphicsLayer;
			//起始图片路径
			public var startPicURL:String;
			//移动图片路径
			public var movePicURL:String;
			//每段移动的公里数
			public var unitValue:int;
			//时间间隔
			public var timeSpace:Number ;
			//线的颜色
			public var lineColor:Number;
			//透明度
			public var lineAlpha:Number;			
			//线宽
			public var lineWidth:Number;
			//线宽
			public var isRevolved:Boolean;
			//地图
			public var map:Map;
			//是否动态显示信息框
			public var isInfoWindowShow:Boolean;
			//是否显示视频按钮
			public var isViewVisible:Boolean;
			//视频图片路径
			public var viewImagePath:String;
			//视频地址
			public var viewUrl:String;
			//视频图片点击时调用函数
			public var videoPicClick:String;
			//点组
			private var points:Array;
			//时间控件
			private var time:Timer;
			//状态 0 终止  1 开始  2 继续/暂停
			private var state:int;
			//当前点的位置
			private var pointNum:int;
			//起点
			private var dataAry:Array;
			private var raisMapPoint:MapPoint;
			private var raisGraphic:Graphic;
			
			private function onCarClick(event:MouseEvent):void
			{
				var graphic:Graphic = event.currentTarget as Graphic;
				
				var winContent:realInfoWindow = new realInfoWindow();
				winContent.title = graphic.attributes.name;
				winContent.content = graphic.attributes.info;
				winContent.viewImagePath = viewImagePath;
				winContent.videoPicClick = videoPicClick;
				winContent.SetImageVisible(isViewVisible);
				winContent.viewUrl = viewUrl;
				winContent.idNo = graphic.attributes.carno;
				winContent.guid = graphic.attributes.guid;
				map.infoWindow.content = winContent;
				map.infoWindow.show(graphic.geometry as MapPoint);
				
				isInfoWindowShow = true;
				
			}
			
			
			//计时开始；
			public function Start(data:Array)
			{
				
				if(data.length <= 1)
					return;
				points = new Array();
				dataAry = data;
				//拆分点组，并按照1米分段并存入points中
				for( var i:int = 0 ; i < dataAry.length-1;i++)
				{
					var startlong:Number = dataAry[i]["X"];
					var startlat:Number = dataAry[i]["Y"];
					var endlong:Number = dataAry[i+1]["X"];
					var endlat:Number = dataAry[i+1]["Y"];
					if(i == 0)//添加起点
					{
						//根据第一个点设定图片是否旋转
						var strRevolved:String = dataAry[i]["isRevolved"];
						if(strRevolved == "1")
							isRevolved = true;
						else
							isRevolved = false;
						//根据第一个点设定是否显示摄像头
						var strView:String = dataAry[i]["isView"];
						if(strView == "1")
							isViewVisible = true;
						else
							isViewVisible = false;
						raisMapPoint = new MapPoint(startlong,startlat);
						points.push(raisMapPoint);
					}
					//计算公里数
					var num:int = (int)(Math.sqrt((startlong - endlong)*(startlong - endlong)+(startlat - endlat)*(startlat - endlat))*111/unitValue);
					for(var j:int = 0;j<num;j++)
					{
						var long:Number = dataAry[i]["X"] + (endlong - startlong)*(j+1)/num;
						var lat:Number = dataAry[i]["Y"]  + (endlat - startlat)*(j+1)/num;
						var newMapPoint:MapPoint = new MapPoint(long,lat);
						points.push(newMapPoint);
					} 
				}
				if(time !=null && time.running== true)
					time.stop();
					
				//定义Time控件
				time = new Timer(timeSpace,0);
				
				time.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void{onTimer_raisMove()});
				
				//添加起点
				raisMapPoint = points[0] as MapPoint;
				var startSymbol:PictureMarkerSymbol=new PictureMarkerSymbol(this.startPicURL);						
				var startGraphic:Graphic = new Graphic(raisMapPoint,startSymbol,dataAry[0]);						
				HistoryPointGraphicsLayer.add(startGraphic);
				
				
				//添加车辆点
				
				var raisSymbol:PictureMarkerSymbol = new PictureMarkerSymbol(this.movePicURL);//new PictureMarkerSymbol(picURL,87*0.7,32*0.7);
				//var angle:Number = caculateAngle(points[pointNum-1] as MapPoint,points[pointNum] as MapPoint);
				
				//raisSymbol.angle=angle;
				raisGraphic = new Graphic(raisMapPoint,raisSymbol,dataAry[0]);				
				raisGraphic.addEventListener(MouseEvent.CLICK, onCarClick);
				HistoryPointGraphicsLayer.add(raisGraphic);
				state = 1;
				this.pointNum = 0;
				time.start();
			}
			//暂停
			public function Pause()
			{
				if(time != null)
					time.stop();
			}
			//继续
			public function GoOn()
			{
				if(time != null)
					time.start();
			}
			//计时停止
			public function Stop()
			{
				
				Clear();
			}
			//刷新
			private function Clear()
			{
				if(time != null)
					time.stop();
				pointNum = 0;
				state = 0;
				HistoryPointGraphicsLayer.clear();
				HistoryLineGraphicsLayer.clear();
			}
			//时间运行时进行
			function onTimer_raisMove():void
			{
				if(state==0)
					return;
				if(pointNum == points.length - 1)
				{
					state=0;
					pointNum=0;
					time.stop();
					return;
				}
				pointNum++;
				var longitude:Number = (points[pointNum] as MapPoint).x;
				var latiude:Number =(points[pointNum] as MapPoint).y;				
				var midelNewPoint:MapPoint = new MapPoint(longitude,latiude,map.spatialReference);				
					
				
								//添加线
				var array:Array = new Array();
				array.push(points[pointNum-1] as MapPoint);
				array.push(points[pointNum] as MapPoint);
				
				var newPolyline:Polyline = new Polyline();
				newPolyline.addPath(array);
				var lineGraphic:Graphic = new Graphic(newPolyline,new SimpleLineSymbol("",lineColor,lineAlpha,lineWidth));
				HistoryLineGraphicsLayer.add(lineGraphic);
				
				//控制是否旋转图片
				if(isRevolved == true)
				{
					var angle:Number = caculateAngle(points[pointNum-1] as MapPoint,points[pointNum] as MapPoint);
					(raisGraphic.symbol as PictureMarkerSymbol).angle = -angle;
				}
				
				raisGraphic.geometry = points[pointNum] as MapPoint;
				
				
				if(isInfoWindowShow == false)
				{
					var attribute:Object = raisGraphic.attributes;					
					var winContent:realInfoWindow = new realInfoWindow();
					winContent.title = attribute.name;
					winContent.content = attribute.info;
					winContent.SetImageVisible(true);
					map.infoWindow.content = winContent;
					map.infoWindow.show(midelNewPoint);
				}
			}
			
			
			
			/**
			 * 函数:计算两点夹角
			 */
			private function caculateAngle(pt0:MapPoint,pt1:MapPoint):Number{
				var angle:Number;
				
				var oldLong:Number = pt0.x;
				var oldLat:Number =pt0.y;
				
				var newLong:Number = pt1.x;
				var newLat:Number =pt1.y;
				
				var longLength:Number = newLong - oldLong;
				var latLength:Number = newLat - oldLat;
				var x:Number = longLength ;
				var y:Number = latLength ;
				if(x==0)
				{
					if(y<0)
						angle=270;
					else if(y>0)
						angle=90;
					
				}
				else if(y==0)
				{	
					if(x<0)
						angle=180;
					else 
						angle=0;
				}
				else
				{
					angle=Math.atan(y/x); 
					angle=angle*180/Math.PI;
					if(longLength>0 && latLength>0)
						angle=angle;
					else if(longLength<0 && latLength>0)
						angle=180+angle;
					else if(longLength<0 && latLength<0)
						angle=180+angle;
					else if(longLength>0 && latLength<0)
						angle=angle;						
				}
			return angle;
		
		}
		
	}
}