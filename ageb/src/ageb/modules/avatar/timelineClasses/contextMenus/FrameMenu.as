package ageb.modules.avatar.timelineClasses.contextMenus
{
	import spark.components.gridClasses.CellPosition;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.utils.Menu;

	/**
	 * 右键点击时间轴时打开的菜单
	 * @author zhanghaocong
	 *
	 */
	public class FrameMenu extends Menu
	{
		/**
		 * constructor
		 *
		 */
		public function FrameMenu()
		{
			// 配置菜单项
			add(new InsertFrameMenu);
			add(new RemoveFrameMenu);
			addSeparator();
			add(new InsertKeyframeMenu);
			add(new InsertEmptyKeyframeMenu);
			add(new RemoveKeyframeMenu);
			super();
		}

		/**
		 * @private
		 */
		private static var instance:FrameMenu;

		/**
		 * 获得 FrameContextMenu 唯一实例
		 * @return
		 *
		 */
		private static function getInstance():FrameMenu
		{
			return instance ||= new FrameMenu();
		}

		/**
		 * 根据参数显示菜单
		 * @param info 当前动作
		 * @param cells 选中的格子
		 *
		 */
		public static function show(info:ActionInfoEditable, cells:Vector.<CellPosition>):void
		{
			// 遍历设置好菜单项需要的数据
			getInstance().forEach(function(m:FrameMenuItem, ... args):void
			{
				m.info = info;
				m.cells = cells;
			});
			// 显示菜单
			getInstance().show();
		}
	}
}
