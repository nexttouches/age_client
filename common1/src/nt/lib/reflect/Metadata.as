package nt.lib.reflect
{
	import nt.lib.util.Converter;

	public class Metadata extends Description
	{
		public var name:String;
		public var args:Object;
		public function Metadata(name:String)
		{
			super();
			this.name = name;
		}
		
		public function getArg (name:String):*
		{
			return args[name];
		}
		
		public function hasArg (name:String):Boolean
		{
			return args[name] != null;
		}
		
		public function parseArgs (list:XMLList):void
		{
			args = {};
			for each (var node:XML in list)
			{
				args[node.@key] = Converter.intelligenceConvert(node.@value);
			}
		}
	}
}