package ageb.modules.avatar.op
{
	import ageb.modules.document.Document;

	/**
	 * 修改图层名字
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameLayerName extends AvatarOPBase
	{
		/**
		 * 新名字
		 */
		private var newName:String;

		/**
		 * 要修改的图层索引
		 */
		private var layerIndex:int;

		/**
		 * 旧名字
		 */
		private var oldName:String;

		/**
		 * constructor
		 * @param doc
		 *
		 */
		public function ChangeFrameLayerName(doc:Document, layerIndex:int, newName:String)
		{
			super(doc);
			this.layerIndex = layerIndex;
			this.newName = newName;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			action.getLayerAt(layerIndex).setName(newName);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldName = action.getLayerAt(layerIndex).name;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			action.getLayerAt(layerIndex).setName(oldName);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return "图层改名 (" + newName + ")";
		}
	}
}
