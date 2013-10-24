package nt.lib.util.queue
{
	public class SyncQueueClient implements IQueueClient
	{
		public var closure:Function;
		public function SyncQueueClient(closure:Function)
		{
			this.closure = closure;
		}
		
		public function process(onComplete:Function):void
		{
			closure();
			onComplete();
		}
	}
}