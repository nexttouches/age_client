package ageb.modules.avatar.op
{
	import ageb.modules.document.Document;

	/**
	 * 修改动作 fps
	 * @author zhanghaocong
	 *
	 */
	public class ChangeActionFPS extends AvatarOPBase
	{
		/**
		 * 旧 fps
		 */
		public var oldFPS:int;

		/**
		 * 新 fps
		 */
		public var fps:int;

		/**
		 * 创建一个新的 ChangeActionFPS
		 * @param doc 相关文档
		 * @param fps 新 fps
		 *
		 */
		public function ChangeActionFPS(doc:Document, fps:int)
		{
			super(doc);
			this.fps = fps;
		}

		/**
		* @inheritDoc
		* @return
		*
		*/
		override public function redo():void
		{
			action.setFPS(fps);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function saveOld():void
		{
			oldFPS = action.fps;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function undo():void
		{
			action.setFPS(oldFPS);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return format("修改 FPS ({fps})", this);
		}
	}
}
