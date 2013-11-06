package ageb.modules.avatar.op
{
	import age.data.FrameLayerInfo;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	import ageb.modules.document.Document;

	/**
	 * 添加帧图层
	 * @author zhanghaocong
	 *
	 */
	public class AddFrameLayer extends AvatarOPBase
	{
		/**
		 * 本次操作要添加的图层
		 */
		private var newLayerInfo:FrameLayerInfoEditable;

		/**
		 * constructor
		 * @param doc
		 *
		 */
		public function AddFrameLayer(doc:Document)
		{
			super(doc);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			action.addLayer(newLayerInfo);
			newLayerInfo.name = "新建图层 " + newLayerInfo.index;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			newLayerInfo = new FrameLayerInfoEditable();
			// 图层至少包含一个空白关键帧
			newLayerInfo.addFrame(new FrameInfoEditable({ isKeyframe: true }));
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			action.removeLayer(newLayerInfo);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return "添加图层";
		}
	}
}
