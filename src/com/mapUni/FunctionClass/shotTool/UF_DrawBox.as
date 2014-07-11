package com.mapUni.FunctionClass.shotTool 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.Container;
	
	[event(name="drawBoxEnd", type="com.mapUni.FunctionClass.shotTool.ShotEvent")]
	
	public class UF_DrawBox extends EventDispatcher
	{
		public function UF_DrawBox(container:Container) 
		{
			this.container = container;
			rect = new Rectangle(0, 0, 0, 0);
			sprite = new Sprite();
			graphic = sprite.graphics;
			
			//仅仅绘制背景
			drawBox(false);
		}
		
		//要执行拉框效果的容器
		protected var container:Container;
		
		//鼠标拉框矩形
		protected var rect:Rectangle;
		
		protected var sprite:Sprite;
		
		private var graphic:Graphics;
		
		
		//拉框的激活状态
		private var _activateEnable:Boolean = false;
		
		//矩形边框的颜色
		private var _boxBoderColor:int = 0xFF0000;
		
		//矩形边框的粗细
		private var _boxBoderThickness:int = 2;
		
		//矩形边框的透明度
		private var _boxBorderAlpha:Number = 1;
		
		//背景颜色
		private var _bgColor:int = 0x000000;
		
		//背景透明度
		private var _bgAlpha:Number = 0.5;
		

		
		/**
		 * 
		 * <p>矩形边框的颜色</p>
		 * @return
		 *
		 */
		public function get boxBoderColor():int 
		{
			return this._boxBoderColor;
		}
		public function set boxBoderColor(value:int):void 
		{
			this._boxBoderColor = value;
		}
		
		
		/**
		 * 
		 * <p>矩形边框的粗细</p>
		 * @return
		 *
		 */
		public function get boxBoderThickness():int 
		{
			return this._boxBoderThickness;
		}
		public function set boxBoderThickness(value:int):void 
		{
			this._boxBoderThickness = value;
		}
		
		
		/**
		 * 
		 * <p>矩形边框的透明度</p>
		 * @return
		 *
		 */
		public function get boxBorderAlpha():Number 
		{
			return this._boxBorderAlpha;
		}
		public function set boxBorderAlpha(value:Number):void 
		{
			this._boxBorderAlpha = value;
		}

		
		/**
		 * 
		 * <p>背景颜色</p>
		 * @return
		 *
		 */
		public function get bgColor():int 
		{
			return this._bgColor;
		}
		public function set bgColor(value:int):void 
		{
			this._bgColor = value;
		}

		
		/**
		 * <p>背景透明度</p>
		 * @return
		 */
		public function get bgAlpha():Number
		{
			return this._bgAlpha;
		}
		public function set bgAlpha(value:Number):void 
		{
			this._bgAlpha = value;
		}
		
		
		/**
		 * <p>鼠标左键按下</p>
		 * @param event
		 */
		protected function downHandler(event:MouseEvent):void 
		{
			container.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			container.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			
			rect.x = event.localX;
			rect.y = event.localY;
			rect.width = rect.height = 0;
			
			//绘制背景
			drawBox(false);
		}

		
		/**
		 *
		 * <p>鼠标释放</p>
		 * @param event
		 *
		 */
		protected function upHandler(event:MouseEvent):void 
		{
			container.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			container.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			
			resetRectLoacted();
			
			reSeletedBox();
		}
		
		
		/**
		 * 
		 * <p>鼠标移动</p>
		 * @param event
		 *
		 */
		protected function moveHandler(event:MouseEvent):void 
		{
			rect.width = event.localX - rect.x;
			rect.height = event.localY - rect.y;
			drawBox();
		}
		
		
		/**
		 *
		 * 检查矩形框的宽高是否存在负数
		 * 如果存在负值，则重新将矩形框的起点坐标设在左上角
		 * 
		 */		
		protected function resetRectLoacted():void
		{
			if(rect.width < 0)
			{
				rect.x = rect.x + rect.width;
				rect.width = Math.abs(rect.width);
			}
			
			if(rect.height < 0)
			{
				rect.y = rect.y + rect.height;
				rect.height = Math.abs(rect.height);
			}
		}
			
		
		/**
		 * 
		 * 清除当前的拉框和拉框外的背景
		 * 并可继续进行拉框选择
		 * 
		 */		
		protected function reSeletedBox():void
		{
			graphic.clear();
		}
		
		
		/**
		 * 
		 * <p>绘制边框</p>
		 * @param includeBox 是否绘制边框
		 *
		 */
		protected function drawBox(includeBox:Boolean = true):void 
		{
			graphic.clear();
			graphic.beginFill(_bgColor, _bgAlpha);
			graphic.drawRect(container.x, container.y, container.width, container.height);
			
			if (includeBox) 
			{
				graphic.lineStyle(_boxBoderThickness, _boxBoderColor, _boxBorderAlpha);
				graphic.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
			
			graphic.endFill();
			graphic.lineStyle();
			
		}
		
		
		/**
		 * 
		 * 激活工具
		 *
		 */
		public function activate():void 
		{
			if(!this._activateEnable)
			{
				this._activateEnable = true;
				
				container.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
				container.rawChildren.addChild(sprite);
			}
		}
		
		
		/**
		 * 
		 * 注销工具
		 *
		 */
		public function deactivate():void 
		{
			container.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			if (sprite && container.rawChildren.contains(sprite))
			{
				container.rawChildren.removeChild(sprite);
				this._activateEnable = false;
			}
				
		}
		
	}
}