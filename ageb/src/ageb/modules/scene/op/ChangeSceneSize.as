package ageb.modules.scene.op
{
	import age.data.Box;
	import ageb.modules.document.Document;

	/**
	 * ChangeSceneSize 是修改场景大小操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeSceneSize extends SceneOPBase
	{
		public var oldSize:Box;

		public var size:Box;

		/**
		 * 创建一个新的 ChangeSceneSize
		 * @param doc
		 * @param width
		 * @param height
		 *
		 */
		public function ChangeSceneSize(doc:Document, size:Box)
		{
			super(doc);
			this.size = size;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldSize = doc.info.size.clone1();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			doc.info.setSize(size);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			doc.info.setSize(oldSize);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("修改场景大小 ({width},{height},{depth})", size);
		}
	}
}
