package
{
	import flash.display.Sprite;
	import nt.lib.util.assert;

	/**
	 * 客户端主程序
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
			assert(!stage, "不可直接启动");
		}

		/**
		 * @private
		 *
		 */
		public function init(skin:Sprite = null):void
		{
			this.skin = skin;
			trace("启动 main");
			// TODO 加载配置和资源
		}
	}
}
