package nt.module
{
	import flash.display.Stage;
	import flash.utils.Dictionary;

	/**
	 * 模块管理器
	 * @author KK
	 *
	 */
	public interface IModuleManager
	{
		/**
		 * 初始化 IModuleManager
		 * @param s
		 *
		 */
		function init(s:Stage, config:Object = null):void;
		/**
		 * 安装指定的模块类，模块类必须实现 IModule
		 * @param moduleClass
		 * @return
		 *
		 */
		function install(moduleClass:Class):IModule;
		/**
		 * 卸载指定的模块类，模块必须已安装
		 * @param moduleClass
		 *
		 */
		function uninstall(moduleClass:Class):void;
		/**
		 * 获得已安装的模块
		 * @param moduleClass
		 * @return
		 *
		 */
		function get(moduleClass:Class):IModule;
		/**
		 * 检查是否有指定的模块已安装
		 * @param moduleClass
		 * @return
		 *
		 */
		function has(moduleClass:Class):Boolean;
		/**
		 * 返回 init 传入的 Starling 实例
		 * @return
		 *
		 */
		function get stage():Stage;
		/**
		 * 当前已安装的模块列表
		 * @return
		 *
		 */
		function get list():Dictionary;
		/**
		 * 各模块的配置文件
		 * @return
		 *
		 */
		function get config():Object;
	}
}
