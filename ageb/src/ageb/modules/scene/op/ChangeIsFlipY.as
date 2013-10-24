package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeIsFlipY extends ChangeProperty
	{
		public function ChangeIsFlipY(doc:Document, objects:*, value:Boolean)
		{
			super(doc, objects, "isFlipY", value);
		}

		override public function get name():String
		{
			return "垂直翻转 (" + value + ")";
		}
	}
}
