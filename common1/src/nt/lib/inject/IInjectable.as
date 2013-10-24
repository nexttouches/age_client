package nt.lib.inject
{
	import flash.events.IEventDispatcher;

	public interface IInjectable extends IEventDispatcher
	{
		function updateFrom (input:Object):void;
		function setValue (propertyName:String, newValue:*):void;
		function copy (target:Object):void;
	}
}