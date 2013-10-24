package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeRegionHeight extends ChangeProperty
	{
		public function ChangeRegionHeight(doc:Document, objects:*, value:Number)
		{
			super(doc, objects, "height", value);
		}

		override public function get name():String
		{
			return format("修改区域高{value}", this);
		}
	}
}
