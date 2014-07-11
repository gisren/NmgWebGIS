////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2012 中科宇图天下科技有限公司 环保事业部
//
//	错误、提示信息窗口
//
//	通过在弹出的浮动框添加文本来实现
//  初始化时传入要显示的信息并弹出窗口
//  如果窗口已经弹出则向现有的窗口中追加信息，
//  关闭窗口时会清空信息
//
//  Author：liuXL
//  Date：2012-03-15
//
////////////////////////////////////////////////////////////////////////////////
package com.mapUni.BaseClass.ErrorWindow
{
	import flash.display.DisplayObject;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.TextInput;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TextArea;
	import spark.components.TitleWindow;

	
	/**
	 *
	 * <p>弹出信息框，显示错误、提示信息</p>
	 *  
	 * @author LiuXL
	 * 
	 */	
	public class ErrorClass extends TitleWindow  
	{
		
		/**
		 *
		 * 初始化时传入要显示的信息
		 *  
		 * @param errorInfo 错误、提示信息
		 * 
		 */		
		public function ErrorClass(errorInfo:String)
		{
			if(!IsLoadErrorWindow)
			{ 
				IsLoadErrorWindow = true;
				
				TextMessage.text = errorInfo
				addErrorInfo();
				//addTitleWindow();
			}
			else
			{
				TextMessage.text += "\n\n" + errorInfo;
			}
		}
		
		
		/**
		 * 文本框
		 * 用于显示错误信息 
		 */		
		private var ErrorTextArea:TextArea = new TextArea();
		
		
		/**
		 * <p>用于显示错误信息窗口是否已经加载并已显示</p> 
		 */		
		private static var IsLoadErrorWindow:Boolean = false;
		
		
		/**
		 * 错误信息 
		 */		
		private static var TextMessage:TextInput = new TextInput();
		
		
		/**
		 * 
		 * 添加文本显示框 
		 * 
		 */		
		private function addErrorInfo():void
		{
			ErrorTextArea.left = 10;
			ErrorTextArea.right = 10;
			ErrorTextArea.top = 10;
			ErrorTextArea.bottom = 10;
			ErrorTextArea.editable = false;
			ErrorTextArea.setStyle("contentBackgroundColor","#000000");
			ErrorTextArea.setStyle("color","#FFFFFF");
			ErrorTextArea.text = TextMessage.text;
			
			this.addElement(ErrorTextArea);
			
			BindingUtils.bindProperty(ErrorTextArea, "text", TextMessage, "text");
		}
		
		
		/**
		 *
		 * 设置错误信息窗口属性
		 * 将窗口添加到顶级浮动窗口
		 * 
		 */		
		private function addTitleWindow():void
		{
			this.x = 100;
			this.y = 100;
			this.width = 400;
			this.height = 200;
			this.setStyle("cornerRadius","5");
			this.title = "应用程序错误信息提示";
			
			this.addEventListener(CloseEvent.CLOSE, onTitleClose);
			
			var app:DisplayObject = FlexGlobals.topLevelApplication as DisplayObject;
			PopUpManager.addPopUp(this, app, false);
		}
		
		
		/**
		 *
		 * 监听弹出窗口的关闭事件
		 * 将此控件从顶级浮动窗口中移除
		 * 
		 */		
		private function onTitleClose(event:CloseEvent):void
		{
			PopUpManager.removePopUp(this);
			
			IsLoadErrorWindow = false;
			TextMessage.text = "";
		}
		
		
		
		
		
	}
}