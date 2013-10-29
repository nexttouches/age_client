package ageb.modules.avatar.op
{
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 重命名动作
	 * @author zhanghaocong
	 *
	 */
	public class RenameAction extends AvatarOPBase
	{
		/**
		 * 新名字
		 */
		private var newName:String;

		/**
		 * 要修改的动作
		 */
		private var target:ActionInfoEditable;

		/**
		 * 旧名字
		 */
		private var oldName:String;

		/**
		 * constructor
		 * @param doc
		 * @param target
		 * @param newActionName
		 *
		 */
		public function RenameAction(doc:Document, target:ActionInfoEditable, newActionName:String)
		{
			super(doc);
			this.target = target;
			this.newName = newActionName;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			target.setName(newName);
			avatar.actionsVectorList.itemUpdated(target, "name", oldName, newName);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldName = target.name;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			target.setName(oldName);
			avatar.actionsVectorList.itemUpdated(target, "name", newName, oldName);
		}

		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "重命名动作 (" + newName + ")";
		}
	}
}
