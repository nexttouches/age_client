package ageb.modules.tools.selectToolClasses.menus
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
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
			FileUtil.browseFile(sceneInfo.expectFolder.nativePath, [ new FileFilter("PNG File", "*.png")], onComplete);
		}

		/**
		 * 选中文件后调用
		 * @param f
		 *
		 */
		private function onComplete(f:File):void
		{
			trace(f.nativePath);
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
