package nt.lib.reflect
{

	public class Accessor extends Property
	{
		public var access:String;

		public function Accessor(name:String, type:Class, access:String, uri:String = null)
		{
			super(name, type, uri);
			this.access = access;
		}
	}
}
