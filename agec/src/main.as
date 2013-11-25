package
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import agec.modules.AllModules;
	import nt.lib.util.assert;

	/**
	 * 客户端主程序，不可直接启动，请从 preloader 启动
	 * @author zhanghaocong
	 *
	 */
	[SWF(frameRate="60", width="1000", height="600")]
	public class main extends Sprite
	{
		/**
		 * constructor
		 *
		 */
		public function main()
		{
			super();
			assert(!stage, "不可作为文档类直接启动，请从 preloader 启动");
		}

		/**
		 * @private
		 *
		 */
		public function init(stage:Stage):void
		{
			// 初始化 AllModules
			AllModules.getInstance().init(stage);
		}
	}
}
