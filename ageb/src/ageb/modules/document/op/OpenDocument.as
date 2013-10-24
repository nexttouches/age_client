package ageb.modules.document.op
{
	import ageb.modules.document.Document;

	public class OpenDocument extends OpBase
	{
		public function OpenDocument(doc:Document)
		{
			super(doc);
		}

		override public function execute():Boolean
		{
			settings.getData(settings).lastDocumentPath = _doc.nativePath;
			return super.execute();
		}

		override public function get name():String
		{
			return format("打开文档", _doc);
		}
	}
}
