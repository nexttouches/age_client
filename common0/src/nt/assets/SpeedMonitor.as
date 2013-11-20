package nt.assets
{
	import flash.utils.getTimer;

	/**
	 * 速度检测小工具
	 * @author zhanghaocong
	 *
	 */
	public class SpeedMonitor
	{
		/**
		 * 上一次调用 <tt>update</tt> 的时间
		 */
		private var t:int = 0;

		/**
		 * 上一次调用 <tt>update</tt> 时输入的参数
		 */
		private var value:int = 0;

		/**
		 * 下载速度（字节/秒）
		 */
		public var speed:int = 0;

		/**
		 * constructor
		 * @param value
		 */
		public function SpeedMonitor(value:int = 0)
		{
			update(value);
		}

		/**
		 * 更新下载速度
		 * @param value
		 *
		 */
		public function update(value:int):void
		{
			const t2:int = getTimer();
			const t_delta:int = t2 - t;
			t = t2;
			const value_delta:int = value - this.value;
			this.value = value;
			speed = value_delta / t_delta * 1000;
		}
	}
}
