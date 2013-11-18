package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import nt.lib.util.setupStage;

	/**
	 * 客户端主程序
	 * @author zhanghaocong
	 *
	 */
	[SWF(frameRate="60", width="1000", height="600")]
	public class main extends Sprite
	{
		/**
		 * 加载器的皮肤类
		 */
		public var skin:Sprite;

		/**
		 * constructor
		 *
		 */
		public function main()
		{
			super();

			// 如直接启动则设置 stage 相关属性
			if (stage)
			{
				setupStage(stage);
				init();
			}
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
