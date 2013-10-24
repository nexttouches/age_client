package nt.assets.extensions
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * 内部使用一个 Timer 来延迟调用方法
	 * @author zhanghaocong
	 *
	 */
	public class LazyCallQueue
	{
		/**
		 * 调用队列
		 */
		private var queue:Vector.<Function> = new Vector.<Function>;

		/**
		 * 调用间隔
		 */
		private var interval:Number;

		/**
		 * 内部 Timer
		 */
		private var timer:Timer;

		/**
		 * 队列开始时，调用该方法
		 */
		public var onStart:Function;

		/**
		 * 产生调用进度时，调用该方法
		 */
		public var onProgress:Function;

		/**
		 * 队列执行完毕时，调用该方法
		 */
		public var onComplete:Function;

		/**
		 * 延迟调用的间隔 <br>
		 * 默认为 0.1，也就是每 0.1 秒执行一次队列<br>
		 * 使用在图片解码等操作上可以显著改善卡的状况
		 * @param fps
		 *
		 */
		public function LazyCallQueue(interval:Number = 0.1)
		{
			this.interval = interval;
			timer = new Timer(interval);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onTimer(event:TimerEvent):void
		{
			queue.pop().call();

			if (queue.length == 0)
			{
				timer.stop();
			}
		}

		/**
		 * 增加一个延迟处理的请求
		 * @param request
		 *
		 */
		public function add(request:Function):void
		{
			queue.push(request);

			if (!timer.running)
			{
				timer.start();
			}
		}
	}
}
