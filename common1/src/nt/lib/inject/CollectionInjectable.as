package nt.lib.inject
{
	import nt.lib.reflect.Metadata;
	import nt.lib.reflect.Type;

	dynamic public class CollectionInjectable extends Injectable
	{
		public var elementType:Class;

		public function CollectionInjectable(input:Object = null)
		{
			super(input);
		}

		/**
		 * 填充一段指定类型的空数据
		 * @param start
		 * @param end
		 * @param type
		 *
		 */
		public function fill(start:int, end:int):void
		{
			if (elementType == null)
			{
				elementType = Object;
			}
			var metadata:Metadata = Type.of(elementType).metadatas[InjectKeywords.Inject];
			if (metadata)
			{
				var defaultProperty:String = metadata.args[InjectKeywords.DefaultProperty];
			}
			for (var i:int = start; i <= end; i++)
			{
				this[i] = new elementType();
				if (defaultProperty)
				{
					this[i][defaultProperty] = i;
				}
			}
		}

		public function reset():void
		{

		}

		public function empty():void
		{
		}
	}
}
