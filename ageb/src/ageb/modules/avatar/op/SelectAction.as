package ageb.modules.avatar.op
{
	import ageb.modules.document.Document;

	/**
	 * 更换动作时使用的 OP
	 * @author zhanghaocong
	 *
	 */
	public class SelectAction extends AvatarOPBase
	{
		/**
		 * 旧动作名称
		 */
		public var oldActionName:String;

		/**
		 * 新动作名称
		 */
		public var actionName:String;

		/**
		 * constructor
		 * @param doc
		 * @param actionName
		 *
		 */
		public function SelectAction(doc:Document, actionName:String)
		{
			super(doc);
			this.actionName = actionName;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function redo():void
		{
			object.actionName = actionName;
			object.currentFrame = 0;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function saveOld():void
		{
			oldActionName = object.actionName;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function undo():void
		{
			object.actionName = oldActionName;
			object.currentFrame = 0;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return "选择动作（" + actionName + "）";
		}
	}
}
