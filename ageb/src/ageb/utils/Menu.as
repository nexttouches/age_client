package ageb.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import age.AGE;
	import nt.lib.util.assert;

	/**
	 * 菜单
	 * @author zhanghaocong
	 *
	 */
	public class Menu
	{
		/**
		 * 标记是否已显示
		 */
		private var isShow:Boolean;

		/**
		 * 本次使用的 ContextMenu 对象
		 */
		protected var contextMenu:ContextMenu;

		/**
		 * 子菜单列表
		 */
		protected var items:Vector.<MenuItem>;

		/**
		 * constructor
		 *
		 */
		public function Menu()
		{
			contextMenu = new ContextMenu();
			// 点选菜单项时调用 onMenuClose
			contextMenu.addEventListener(Event.SELECT, onMenuClose);

			for (var i:int = 0; i < items.length; i++)
			{
				contextMenu.addItem(items[i].contextMenuItem);
			}
		}

		/**
		 * 显示菜单
		 * @param info
		 *
		 */
		public function show():void
		{
			assert(!isShow, "不可重复调用 show");
			isShow = true;
			// 在菜单外部点击时调用 onMenuClose
			nativeStage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMenuClose, true, int.MAX_VALUE);
			nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, onMenuClose, true, int.MAX_VALUE);

			for (var i:int = 0; i < items.length; i++)
			{
				items[i].mouseX = nativeStage.mouseX;
				items[i].mouseY = nativeStage.mouseY;
				items[i].onShow();
			}
			// 请注意：
			// 调用 display 后会临时中断 as 执行过程
			// 必须放在最后
			// 否则后面的代码可能不会跑
			contextMenu.display(nativeStage, nativeStage.mouseX, nativeStage.mouseY);
		}

		/**
		 * 菜单关闭时回调
		 * @param ignored
		 *
		 */
		protected function onMenuClose(... ignored):void
		{
			isShow = false;
			nativeStage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMenuClose, true);
			nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, onMenuClose, true);

			for (var i:int = 0; i < items.length; i++)
			{
				items[i].onClose();
				items[i].mouseX = NaN;
				items[i].mouseY = NaN;
			}
		}

		/**
		 * 添加一个菜单
		 * @param item
		 *
		 */
		public function add(item:MenuItem):void
		{
			if (!items)
			{
				items = new Vector.<MenuItem>;
			}

			if (isNextItemAddSeparator)
			{
				isNextItemAddSeparator = false;
				item.contextMenuItem.separatorBefore = true;
			}
			items.push(item);
		}

		/**
		 * 删除一个菜单
		 * @param item
		 *
		 */
		public function remove(item:MenuItem):void
		{
			items.splice(items.indexOf(item), 1);
		}

		private var isNextItemAddSeparator:Boolean;

		/**
		 * 添加一个分割线
		 *
		 */
		public function addSeparator():void
		{
			isNextItemAddSeparator = true;
		}

		/**
		 * 遍历 items
		 * @param callback 正确的签名为 function (m:MenuItem, ...args):void; 其中参数 m 可以是任何可以正确转换的 MenuItem 子类
		 *
		 */
		public function forEach(callback:Function):void
		{
			items.forEach(callback);
		}

		/**
		 * 舞台
		 * @return
		 *
		 */
		protected function get nativeStage():Stage
		{
			return AGE.s.nativeStage;
		}
	}
}
