package nt.lib.util
{

	/**
	 * 通过UTF时区的时间戳 加上 北京时区偏移量，此时再根据UTF读取的日期值，即为北京时区
	 * 获取当日零时的时间戳的方法（ 将当日北京日期 年/月/日按照UTF设置，然后获取的时间戳 减去 北京时区的偏移量，即为北京时区当日的时间戳）
	 *
	 */
	public class DateBeijing
	{
		private static const BeijinOffset:Number = 8 * 3600 * 1000;

		/**
		 * 仅用于存储日期数据
		 */
		private var beijinDate:Date;

		//private var utfDate:Date;

		/**
		 * 单位毫秒
		 * @param time
		 *
		 */
		public function DateBeijing(time:Number)
		{
			//将UTF时区的时间戳+北京时区偏移量，此时根据UTF读取的日期值，即为北京时区
			beijinDate = new Date(time + BeijinOffset);
		}

		public function getTime():Number
		{
			return beijinDate.getTime() - BeijinOffset;
		}

		/**
		 * 返回时间戳，截至到北京时区的00:00:00
		 *
		 */
		public function getTimeForDate():Number
		{
			var date:Date = new Date();
			date.setUTCFullYear(getBeijinFullYear(), getBeijinMonth(), getBeijinDate());
			date.setUTCHours(0, 0, 0, 0);
			return date.getTime() - BeijinOffset;
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinFullYear():int
		{
			return beijinDate.getUTCFullYear();
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinMonth():int
		{
			return beijinDate.getUTCMonth();
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinDate():int
		{
			return beijinDate.getUTCDate();
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinHours():int
		{
			return beijinDate.getUTCHours();
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinMinutes():int
		{
			return beijinDate.getUTCMinutes();
		}

		/**
		 * 返回北京时区的
		 *
		 */
		public function getBeijinSeconds():int
		{
			return beijinDate.getUTCSeconds()
		}
	}
}
