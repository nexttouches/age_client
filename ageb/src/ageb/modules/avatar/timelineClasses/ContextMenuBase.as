package ageb.modules.avatar.timelineClasses.contextMenus
{
	import flash.ui.ContextMenu;
	import ageb.utils.MenuItem;

	public class ContextMenuBase
	{
		/**
		 * 本次使用的 ContextMenu 对象
		 */
		protected var cm:ContextMenu;

		/**
		 * 菜单列表
		 */
		protected var menus:Vector.<MenuItem> = new Vector.<MenuItem>;

		public function ContextMenuBase()
		{
		}
	}
}
