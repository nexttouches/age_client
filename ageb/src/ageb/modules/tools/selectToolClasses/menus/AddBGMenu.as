package ageb.modules.tools.selectToolClasses.menus
{
	import flash.events.Event;
	import age.assets.LayerType;

	public class AddBGMenu extends SelectToolMenuItem
	{
		public function AddBGMenu()
		{
			super();
			contextMenuItem.caption = "添加背景";
		}

		override protected function onSelect(event:Event):void
		{
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			contextMenuItem.enabled = lr.info.type == LayerType.OBJECT;
		}
	}
}
