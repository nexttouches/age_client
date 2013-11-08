package ageb.modules.avatar.op
{
	import ageb.modules.document.Document;

	/**
	 * 修改动作的 atals
	 * @author zhanghaocong
	 *
	 */
	public class ChangeActionAtlas extends AvatarOPBase
	{
		/**
		 * 旧值
		 */
		public var oldAtlas:String;

		/**
		 * 新值
		 */
		public var atlas:String;

		/**
		 * constructor
		 * @param doc
		 * @param atlas
		 *
		 */
		public function ChangeActionAtlas(doc:Document, atlas:String)
		{
			super(doc);
			this.atlas = atlas;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function redo():void
		{
			action.setAtlas(atlas);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function saveOld():void
		{
			oldAtlas = action.atlas;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function undo():void
		{
			action.setAtlas(oldAtlas);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return format("修改 atlas ({atlas})", this);
		}
	}
}
