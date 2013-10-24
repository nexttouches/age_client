package nt.lib.util
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import nt.ui.core.Component;
	import org.osflash.signals.natives.*;
	import org.osflash.signals.natives.sets.NativeSignalSet;

	/**
	 * 提供了 Event 到 Event.currentTarget 映射的 SignalSet
	 * @author zhanghaocong
	 *
	 */
	public class NativeMappedSignalSet extends NativeSignalSet
	{
		public function NativeMappedSignalSet(target:IEventDispatcher)
		{
			super(target);
		}

		public function getNativeMappedSignal(eventType:String, eventClass:Class = null):NativeMappedSignal
		{
			if (null == eventType)
				throw new ArgumentError('eventType must not be null.');
			return _signals[eventType] ||= new NativeMappedSignal(target, eventType, eventClass || Event).mapTo(mapFunction);
		}

		private function mapFunction(event:Event):Component
		{
			return target as Component;
		}
	}
}
