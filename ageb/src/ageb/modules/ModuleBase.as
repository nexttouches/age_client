package ageb.modules
{
	import ageb.modules.settings.SettingsModule;

	/**
	 * 模块模板
	 * @author zhanghaocong
	 *
	 */
	public class ModuleBase
	{
		/**
		 * 创建一个新的 ModuleBase<br>
		 * 在这里是空的构造函数，没什么用
		 *
		 */
		public function ModuleBase()
		{
		}

		/**
		 * 设置或获取设置模块
		 * @return
		 *
		 */
		public function get settings():SettingsModule
		{
			return modules.settings;
		}

		/**
		 * 获取所有 Modules 的唯一实例
		 * @return
		 *
		 */
		final public function get modules():Modules
		{
			return Modules.getInstance();
		}
	}
}
