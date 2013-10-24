package ageb.modules.shortcut
{
	import flash.ui.Keyboard;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	import spark.components.Panel;
	import spark.components.TitleWindow;
	import ageb.modules.ModuleBase;
	import nt.ui.util.ShortcutUtil;

	public class ShortcutModule extends ModuleBase
	{
		public function ShortcutModule()
		{
			super();
		}

		public function init(shortcuts:XMLList):void
		{
			ShortcutUtil.init(modules.root.stage);

			for each (var menu:XML in shortcuts)
			{
				if (menu.hasOwnProperty("@shortcut"))
				{
					const CLASS:int = 0;
					const METHOD:int = 1;
					var combo:String = menu.@shortcut;
					var command:String = menu.@command;
					var parseResult:Array = command.split(".");

					if (command)
					{
						traceex("[ShortcutModule] 注册 {1} ({0})", combo, command);
						register(combo, modules[parseResult[CLASS]][parseResult[METHOD]]);
					}
				}
			}
			// 注册按 ESC 就可以关闭当前窗口的快捷键
			register("ESCAPE", closeCurrentPanel);
		}

		public function closeCurrentPanel():void
		{
			// 没做好
		}

		public var register:Function = ShortcutUtil.register2;
	}
}
