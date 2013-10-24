package nt.lib.inject.injectors
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	import nt.lib.inject.*;
	import nt.lib.reflect.*;

	public class AliasInjector extends Injector
	{
		private var aliasCache:Dictionary;

		public function AliasInjector()
		{
			super();
			injectKeyword = InjectKeywords.Alias;
			aliasCache = new Dictionary();
		}

		public override function cacheProperties(description:Type):void
		{
			super.cacheProperties(description);
			var aliases:Object = {};
			var properties:Object = getInjectableProperties(description.factory);
			for each (var property:Property in properties)
			{
				var t:String = property.metadatas[InjectKeywords.Inject].args[InjectKeywords.Alias];
				var a:Array = t.split("|");
				for each (var alias:String in a)
				{
					aliases[alias] = property.name;
				}
			}
			aliasCache[description.factory] = aliases;
		}

		public override function inject(target:*, params:* = null):void
		{
			var properties:Object = getInjectableProperties(target);
			var propertyChanged:Boolean = false;
			var targetIsInjectable:Boolean = target is IInjectable;
			var targetIsEventDispatcher:Boolean = target is IEventDispatcher;
			var description:Type = Type.of(target);
			var aliases:Object = aliasCache[description.factory];
			for (var alias:String in params)
			{
				var propertyName:String = aliases[alias];
				if (!propertyName)
				{
					if (target is CollectionInjectable || target is ArrayInjectable)
					{
						propertyName = alias;
					}
				}
				if (propertyName)
				{
					propertyChanged = true;
					var property:Property = properties[propertyName];
					if (property)
					{
						var propertyMetadata:Metadata = property.metadatas[InjectKeywords.Inject];
					}
					var aliasValue:* = params[alias];
					var oldValue:* = target[propertyName];
					if (target[propertyName] is IInjectable)
					{
						target[propertyName].updateFrom(aliasValue);
					}
					else
					{
						target[propertyName] = aliasValue;
					}
					if (targetIsEventDispatcher)
					{
						if (propertyMetadata && propertyMetadata.args[InjectKeywords.Event])
						{
							var eventName:String = propertyMetadata.args[InjectKeywords.Event] == true ? propertyName + "Change" : propertyMetadata.args[InjectKeywords.Event];
							target.dispatchEvent(new PropertyChangeEvent(eventName, propertyName, target[propertyName], oldValue));
						}
					}
				}
			}
			if (propertyChanged && targetIsEventDispatcher)
			{
				var instanceMetadata:Metadata = description.metadatas[InjectKeywords.Inject];
				if (instanceMetadata)
				{
					if (instanceMetadata.args[InjectKeywords.Event])
					{
						eventName = instanceMetadata.args[InjectKeywords.Event] == true ? "change" : instanceMetadata.args[InjectKeywords.Event];
						target.dispatchEvent(new PropertyChangeEvent(eventName));
					}
				}
			}
		}
	}
}
