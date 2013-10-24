package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeRegionWidth extends ChangeProperty
	{
		public function ChangeRegionWidth(doc:Document, objects:*, value:Number)
		{
			super(doc, objects, "width", value);
		}

		override public function get name():String
		{
			return format("修改区域宽{value}", this);
		}
	}
}
