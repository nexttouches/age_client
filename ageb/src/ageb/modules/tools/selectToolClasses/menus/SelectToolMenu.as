package ageb.modules.tools.selectToolClasses.menus
{
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.ae.LayerRendererEditable;
	import ageb.utils.Menu;

	/**
	 * 切换到 SelectTool 时使用的右键菜单
	 * @author zhanghaocong
	 *
	 */
	public class SelectToolMenu extends Menu
	{
		/**
		 * constructor
		 *
		 */
		public function SelectToolMenu()
		{
			add(new AddObjectMeun);
			add(new AddBGMenu);
			super();
		}

		/**
		* @private
		*/
		private static var instance:SelectToolMenu;

		/**
		 * 获得 SelectToolMenu 唯一实例
		 * @return
		 *
		 */
		private static function getInstance():SelectToolMenu
		{
			return instance ||= new SelectToolMenu();
		}

		/**
		 * 根据参数显示菜单
		 * @param info 当前图层
		 *
		 */
		public static function show(lr:LayerRendererEditable):void
		{
			// 遍历设置好菜单项需要的数据
			getInstance().forEach(function(m:SelectToolMenuItem, ... args):void
			{
				m.lr = lr;
			});
			// 显示菜单
			getInstance().show();
		}
	}
}
