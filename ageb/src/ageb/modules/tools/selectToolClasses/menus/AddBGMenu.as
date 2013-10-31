package ageb.modules.tools.selectToolClasses.menus
{
	import flash.events.Event;
	import age.assets.LayerType;
	import ageb.utils.FileUtil;

	/**
	 * 添加背景菜单
	 * @author zhanghaocong
	 *
	 */
	public class AddBGMenu extends SelectToolMenuItem
	{
		/**
		 * constructor
		 *
		 */
		public function AddBGMenu()
		{
			super();
			contextMenuItem.caption = "添加背景";
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onSelect(event:Event):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			contextMenuItem.enabled = lr.info.type == LayerType.BG;
		}
	}
}
