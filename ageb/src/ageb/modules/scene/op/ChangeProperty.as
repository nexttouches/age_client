package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeProperty extends SceneOPBase
	{
		public var oldValues:Array;

		public var value:*;

		public var objects:*;

		public var property:String;

		public var setter:String;

		public function ChangeProperty(doc:Document, objects:*, property:String, value:*)
		{
			super(doc);
			this.property = property;
			this.setter = "set" + property.charAt(0).toUpperCase() + property.substring(1);
			this.objects = objects;
			this.value = value;
		}

		protected function doChange(o:Object, property:String, value:*):void
		{
			if (o.hasOwnProperty(setter))
			{
				o[setter](value);
			}
			else
			{
				o[property] = value;
			}
		}

		override public function redo():void
		{
			for (var i:int = 0; i < objects.length; i++)
			{
				doChange(objects[i], property, value);
			}
		}

		override protected function saveOld():void
		{
			oldValues = [];

			for (var i:int = 0; i < objects.length; i++)
			{
				oldValues[i] = objects[i][property];
			}
		}

		override public function undo():void
		{
			for (var i:int = 0; i < objects.length; i++)
			{
				doChange(objects[i], property, oldValues[i]);
			}
		}
	}
}
