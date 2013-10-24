package nt.lib.inject
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	import nt.lib.reflect.Metadata;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;

	public class Injector
	{
		public var injectablePropertyCache:Dictionary;

		/**
		 * cacheProperties 使用的过滤关键字，最终会储存到 injectablePropertyCache 中
		 */
		public var injectKeyword:String;

		public static var injectorCache:Dictionary = new Dictionary();

		public static function getInjector(factory:Class):Injector
		{
			if (!injectorCache[factory])
			{
				injectorCache[factory] = new factory();
			}
			return injectorCache[factory];
		}

		public function Injector()
		{
			super();
			if (this["constructor"] == Injector)
			{
				throw new IllegalOperationError("Injector 是抽象类");
			}
			injectablePropertyCache = new Dictionary();
		}

		public function getInjectableProperties(target:*):Object
		{
			var description:Type = Type.of(target);
			if (!injectablePropertyCache[description.factory])
			{
				cacheProperties(description);
			}
			return injectablePropertyCache[description.factory];
		}

		public function cacheProperties(description:Type):void
		{
			var properties:Object = description.writableProperties;
			var cache:Object = {};
			for (var propertyName:String in properties)
			{
				var property:Property = properties[propertyName];
				var metadata:Metadata = property.metadatas[InjectKeywords.Inject]
				if (metadata)
				{
					if (metadata.args[injectKeyword])
					{
						cache[propertyName] = property;
					}
				}
			}
			injectablePropertyCache[description.factory] = cache;
		}

		public function inject(target:*, params:* = null):void
		{
			throw new IllegalOperationError("尚未实现");
		}
	}
}
