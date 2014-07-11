package widgets.exInterface.StatisticalAnalysis.Control
{
	import com.esri.viewer.ViewerContainer;
	
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	
	import mx.controls.Image;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="closed", type="flash.events.Event")]

	[SkinState("open")]
	[SkinState("closed")]
	
	public class StatChartContent extends SkinnableContainer
	{
		
		[SkinPart(required="false")]
		public var widgetFrame:Group;
		
		[SkinPart(required="false")]
		public var header:Group;
		
		[SkinPart(required="false")]
		public var closeButton:Image;
		
		[SkinPart(required="false")]
		public var resizeButton:Image;
		
		[Bindable]
		public var widgetWidth:Number;
		
		[Bindable]
		public var widgetHeight:Number;
		
		[Bindable]
		public var title:String;
		
		private static const WIDGET_OPENED:String = "open";
		private static const WIDGET_CLOSED:String = "closed";
		
		[Embed(source="assets/images/w_resizecursor.png")]
		public var resizeCursor:Class;
		
		private var _widgetState:String = WIDGET_OPENED;
		
		private var _cursorID:int = 0;
		
		public function StatChartContent()
		{
			
		}
		
		
		/**
		 * 监听：重写向皮肤中推送组件的方法
		 * 功能：对组建进行动作监听
		 */		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == widgetFrame)
			{
				widgetFrame.addEventListener(MouseEvent.MOUSE_DOWN, mouse_downHandler);
				widgetFrame.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
				
				widgetFrame.stage.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
				widgetFrame.stage.addEventListener(Event.MOUSE_LEAVE, stageout_Handler);
			}
			if (instance == header)
			{
				header.addEventListener(MouseEvent.MOUSE_DOWN, mouse_downHandler);
				header.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
			}
			if (instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK, close_clickHandler);
			}
			if (instance == resizeButton)
			{
				resizeButton.addEventListener(MouseEvent.MOUSE_OVER, resize_overHandler);
				resizeButton.addEventListener(MouseEvent.MOUSE_OUT, resize_outHandler);
				resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, resize_downHandler);
			}
		}
		
		
		/**
		 * 监听：组件鼠标的按下事件
		 * 功能：在鼠标按下后监听鼠标的移动事件
		 */		
		public function mouse_downHandler(event:MouseEvent):void
		{
			header.addEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			widgetFrame.addEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
		}
		
		
		/** 指示组件现在是否正处在移动中 */
		private var widgetMoveStarted:Boolean = false;
		
		private function mouse_moveHandler(event:MouseEvent):void
		{
			if (!widgetMoveStarted)
			{
				widgetMoveStarted = true;
				
				this.alpha = 0.7;
				this.startDrag();
			}
		}
		
		private function mouse_upHandler(event:MouseEvent):void
		{
			header.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			widgetFrame.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			
			this.alpha = 1;
			this.stopDrag();
			
			var appHeight:Number = FlexGlobals.topLevelApplication.height;
			
			if (this.y < 0)
			{
				this.y = 2;
			}
			if (this.y > (appHeight - 40))
			{
				this.y = appHeight - 40;
			}
			if (this.x < 0)
			{
				this.x = 2;
			}
			
			var screenWidth:int = Capabilities.screenResolutionX;
			
			if(systemManager.stage.width-screenWidth<150)
			{
				if (this.x >= (systemManager.stage.width - this.width - 200 + 110))
				{
					this.x = systemManager.stage.width - this.width - 200 + 110;
				}
			}
			else
			{
				if (this.x > (systemManager.stage.width - this.width - 200))
				{
					this.x = systemManager.stage.width - this.width - 200 ;
				}
			}
			
			// clear constraints since x and y have been set
			this.left = this.right = this.top = this.bottom = undefined; 
			
			widgetMoveStarted = false;
		}
		
		private function stageout_Handler(event:Event):void
		{
			if (widgetMoveStarted)
			{
				mouse_upHandler(null);
			}
		}
		
		
		/**
		 * 组建的状态 
		 */		
		public function set widgetState(value:String):void
		{
			_widgetState = value;
			invalidateSkinState();
			
			dispatchEvent(new Event(value));
		}
		public function get widgetState():String
		{
			return _widgetState;
		}
		
		
		/**
		 * 监听：关闭按钮的点击 
		 */		
		protected function close_clickHandler(event:MouseEvent):void
		{
			widgetState = WIDGET_CLOSED;
			dispatchEvent(new Event(WIDGET_CLOSED));
		}
		
		
		
		private function resize_overHandler(event:MouseEvent):void
		{
			_cursorID = CursorManager.setCursor(resizeCursor, 2, -10, -10);
		}
		
		private function resize_outHandler(event:MouseEvent):void
		{
			CursorManager.removeCursor(_cursorID);
		}
		
		private function resize_downHandler(event:MouseEvent):void
		{
			/*TODO: for now, it can't be resized when is not basic layout*/
			stage.addEventListener(MouseEvent.MOUSE_MOVE, resize_moveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, resize_upHandler);
		}
		
		private function resize_moveHandler(event:MouseEvent):void
		{
			// if there is minWidth and minHeight specified on the container, use them while resizing
			const minimumResizeWidth:Number = minWidth ? minWidth : 200;
			const minimumResizeHeight:Number = minHeight ? minHeight : 100;
			
			if ((stage.mouseX < stage.width - 20) && (stage.mouseY < stage.height - 20))
			{
				if ((stage.mouseX - this.x) > minimumResizeWidth)
				{
					width = (stage.mouseX - this.x);
				}
				if ((stage.mouseY - this.y) > minimumResizeHeight)
				{
					height = (stage.mouseY - this.y);
				}
			}
		}
		
		private function resize_upHandler(event:MouseEvent):void
		{
			widgetWidth = width;
			widgetHeight = height;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resize_moveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, resize_upHandler);
			
			this.stopDrag();
		}
	}
}