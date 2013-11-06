package ageb.modules.avatar.op
{
	import age.data.ActionInfo;
	import ageb.modules.document.Document;

	/**
	 * 删除动作
	 * @author zhanghaocong
	 *
	 */
	public class RemoveAction extends AvatarOPBase
	{
		private var target:ActionInfo;

		private var oldIndex:int;

		/**
		 * constructor
		 * @param doc
		 * @param target
		 *
		 */
		public function RemoveAction(doc:Document, target:ActionInfo)
		{
			super(doc);
			this.target = target;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			const numActions:int = avatar.numActions - 1;

			if (numActions > 0)
			{
				object.actionName = avatar.actionsVectorList.getItemAt((numActions > oldIndex + 1) ? oldIndex + 1 : numActions - 1).name;
			}
			else
			{
				object.actionName = null;
			}
			object.currentFrame = 0;
			avatar.actionsVectorList.removeItem(target);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldIndex = avatar.actionsVectorList.getItemIndex(target);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			avatar.actionsVectorList.addItemAt(target, oldIndex);
			object.actionName = target.name;
			object.currentFrame = 0;
		}

		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "删除动作 (" + target.name + ")";
		}
	}
}
