package ageb.modules.avatar.op
{
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.AvatarInfoEditable;
	import ageb.modules.ae.ObjectInfoEditable;
	import ageb.modules.document.AvatarDocument;
	import ageb.modules.document.Document;
	import ageb.modules.document.op.ChangeDocumentOP;

	/**
	 * 操作 AvatarDocument 的基类
	 * @author zhanghaocong
	 *
	 */
	internal class AvatarOPBase extends ChangeDocumentOP
	{
		/**
		 * 获得当前 OP 要修改的文档对象
		 * @return
		 *
		 */
		public function get doc():AvatarDocument
		{
			return _doc as AvatarDocument
		}

		/**
		 * 返回 doc.object
		 * @return
		 *
		 */
		public function get object():ObjectInfoEditable
		{
			return doc.object;
		}

		/**
		 * 返回 doc.avatar
		 * @return
		 *
		 */
		public function get avatar():AvatarInfoEditable
		{
			return doc.avatar;
		}

		/**
		 * 返回 object.actionInfo
		 * @return
		 *
		 */
		public function get action():ActionInfoEditable
		{
			return object.actionInfo as ActionInfoEditable;
		}

		/**
		 * 创建一个新的 AvatarOPBase
		 * @param doc
		 *
		 */
		public function AvatarOPBase(doc:Document)
		{
			super(doc);
		}
	}
}
