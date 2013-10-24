package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.Modules;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.AvatarDocument;

	/**
	 * 表示一个帧右键菜单
	 * @author zhanghaocong
	 *
	 */
	public class FrameContextMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function FrameContextMenuItem()
		{
			item.addEventListener(Event.SELECT, onSelect);
		}

		/**
		 * 当前菜单操作的 ActionInfoEditable
		 */
		public var info:ActionInfoEditable;

		/**
		 * 当前菜单对应的格子
		 */
		public var cells:Vector.<CellPosition>;

		private var _item:ContextMenuItem;

		/**
		 * 实际使用的 ContextMenuItem 对象
		 * @return
		 *
		 */
		public function get item():ContextMenuItem
		{
			if (!_item)
			{
				_item = new ContextMenuItem("", false);
			}
			return _item;
		}

		/**
		 * 刷菜单
		 * @param info
		 * @param cells
		 * @return
		 *
		 */
		public function validate():void
		{
			throw new Error("需子类实现");
		}

		/**
		 * 用户选择当前菜单时调用
		 * @param event
		 *
		 */
		protected function onSelect(event:Event):void
		{
			throw new Error("需子类实现");
		}

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
		 * 当前文档
		 * @return
		 *
		 */
		protected function get doc():AvatarDocument
		{
			return Modules.getInstance().document.currentDoc as AvatarDocument;
		}
	}
}
