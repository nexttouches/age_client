package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeActionName extends ChangeProperty
	{
		public function ChangeActionName(doc:Document, objects:*, value:*)
		{
			super(doc, objects, "actionName", value);
		}

		override public function get name():String
		{
			return "修改动作 (" + value + ")";
		}
	}
}
