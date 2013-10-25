package ageb.modules.avatar.op
{
	import ageb.modules.document.Document;

	/**
	 * 修改图层类型
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameLayerType extends AvatarOPBase
	{
		/**
		 * 新名字
		 */
		private var newType:int;

		/**
		 * 要修改的图层索引
		 */
		private var layerIndex:int;

		/**
		 * 旧名字
		 */
		private var oldType:int;

		/**
		 * constructor
		 * @param doc
		 *
		 */
		public function ChangeFrameLayerType(doc:Document, layerIndex:int, newType:int)
		{
			super(doc);
			this.layerIndex = layerIndex;
			this.newType = newType;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			action.getLayerAt(layerIndex).setType(newType);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldType = action.getLayerAt(layerIndex).type;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			action.getLayerAt(layerIndex).setType(oldType);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return "图层改类型 (" + newType + ")";
		}
	}
}
