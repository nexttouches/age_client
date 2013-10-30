package ageb.utils
{
	import flash.events.Event;
	import flash.ui.ContextMenuItem;

	/**
	 * 菜单项
	 * @author zhanghaocong
	 *
	 */
	public class MenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function MenuItem()
		{
			contextMenuItem.addEventListener(Event.SELECT, onSelect);
		}

		private var _contextMenuItem:ContextMenuItem;

		/**
		 * 实际使用的 ContextMenuItem 对象
		 * @return
		 *
		 */
		public function get contextMenuItem():ContextMenuItem
		{
			if (!_contextMenuItem)
			{
				_contextMenuItem = new ContextMenuItem("", false);
			}
			return _contextMenuItem;
		}

		/**
		 * 打开时调用
		 *
		 */
		public function onShow():void
		{
			throw new Error("需子类实现");
		}

		/**
		 * 隐藏时调用
		 *
		 */
		public function onClose():void
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
	}
}
