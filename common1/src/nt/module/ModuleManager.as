package nt.module
{
	public var ModuleManager:IModuleManager = new ModuleManagerImpl();
}
import flash.display.Stage;
import flash.errors.IllegalOperationError;
import flash.system.Capabilities;
import flash.utils.Dictionary;
import nt.module.IModule;
import nt.module.IModuleManager;

class ModuleManagerImpl implements IModuleManager
{
	private var _list:Dictionary = new Dictionary();

	public function get list():Dictionary
	{
		return _list;
	}

	private var _stage:Stage;

	public function get stage():Stage
	{
		return _stage;
	}

	private var _config:Object;

	public function get config():Object
	{
		return _config;
	}

	public function init(stage:Stage, config:Object = null):void
	{
		this._stage = stage;
		this._config = config;
	}

	public function install(moduleClass:Class):IModule
	{
		if (Capabilities.isDebugger)
		{
			if (!_stage)
			{
				throw new IllegalOperationError("尚未初始化");
			}
		}

		if (has(moduleClass))
		{
			throw new Error("不能重复安装模块 " + moduleClass);
		}
		_list[moduleClass] = new moduleClass();
		traceex("[ModuleManager] {0} installed.", _list[moduleClass].toString());
		_list[moduleClass].install(this);
		return _list[moduleClass];
	}

	public function uninstall(moduleClass:Class):void
	{
		if (!has(moduleClass))
		{
			throw new Error("删除失败：找不到指定的模块 " + moduleClass);
		}
		get(moduleClass).uninstall();
		traceex("[ModuleManager] {0} uninstalled.", _list[moduleClass].toString());
		delete _list[moduleClass];
	}

	public function get(moduleClass:Class):IModule
	{
		if (!_list[moduleClass])
		{
			throw ReferenceError("找不到指定的模块 " + moduleClass);
		}
		return _list[moduleClass];
	}

	public function has(moduleClass:Class):Boolean
	{
		return _list[moduleClass] != null;
	}
}
