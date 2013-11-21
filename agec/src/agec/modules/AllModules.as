package agec.modules
{
	import flash.display.Stage;
	import agec.modules.age.AGEModule;

	/**
	 * 所有模块
	 * @author zhanghaocong
	 *
	 */
	public class AllModules
	{
		/**
		 * constructor
		 *
		 */
		public function AllModules()
		{
		}

		/**
		 * AGE 模块
		 */
		public var age:AGEModule = new AGEModule

		/**
		* 初始化所有模块
		* @param root 根视图
		*
		*/
		public function init(nativeStage:Stage):void
		{
			trace("[AllModules] 正在初始化…");
			this.nativeStage = nativeStage;
			age.init(nativeStage);
		}

		/**
		 * Stage
		 */
		public var nativeStage:Stage;

		private static var instance:AllModules;

		/**
		 * 获得 AllModules 实例
		 * @return
		 *
		 */
		public static function getInstance():AllModules
		{
			return instance ||= new AllModules();
		}
	}
}
