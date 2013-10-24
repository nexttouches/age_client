package ageb.modules.avatar.timelineClasses
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import spark.components.gridClasses.CellPosition;
	import age.AGE;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.avatar.timelineClasses.contextMenus.ConvertToKeyframeMenu;
	import ageb.modules.avatar.timelineClasses.contextMenus.FrameContextMenuItem;
	import ageb.modules.avatar.timelineClasses.contextMenus.InsertEmptyKeyframeMenu;
	import ageb.modules.avatar.timelineClasses.contextMenus.InsertFrameMenu;
	import ageb.modules.avatar.timelineClasses.contextMenus.InsertKeyframeMenu;
	import ageb.modules.avatar.timelineClasses.contextMenus.RemoveFrameMenu;
	import ageb.modules.avatar.timelineClasses.contextMenus.RemoveKeyframeMenu;
	import nt.lib.util.assert;

	/**
	 * 右键点击时间轴时打开的菜单
	 * @author zhanghaocong
	 *
	 */
	public class FrameContextMenu
	{
		/**
		 * 要打开的 ContextMenu 对象
		 */
		public var cm:ContextMenu;

		/**
		 * 菜单列表
		 */
		public var menus:Vector.<FrameContextMenuItem> = new Vector.<FrameContextMenuItem>;

		/**
		 * constructor
		 *
		 */
		public function FrameContextMenu()
		{
			menus.push(new InsertFrameMenu);
			menus.push(new RemoveFrameMenu);
			menus.push(new InsertKeyframeMenu);
			menus.push(new InsertEmptyKeyframeMenu);
			menus.push(new RemoveKeyframeMenu);
			cm = new ContextMenu();
			cm.addEventListener(Event.SELECT, onMenuClose);

			for (var i:int = 0; i < menus.length; i++)
			{
				cm.addItem(menus[i].item);
			}
		}

		/**
		 * @private
		 */
		private static var instance:FrameContextMenu;

		/**
		 * 当前菜单操作的 ActionInfoEditable
		 */
		private var info:ActionInfoEditable;

		/**
		 * 当前菜单对应的格子
		 */
		private var cells:Vector.<CellPosition>;

		/**
		 * 标记是否已显示
		 */
		private var isShow:Boolean;

		/**
		 * 获得 FrameContextMenu 唯一实例
		 * @return
		 *
		 */
		private static function getInstance():FrameContextMenu
		{
			return instance ||= new FrameContextMenu();
		}

		/**
		 * 根据参数显示菜单
		 * @param info 当前动作
		 * @param cells 选中的格子
		 *
		 */
		public static function show(info:ActionInfoEditable, cells:Vector.<CellPosition>):void
		{
			getInstance().show(info, cells);
		}

		/**
		 * @private
		 * @param info
		 *
		 */
		protected function show(info:ActionInfoEditable, cells:Vector.<CellPosition>):void
		{
			assert(!isShow, "不可重复调用 show");

			for (var i:int = 0; i < menus.length; i++)
			{
				const menu:FrameContextMenuItem = menus[i];
				menu.info = info;
				menu.cells = cells;
				menu.validate();
			}
			isShow = true;
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMenuClose, true, int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMenuClose, true, int.MAX_VALUE);
			cm.display(stage, stage.mouseX, stage.mouseY);
		}

		/**
		 * 菜单关闭时回调
		 * @param ignored
		 *
		 */
		protected function onMenuClose(... ignored):void
		{
			isShow = false;

			// 解引用
			for (var i:int = 0; i < menus.length; i++)
			{
				const menu:FrameContextMenuItem = menus[i];
				menu.info = null;
				menu.cells = null;
			}
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMenuClose, true);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMenuClose, true);
		}

		/**
		 * 舞台
		 * @return
		 *
		 */
		protected function get stage():Stage
		{
			return AGE.s.nativeStage;
		}
	}
}
