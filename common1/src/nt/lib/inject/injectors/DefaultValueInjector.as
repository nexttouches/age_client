package nt.lib.inject.injectors
{
	import nt.lib.inject.InjectKeywords;
	import nt.lib.inject.Injector;
	import nt.lib.reflect.Property;
	
	public class DefaultValueInjector extends Injector
	{
		public function DefaultValueInjector()
		{
			super();
			injectKeyword = InjectKeywords.DefaultValue;
		}
		
		public override function inject (target:*, params:* = null):void
		{
			var properties:Object = getInjectableProperties(target);
			for each (var property:Property in properties)
			{
				var propertyValue:*;
				var defaultValue:* = property.metadatas[InjectKeywords.Inject].args[InjectKeywords.DefaultValue];
				if (defaultValue == InjectKeywords.Auto)
				{
					propertyValue = new property.type();
				}
				else
				{
					propertyValue = defaultValue;
				}
				target[property.name] = propertyValue;
			}
		}
	}
}