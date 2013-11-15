package
{
	import flash.display.Sprite;

	/**
	 * bootstrap 是最初的引导程序，负责载入 preloader<br/>
	 * 他几乎没有依赖的类，所以很小，这可以保证网页显示的同时就可以显示 bootstrap
	 * @author zhanghaocong
	 *
	 */
	[SWF(frameRate="60", width="1000", height="600")]
	public class bootstrap extends Sprite
	{
		/**
		 * constructor
		 *
		 */
		public function bootstrap()
		{
			super();
			stage.color = 0;
			const preloaderURL:String = loaderInfo.parameters["preloaderURL"];
			var s:Sprite = new Sprite();
			s.buttonMode = true;
			s.graphics.beginFill(0xff0000, 1);
			s.graphics.drawRect(0, 0, 100, 100);
			s.graphics.drawCircle(50, 50, 30);
			s.graphics.endFill();
			addChild(s);
		}
	}
}
