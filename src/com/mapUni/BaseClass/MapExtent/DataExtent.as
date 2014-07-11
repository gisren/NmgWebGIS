////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	根据传入的显示图像数据集，自动将地图缩放到包含所以图像的范围
//  传入的数据集支持 Array 和 ArrayCollection
//  集合的内容支持  Graphic 或 MapPoint 的集合
//  Graphic 可以为任意类型图形
//
//  Author：liuXL
//  Date：2012-02-10
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.MapExtent
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	
	import mx.collections.ArrayCollection;

	
	/**
	 * 
	 * 地图缩放到所有传入的图形对象显示集合的区域
	 * 
	 * 初始化时需传入两个参数，
	 * dataCollection 为数据源，支持 Array 和 ArrayCollection 格式，内容为 Graphic 或 MapPoint 的集合， 
	 * map	为要进行缩放的地图
	 * MapExtentProportion 可选参数，用于缩放的区域的边缘向外延伸为区域长宽的比例
	 * 
	 * @author liuxl
	 * 
	 */	
	public class DataExtent
	{
		
		/**
		 * 
		 * 设置地图显示区域
		 * 
		 * @param dataCollection 要显示的对象集合
		 * @param map	地图
		 * @param MapExtentProportion 地图缩放的区域的边缘向外延伸为区域长宽的比例
		 * 
		 */		
		public function DataExtent(dataCollection:Object, map:Map, MapExtentProportion:Number=0.3)
		{
			var collection:ArrayCollection = new ArrayCollection();
			
			/*
			判断数据类型
			*/
			if(dataCollection is Array)
			{
				collection = new ArrayCollection(dataCollection as Array);
			}
			else if(dataCollection is ArrayCollection)
			{
				collection = dataCollection as ArrayCollection;
			}
			else
			{
				return;
			}
			
			_map = map;
			
			_MapExtentProportion = MapExtentProportion;
			
			if(_map)
			{
				if(collection.length)
				{
					//判断集合内的数据类型
					if(collection[0] is Graphic || collection[0] is Geometry)
					{
						setMapExtent(collection);
					}
				}
			}
			
		}
		
		
		/**
		 * 在地图上加载多点或单点后，屏幕缩放到点所在的位置时向外延伸的比例值<br/>
		 * 比例值越大，缩放后的地图比例尺越小。默认值为0.1
		 */		
		private var _MapExtentProportion:Number = 0.3; 
		
		/**
		 * 地图 若不传入此参数则地图不会自动缩放到所加载点的区域
		 */		
		private var _map:Map;
		
		
		/**
		 * 
		 * 进行地图显示区域的判断
		 * 
		 * @param dataColl 显示对象数据集
		 * 
		 */		
		private function setMapExtent(dataColl:ArrayCollection):void
		{
			var minX:Number = 180;
			var minY:Number = 90;
			var maxX:Number = 0;
			var maxY:Number = 0;
			
			/*
			遍历数据
			通过对比替换来得到地图要显示区域边缘的最大值
			*/
			for(var i:int=0;i<dataColl.length;i++)
			{
				var longitude:Number;
				var latitude:Number;
				
				var geometry:Geometry = null;
				
				if(dataColl[i] is Graphic)
				{
					var graphic:Graphic = dataColl[i] as Graphic;
					geometry = graphic.geometry;
				}
				else if(dataColl[i] is Geometry)
				{
					geometry = dataColl[i] as Geometry;
				}
				else
				{
					return;
				}
				
				
				if(geometry)
				{
					if(geometry.type == Geometry.MAPPOINT)
					{
						var mapPoint:MapPoint = geometry as MapPoint;
						
						longitude = mapPoint.x;
						latitude  = mapPoint.y;
						
						if(longitude && latitude)
						{
							if(minX > longitude)
								minX = longitude;
							if(minY > latitude)
								minY = latitude;
							if(maxX < longitude)
								maxX = longitude;
							if(maxY < latitude)
								maxY = latitude;
						}
					}
					else
					{
						
						if(minX > geometry.extent.xmin)
							minX = geometry.extent.xmin;
						if(minY > geometry.extent.ymin)
							minY = geometry.extent.ymin;
						if(maxX < geometry.extent.xmax)
							maxX = geometry.extent.xmax;
						if(maxY < geometry.extent.ymax)
							maxY = geometry.extent.ymax;
					}
				}
			}
			
			var xNum:Number = maxX - minX;
			var yNum:Number = maxY - minY;
			
			if(xNum && yNum && xNum!=-180 && yNum!=-90)
			{
				/*
				_MapExtentProportion 的值来控制地图缩放区域要向外延伸的范围站本身显示区域的比例值
				*/
				var _minX:Number = minX - xNum * _MapExtentProportion;
				var _minY:Number = minY - yNum * _MapExtentProportion;
				var _maxX:Number = maxX + xNum * _MapExtentProportion;
				var _maxY:Number = maxY + yNum * _MapExtentProportion;
				
				_map.extent = new Extent(_minX, _minY, _maxX, _maxY);
			}
			else if(minX != 180 && minY != 90)
			{
				/*
				如果传入的数据只有一个点
				则居中显示此点，并且地图比例尺会放大一倍
				*/
				_map.centerAt(new MapPoint(minX,minY));
				//_map.scale = _map.scale/2;
			}
			else
			{
				showError("没有成功根据数据完成指定区域的显示");
			}
		}
		
		
		/**
		 * 错误提示
		 */		
		private function showError(errorString:String):void
		{
			var info:String = 
				"方法：DataExtent\n" +
				"功能：将地图缩放移动到传入数据所在的区域\n" +
				"错误：" + errorString;
			
			new ErrorClass(info);
		}
		
		
		
		
		
	}
}