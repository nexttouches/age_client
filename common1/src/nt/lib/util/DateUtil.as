package nt.lib.util
{

	public class DateUtil
	{
		public function DateUtil()
		{
		}

		/**
		* 计算多少时间前
		* @author KK
		*/
		public static function getAgo(timePass:Number, minute:String = "分钟前", hour:String = "小时前", day:String = "天前"):String
		{
			var txt:String;

			if (timePass < 3600)
			{
				//n分钟前
				txt = int(timePass / 60) + minute;
			}
			else if (timePass < 3600 * 24)
			{
				//n小时前
				txt = int(timePass / 3600) + hour;
			}
			else
			{
				//n天前
				txt = int(timePass / (3600 * 24)) + day;
			}
			return txt;
		}

		/**
		 * 根据时间戳获取 时分秒
		 * @param num
		 * @return
		 *
		 */
		public static function getHHMMSS(num:int):String
		{
			var h:String;
			var m:String;
			var s:String;

			var hour:Number = Math.floor(num / 3600);
			hour %= 24;
			hour < 10 ? h = "0" + hour : h = hour.toString();

			var minute:Number = Math.floor(num / 60) % 60;
			minute < 10 ? m = "0" + minute : m = minute.toString();

			var sec:Number = Math.floor(num % 60);
			sec < 10 ? s = "0" + sec : s = sec.toString();
			return h + ":" + m + ":" + s;
		}

		/**
		 * 根据时间戳获取 分秒
		 * @param num
		 * @return
		 *
		 */
		public static function getMMSS(num:int):String
		{
			var h:String;
			var m:String;
			var s:String;

			var hour:Number = Math.floor(num / 3600);
			hour %= 24;
			hour < 10 ? h = "0" + hour : h = hour.toString();

			var minute:Number = Math.floor(num / 60) % 60;
			minute < 10 ? m = "0" + minute : m = minute.toString();

			var sec:Number = Math.floor(num % 60);
			sec < 10 ? s = "0" + sec : s = sec.toString();
			if (hour > 0)
			{
				return h + ":" + m + ":" + s;
			}
			else
			{
				return m + ":" + s;
			}
		}

		/**
		 * 以第一个时间戳为基准，判断第二个时间戳与其的差值，单位为天
		 * @param time1 单位秒
		 * @return 0同一天，负数代表早了几天，正数代表晚了几天
		 */
		public static function dayDiff(time1:int, time2:int):int
		{
			var date1:DateBeijing = new DateBeijing(time1 * 1000);
			var date2:DateBeijing = new DateBeijing(time2 * 1000);

			var dValue:Number = date2.getTimeForDate() - date1.getTimeForDate();
			if (dValue == 0)
			{
				return dValue;
			}
			else
			{
				return dValue / (24 * 3600 * 1000);
			}
		}

		/**
		 *
		 * @param time 时间戳，单位秒
		 * @return 0428
		 *
		 */
		public static function toMonthDayString(time:int):String
		{
			var date:DateBeijing = new DateBeijing(time * 1000);
			var month:int = date.getBeijinMonth() + 1
			var day:int = date.getBeijinDate();

			var str:String = "";
			if (month < 10)
			{
				str += "0";
			}
			str += month;
			if (day < 10)
			{
				str += "0";
			}
			str += day;
			return str;
		}

		/**
		 *是否是整点
		 * @return
		 *
		 */
		public static function isOclock(time:int):Boolean
		{
			var date1:DateBeijing = new DateBeijing(time * 1000);

			if (date1.getBeijinMinutes() == 0 && date1.getBeijinSeconds() == 0)
			{
				return true;
			}

			return false;
		}
	}
}
