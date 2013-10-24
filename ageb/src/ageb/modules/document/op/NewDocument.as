package ageb.modules.document.op
{
	import ageb.modules.document.Document;

	public class NewDocument extends OpBase
	{
		public function NewDocument(doc:Document)
		{
			super(doc);
		}

		override public function get name():String
		{
			return format("打开文档 ({name})", _doc);
		}
	}
}
