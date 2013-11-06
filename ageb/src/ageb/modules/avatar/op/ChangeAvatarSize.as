package ageb.modules.avatar.op
{
	import age.data.Box;
	import ageb.modules.document.Document;

	/**
	 * 修改 AvatarInfo.size 属性
	 * @author zhanghaocong
	 *
	 */
	public class ChangeAvatarSize extends AvatarOPBase
	{
		/**
		 * 新大小
		 */
		public var size:Box;

		/**
		 * 旧大小
		 */
		public var oldSize:Box;

		/**
		 * 创建一个新的 ChangeAvatarSize
		 * @param doc
		 *
		 */
		public function ChangeAvatarSize(doc:Document, size:Box)
		{
			super(doc);
			this.size = size;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function redo():void
		{
			avatar.setSize(size);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function saveOld():void
		{
			oldSize = avatar.size;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function undo():void
		{
			avatar.setSize(oldSize);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return format("修改大小 ({width}, {height}, {depth})", size);
		}
	}
}
