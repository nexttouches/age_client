package nt.lib.inject
{
	import flash.events.EventDispatcher;

	import nt.lib.inject.injectors.AliasInjector;
	import nt.lib.inject.injectors.DefaultValueInjector;
	import nt.lib.reflect.Metadata;
	import nt.lib.reflect.Property;
	import nt.lib.reflect.Type;
	import nt.lib.util.copyProperties;

	public class Injectable extends EventDispatcher implements IInjectable
	{
		public var input:Object;

		public function Injectable(input:Object = null)
		{
			Injector.getInjector(DefaultValueInjector).inject(this);
			updateFrom(input);
		}

		public function updateFrom(input:Object):void
		{
			this.input = input;
			if (input)
			{
				Injector.getInjector(AliasInjector).inject(this, input);
			}

			onUpdate(input);
		}

		protected function onUpdate(input:Object):void
		{
			// TODO Auto Generated method stub

		}

		public function setValue(propertyName:String, newValue:*):void
		{
			var description:Type = Type.of(this);
			var property:Property = description.writableProperties[propertyName];
			var oldValue:* = this[propertyName];
			if (oldValue is Injectable)
			{
				oldValue.updateFrom(newValue);
			}
			else
			{
				this[propertyName] = newValue;
			}
			var eventName:String;
			var propertyMetadata:Metadata = property.metadatas[InjectKeywords.Inject];
			if (propertyMetadata.args[InjectKeywords.Event])
			{
				eventName = propertyMetadata.args[InjectKeywords.Event] == true ? propertyName + "Change" : propertyMetadata.args[InjectKeywords.Event];
				dispatchEvent(new PropertyChangeEvent(eventName, propertyName, this[propertyName], oldValue));
			}
			var instanceMetadata:Metadata = description.metadatas[InjectKeywords.Inject];
			if (instanceMetadata.args[InjectKeywords.Event])
			{
				eventName = instanceMetadata.args[InjectKeywords.Event] == true ? "change" : instanceMetadata.args[InjectKeywords.Event];
				dispatchEvent(new PropertyChangeEvent(eventName, propertyName, this[propertyName], oldValue));
			}
		}

		public function copy(target:Object):void
		{
			copyProperties(this, target);
		}
	}
}
