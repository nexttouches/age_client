package nt.lib.util.queue
{
	import flash.events.EventDispatcher;
	
	/**
	 * 队列管理器
	 * @author zhanghaocong
	 * 
	 */
	public class QueueManager extends EventDispatcher
	{
		public var clientList:Array;
		public var lastClient:IQueueClient;
		public var state:int = QueueState.Idle;
		
		public function QueueManager()
		{
			super();
			clientList = [];
		}
		
		public function flush ():void
		{
			switch (state)
			{
				case QueueState.Idle:
					processNext();
					break;
			}
		}
		
		/**
		 * 增加一个队列客户端，客户端必须实现 IQueueClient
		 * @param client
		 * 
		 */
		public function equeue (client:IQueueClient):void
		{
			clientList.push(client);
		}
		
		/**
		 * 执行本次队列
		 * @param client
		 * 
		 */
		public function processNext ():void
		{
			if (clientList && clientList.length > 0)
			{
				state = QueueState.Busy;
				lastClient = clientList.shift() as IQueueClient;
				lastClient.process(lastClient_onProcessComplete);
				flush();
			}
		}
	
		/**
		 * 清空队列
		 * 
		 */
		public function clear ():void
		{
			lastClient = null;
			state = QueueState.Idle;
			if (clientList)
			{
				clientList.length = 0;
				clientList = null;
			}
		}
		
		/**
		 * @private
		 * 
		 */
		private function lastClient_onProcessComplete ():void
		{
			state = QueueState.Idle;
			flush();
		}
	}
}