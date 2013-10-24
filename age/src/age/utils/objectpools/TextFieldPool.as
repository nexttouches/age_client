package age.utils.objectpools
{
	import starling.text.TextField;

	/**
	 * TextFieldPool<br>
	 * 代码节选自
	 * http://help.adobe.com/zh_CN/as3/mobile/WS948100b6829bd5a6-19cd3c2412513c24bce-8000.html
	 * @author zhanghaocong
	 *
	 */
	public final class TextFieldPool
	{
		private static var MAX_VALUE:uint;

		private static var GROWTH_VALUE:uint;

		private static var counter:uint;

		private static var pool:Vector.<TextField>;

		private static var currentTextField:TextField;

		public static function init(maxPoolSize:uint, growthValue:uint):void
		{
			MAX_VALUE = maxPoolSize;
			GROWTH_VALUE = growthValue;
			counter = maxPoolSize;
			var i:uint = maxPoolSize;
			pool = new Vector.<TextField>(MAX_VALUE);

			while (--i > -1)
				pool[i] = new TextField(1, 1, "");
		}

		public static function get():TextField
		{
			if (counter > 0)
				return currentTextField = pool[--counter];
			var i:uint = GROWTH_VALUE;

			while (--i > -1)
				pool.unshift(new TextField(1, 1, ""));
			counter = GROWTH_VALUE;
			return get();
		}

		public static function dispose(disposedTextField:TextField):void
		{
			pool[counter++] = disposedTextField;
		}
	}
}
