package nt.lib.inject
{
	import flash.events.Event;

	public class PropertyChangeEvent extends Event
	{
		public static var CHANGE:String = "change";
		public var before:*;
		public var after:*;
		public var name:String;
		public function PropertyChangeEvent(type:String, name:String = null, after:* = null, before:* = null)
		{
			super(type);
			this.name = name;
			this.before = before;
			this.after = after;
		}
	}
}