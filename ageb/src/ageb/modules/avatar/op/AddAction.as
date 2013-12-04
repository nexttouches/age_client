package ageb.modules.avatar.op
{
	import age.data.FrameLayerType;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * <p>添加动作。新建的动作将包含一个一帧的动画图层</p>
	 * @author zhanghaocong
	 *
	 */
	public class AddAction extends AvatarOPBase
	{
		/**
		 * 新建的动作名字
		 */
		private var actionName:String;

		/**
		 * 执行前当前的动作名字，在 saveOld 中记录。撤销时将恢复到该动作。
		 */
		private var oldActionName:String;

		/**
		 * 新建的动作，在 saveOld 中创建
		 */
		private var target:ActionInfoEditable;

		/**
		 * consturctor
		 * @param doc 操作的文档对象
		 * @param actionName 新建的动作名字
		 *
		 */
		public function AddAction(doc:Document, actionName:String)
		{
			super(doc);
			this.actionName = actionName;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			avatar.actionsVectorList.addItem(target);
			object.actionName = target.name;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldActionName = action ? action.name : null;
			target = new ActionInfoEditable();
			target.name = actionName;
			var layer:FrameLayerInfoEditable = new FrameLayerInfoEditable(null, target);
			layer.type = FrameLayerType.ANIMATION;
			layer.name = "animation1";
			layer.addFrame(new FrameInfoEditable({ isKeyframe: true }));
			target.addLayer(layer);
			layer = new FrameLayerInfoEditable(null, target);
			layer.type = FrameLayerType.VIRTUAL;
			layer.name = "hitBox";
			layer.addFrame(new FrameInfoEditable({ isKeyframe: true, box: avatar.size.toJSON(null)}));
			target.addLayer(layer);
			target.updateNumFrames();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			object.actionName = oldActionName;
			avatar.actionsVectorList.removeItem(target);
		}

		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "新建动作 (" + target.name + ")";
		}
	}
}
