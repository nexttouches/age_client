package nt.lib.inject
{
	import nt.lib.inject.*;
	import nt.lib.inject.injectors.AliasInjector;
	import nt.lib.reflect.*;
	import nt.lib.util.copyProperties;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	dynamic public class ArrayInjectable extends Array implements IInjectable, IEventDispatcher
	{
		private var dispatcher:EventDispatcher;

		public function ArrayInjectable(... parameters)
		{
			super(parameters);
			dispatcher = new EventDispatcher(this);
		}

		public function updateFrom(input:Object):void
		{
			if (input)
			{
				Injector.getInjector(AliasInjector).inject(this, input);
			}
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
			var targetIsArrayInjectable:Boolean = target is ArrayInjectable;
			if (targetIsArrayInjectable)
			{
				copyProperties(this, target);
			}
			else
			{
				throw new ArgumentError("要复制的目标不是 ArrayInjectable");
			}
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return willTrigger(type);
		}
	}
}
