package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeIsFlipX extends ChangeProperty
	{
		public function ChangeIsFlipX(doc:Document, objects:*, value:Boolean)
		{
			super(doc, objects, "isFlipX", value);
		}

		override public function get name():String
		{
			return "水平翻转 (" + value + ")";
		}
	}
}
