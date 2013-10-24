package ageb.modules.scene.op
{
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.document.op.ChangeDocumentOP;

	/**
	 * 操作 SceneDocument 的基类
	 * @author zhanghaocong
	 *
	 */
	internal class SceneOPBase extends ChangeDocumentOP
	{
		/**
		 * 获得当前 OP 要修改的文档对象
		 * @return
		 *
		 */
		public function get doc():SceneDocument
		{
			return _doc as SceneDocument
		}

		/**
		 * 创建一个新的 SceneOPBase
		 * @param doc
		 *
		 */
		public function SceneOPBase(doc:Document)
		{
			super(doc);
		}
	}
}
