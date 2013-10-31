package ageb.modules.document
{
	import flash.filesystem.File;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.scene.SceneDocumentView;

	/**
	 * 场景文档
	 * @author zhanghaocong
	 *
	 */
	public class SceneDocument extends Document
	{
		/**
		 * 关联的 info
		 */
		public var info:SceneInfoEditable;

		/**
		 * 根据参数创建一个新的场景文档
		 * @param file
		 * @param raw
		 *
		 */
		public function SceneDocument(file:File, raw:Object)
		{
			super(file, raw);

			// 自动处理 ID
			if (file && !("id" in raw))
			{
				raw.id = file.name.split(".")[0];
			}
			info = new SceneInfoEditable(raw);
			focus.x = info.width / 2;
			focus.y = info.height / 2;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			if (isNew)
			{
				return info.id;
			}
			return super.name;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get rawString():String
		{
			return JSON.stringify(info);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get viewClass():Class
		{
			return SceneDocumentView;
		}
	}
}
