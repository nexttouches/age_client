package nt.module
{
	import flash.display.Stage;
	import nt.lib.reflect.Type;

	/**
	 * ModuleBase 是基本模块
	 * @author KK
	 *
	 */
	public class ModuleBase implements IModule
	{
		/**
		 * 如果模块没有被安装，host 为 null
		 */
		protected var host:IModuleManager;

		protected function get stage():Stage
		{
			return host.stage;
		}

		public function ModuleBase()
		{
		}

		/**
		 * 安装模块
		 * @param installer
		 *
		 */
		public function install(host:IModuleManager):void
		{
			this.host = host;
			onInstall();
		}

		protected function onInstall():void
		{
		}

		public function uninstall():void
		{
			host = null;
			onUninstall();
		}

		protected function onUninstall():void
		{
		}

		public function get installed():Boolean
		{
			return host != null;
		}

		public function toString():String
		{
			return Type.of(this).shortname;
		}
	}
}
