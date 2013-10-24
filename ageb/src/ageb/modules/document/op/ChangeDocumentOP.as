package ageb.modules.document.op
{
	import flash.errors.IllegalOperationError;
	import ageb.modules.document.Document;
	import ageb.modules.document.DocumentState;

	/**
	 * ChangeDocumentOP 是会修改文档的操作<br>
	 * 在 OpBase 的基础上增加了几个模板方法，用于实现 undo, redo 等操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeDocumentOP extends OpBase
	{
		/**
		 * 创建一个新的 ChangeDocumentOP 对象
		 * @param doc
		 *
		 */
		public function ChangeDocumentOP(doc:Document)
		{
			super(doc);
		}

		override public function execute():Boolean
		{
			// 调用 saveOld 保存历史记录
			saveOld();

			if (!_doc.isNew)
			{
				_doc.state = DocumentState.CHANGED;
			}
			redo();
			var result:Boolean = super.execute();
			return result;
		}

		/**
		 * saveOld 将会被 execute 调用，用于保存旧值，以便实现 undo 和 redo<br>
		 * 子类必须实现该接口
		 */
		protected function saveOld():void
		{
			throw new IllegalOperationError("saveOld 尚未实现");
		}

		/**
		 * 撤销
		 *
		 */
		public function undo():void
		{
			throw new IllegalOperationError("undo 尚未实现");
		}

		/**
		 * 重做
		 *
		 */
		public function redo():void
		{
			throw new IllegalOperationError("redo 尚未实现");
		}
	}
}
