package com.mapUni.BaseClass.WebServices
{
	import com.mapUni.BaseClass.ErrorWindow.ErrorClass;
	
	import mx.managers.CursorManager;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;

	public class CallWebServices
	{
		
		/**
		 * 
		 * 调用外部WebService方法
		 * 
		 * @param WebServiceURL WebService链接地址
		 * @param httpFunctionName 要调用的函数的名称
		 * @param httpFunctionParameter 调用函数所需的参数
		 * @param onResultFunction 成功调取数据后的响应函数
		 * @param onResultParameter 用于向成功调取数据后的响应函数中传递参数,可选参数
		 * @param onFaultfunction 没有成功调取数据后的响应函数,可选参数
		 * @param onFaultParameter 用于向没有成功调取数据后的响应函数中传递参数,可选参数
		 * 
		 */		
		public function CallWebServices(WebServiceURL:String,httpFunctionName:String,httpFunctionParameter:Array,
									      onResultFunction:Function,onResultParameter:Object = null,
									      onFaultfunction:Function = null,onFaultParameter:Object =null):void
		{
			var pService:WebService=new WebService();
			pService.loadWSDL(WebServiceURL);
			pService.addEventListener(ResultEvent.RESULT,onResult);
			pService.addEventListener(FaultEvent.FAULT,onfult);
			
			var _abstr:AbstractOperation;
			_abstr = pService[httpFunctionName];
			_abstr.arguments = httpFunctionParameter;
			_abstr.send();
			
			//鼠标设置忙碌光标
			CursorManager.setBusyCursor();
			
			
			function onResult(event:ResultEvent):void
			{
				//清除忙碌光标
				CursorManager.removeBusyCursor();
				
				if(onResultParameter)
				{
					onResultFunction(event,onResultParameter);
				}
				else
				{
					onResultFunction(event);
				}
				
			}
			
			function onfult(event:FaultEvent):void
			{
				//清除忙碌光标
				CursorManager.removeBusyCursor();
				
				if(onFaultfunction != null)
				{
					if(onFaultParameter)
					{
						onFaultfunction(event,onFaultParameter);
					}
					else
					{
						onFaultfunction(event);
					}
				}
				else
				{
					var param:String = "";
					
					if(httpFunctionParameter)
					{
						param = httpFunctionParameter.toString();
					}
					
					new ErrorClass(
						"错误：在调取外部WebService服务时出错，请检查参数配置\n" +
						"地址：" + WebServiceURL +　"\n" +
						"名称：" + httpFunctionName + "\n" +
						"参数：" + param + "\n" +
						event.fault.toString()
						);
					
				}
			}
		}
	}
}