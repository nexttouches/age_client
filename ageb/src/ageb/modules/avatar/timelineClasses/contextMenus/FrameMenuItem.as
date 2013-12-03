package ageb.modules.avatar.timelineClasses.contextMenus
{
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.Modules;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.AvatarDocument;
	import ageb.utils.MenuItem;

	/**
	 * 表示一个帧右键菜单
	 * @author zhanghaocong
	 *
	 */
	public class FrameMenuItem extends MenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function FrameMenuItem()
		{
			super();
		}

		/**
		 * 当前菜单操作的 ActionInfoEditable
		 */
		public var info:ActionInfoEditable;

		/**
		 * 当前菜单对应的格子
		 */
		public var cells:Vector.<CellPosition>;

		/**
		 * 返回 info.selectedFrames
		 * @return
		 *
		 */
		protected function get frames():Vector.<FrameInfoEditable>
		{
			return info.selectedFrames;
		}

		/**
		 * 返回 info.selectedKeyframes
		 * @return
		 *
		 */
		protected function get keyframes():Vector.<FrameInfoEditable>
		{
			return info.selectedKeyframes;
		}

		/**
		 * 当前文档
		 * @return
		 *
		 */
		protected function get doc():AvatarDocument
		{
			return Modules.getInstance().document.currentDoc as AvatarDocument;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onClose():void
		{
			// 解引用
			info = null;
			cells = null;
		}

		/**
		* @inheritDoc
		*
		*/
		override public function onShow():void
		{
			// 默认启用
			contextMenuItem.enabled = true;
		}
	}
}
