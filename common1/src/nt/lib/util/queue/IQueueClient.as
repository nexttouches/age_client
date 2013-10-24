package nt.lib.util.queue
{
	/**
	 * 队列客户端<br/>
	 * 所有的队列客户端都应该实现该接口
	 * @author zhanghaocong
	 * 
	 */
	public interface IQueueClient
	{
		/**
		 * 轮到当前队列时 QueueManager 会调用该方法
		 * @param onComplete process 本体 执行完毕时会调用该方法
		 */
		function process (onProcessComplete:Function):void;
	}
}