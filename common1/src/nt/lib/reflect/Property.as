package nt.lib.reflect
{

	public class Property extends Description
	{
		public var name:String;

		public var type:Class;

		public var uri:String;

		public var ns:Namespace;

		public function Property(name:String, type:Class, uri:String = null)
		{
			this.name = name;
			this.type = type;
			this.uri = uri;
			if (uri)
			{
				ns = new Namespace("", uri);
			}
		}
	}
}
