package nt.lib.reflect
{

	internal class Description
	{
		public var metadatas:Object;

		public function Description()
		{
		}

		public function parseMetadata(list:XMLList):void
		{
			metadatas = {};

			for each (var node:XML in list)
			{
				var m:Metadata = new Metadata(node.@name);
				m.parseArgs(node..arg);
				metadatas[m.name] = m;
			}
		}

		/**
		 * 获得指定的 Metadata
		 * @param name
		 * @return
		 *
		 */
		final public function getMetadata(name:String):Metadata
		{
			return metadatas[name];
		}

		final public function hasMetadata(name:String):Boolean
		{
			return metadatas[name] != null;
		}
	}
}
