package ageb.modules
{
	import ageb.modules.about.AboutModule;
	import ageb.modules.ae.AEModule;
	import ageb.modules.document.DocumentModule;
	import ageb.modules.settings.SettingsModule;
	import ageb.modules.shortcut.ShortcutModule;
	import ageb.modules.tools.ToolsModule;
	import ageb.modules.job.JobModule;

	/**
	 * 储存了所有模块
	 * @author zhanghaocong
	 *
	 */
	public class Modules
	{
		/**
		 * Modules 是单例，请使用 Modules.getInstance 获取
		 *
		 */
		public function Modules(lock:Lock)
		{
		}

		/**
		 * 关于模块
		 */
		public var about:AboutModule = new AboutModule();

		/**
		 * 设置模块
		 */
		public var settings:SettingsModule = new SettingsModule();

		/**
		 * 文档模块
		 */
		public var document:DocumentModule = new DocumentModule();

		/**
		 * 快捷键模块
		 */
		public var shortcut:ShortcutModule = new ShortcutModule();

		/**
		 * AE 模块
		 */
		public var ae:AEModule = new AEModule();

		/**
		 * 工具模块
		 */
		public var tools:ToolsModule = new ToolsModule();

		/**
		 * JOB 模块
		 */
		public var job:JobModule = new JobModule();

		/**
		 * 获得根视图
		 */
		public var root:ageb;

		/**
		 * 初始化所有模块
		 * @param root 根视图
		 *
		 */
		public function init(root:ageb):void
		{
			this.root = root;
		}

		private static var instance:Modules;

		public static function getInstance():Modules
		{
			return instance ||= new Modules(new Lock);
		}
	}
}

class Lock
{
	// stupid
}
