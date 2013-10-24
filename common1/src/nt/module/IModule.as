package nt.module
{

	public interface IModule
	{
		/**
		 * 安装模块
		 * @param installer
		 *
		 */
		function install(host:IModuleManager):void;
		/**
		 * 卸载模块
		 * @param installer
		 *
		 */
		function uninstall():void;
		/**
		 * 指示模块是否已被安装
		 * @return
		 *
		 */
		function get installed():Boolean;
	}
}
