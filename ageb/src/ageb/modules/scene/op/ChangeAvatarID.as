package ageb.modules.scene.op
{
	import ageb.modules.document.Document;

	public class ChangeAvatarID extends ChangeProperty
	{
		public function ChangeAvatarID(doc:Document, objects:*, value:*)
		{
			super(doc, objects, "avatarID", value);
		}

		override public function get name():String
		{
			return "修改 Avatar ID (" + value + ")";
		}
	}
}
