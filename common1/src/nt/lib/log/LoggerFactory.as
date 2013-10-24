package nt.lib.log
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class LoggerFactory
	{
		private static var instance:LoggerFactory;

		private static var cache:Dictionary = new Dictionary;

		public static function create(obj:*):ILogger
		{
			if (instance == null)
			{
				instance = new LoggerFactory;
			}
			return instance.create(obj);
		}

		public static function setFactory(value:LoggerFactory):void
		{
			instance = value;
		}

		private var target:ILogTarget;

		public function LoggerFactory()
		{
			target = createLogTarget();
		}

		private function create(obj:*):ILogger
		{
			if (!(obj is Class))
			{
				obj = obj.constructor;
			}
			if (cache[obj] != null)
			{
				return new SimpleLogger(target, cache[obj]);
			}

			var shortName:String = getQualifiedClassName(obj);
			var spliterIndex:int = shortName.indexOf("::");
			if (spliterIndex > -1)
			{
				shortName = shortName.substring(spliterIndex + 2);
			}
			cache[obj] = shortName;
			return new SimpleLogger(target, shortName);
		}

		protected function createLogTarget():ILogTarget
		{
			return new TraceTarget;
		}
	}
}
