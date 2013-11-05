package
{
	import flash.display.Sprite;
	import age.AGE;
	import age.renderers.SceneRenender;

	/**
	 * 客户端主程序
	 * @author zhanghaocong
	 *
	 */
	public class main extends Sprite
	{
		/**
		 * constructor
		 *
		 */
		public function main()
		{
			AGE.start(stage, SceneRenender);
		}
	}
}
