package ageb.modules.tools
{
	import flash.utils.Dictionary;
	import mx.collections.ArrayList;
	import ageb.modules.ModuleBase;
	import ageb.modules.tools.gridBrushClasses.GridBrushTool;
	import ageb.modules.tools.sceneInfoClasses.SceneInfoTool;
	import ageb.modules.tools.testToolClasses.TestTool;
	import ageb.utils.FlashTip;
	import nt.ui.util.ShortcutUtil;
	import org.osflash.signals.Signal;
	import ageb.modules.tools.selectToolClasses.SelectTool;

	/**
	 * 工具模块
	 * @author zhanghaocong
	 *
	 */
	public class ToolsModule extends ModuleBase
	{
		/**
		 * 创建一个新的 ToolsModule
		 *
		 */
		public function ToolsModule()
		{
			super();
		}

		/**
		 * 所有用到的工具类，按钮也会根据该数组进行排序
		 */
		public const TOOL_CLASSES:Vector.<Class> = new <Class>[ SelectTool,
																GridBrushTool, SceneInfoTool,
																TestTool ];

		/**
		 * 初始化工具模块
		 *
		 */
		public function init():void
		{
			for (var i:int = 0; i < TOOL_CLASSES.length; i++)
			{
				addTool(TOOL_CLASSES[i]);
			}
			modules.document.onCurrentDocChange.add(onCurrentDocumentChange);
			selectedIndex = 0;
		}

		/**
		 * 文档切换时调用
		 *
		 */
		private function onCurrentDocumentChange():void
		{
			selectedTool.doc = null;

			if (modules.document.currentDoc)
			{
				var type:Class = modules.document.currentDoc["constructor"];

				for each (var tool:ToolBase in tools)
				{
					if (tool.availableDocs && tool.availableDocs.indexOf(type) == -1)
					{
						if (tool.enabled)
						{
							// 如果当前工具已经在使用了，就切换到默认工具
							selectedTool = toolsArray.getItemAt(0) as ToolBase;
						}
						tool.enabled = false;
					}
					else
					{
						tool.enabled = true;
					}
				}
			}
			// 重新设置文档对象
			selectedTool.doc = modules.document.currentDoc;
		}

		/**
		 * 储存所有工具（快速查询）
		 */
		public var tools:Dictionary = new Dictionary();

		/**
		 * 储存所有工具（数组）
		 */
		public var toolsArray:ArrayList = new ArrayList();

		/**
		 * 添加一个工具
		 * @param tool
		 *
		 */
		public function addTool(toolClass:Class):void
		{
			var t:ToolBase = new toolClass();
			tools[toolClass] = t;
			toolsArray.addItem(t);

			if (t.shortcut)
			{
				ShortcutUtil.register2(t.shortcut, function():void
				{
					if (modules.document.currentDoc && t.availableDocs && t.availableDocs.indexOf(modules.document.currentDoc["constructor"]) != -1)
					{
						selectedTool = t;
					}
				});
			}
			trace("[ToolModule] 增加 " + t);
		}

		/**
		 * 选择工具时广播
		 */
		public var onSelectTool:Signal = new Signal();

		private var _selectedIndex:int = -1;

		/**
		 * 设置或获取当前选中工具的索引
		 * @return
		 *
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			if (value == _selectedIndex)
			{
				return;
			}
			var isShowTip:Boolean = false;

			if (_selectedIndex != -1)
			{
				isShowTip = true;
				selectedTool.isSelected = false;
				selectedTool.doc = null;
			}
			_selectedIndex = value;
			selectedTool.isSelected = true;
			selectedTool.doc = modules.document.currentDoc;

			if (isShowTip)
			{
				FlashTip.show(selectedTool.tooltip);
			}
			onSelectTool.dispatch();
		}

		/**
		 * 设置或获取选中了的工具
		 * @return
		 *
		 */
		public function get selectedTool():ToolBase
		{
			return toolsArray.getItemAt(_selectedIndex) as ToolBase;
		}

		public function set selectedTool(value:ToolBase):void
		{
			selectedIndex = toolsArray.getItemIndex(value);
		}

		/**
		 * 根据类型获得工具<br>
		 * 可以通过 ToolBase.isSelected 属性查看是否已选中<br>
		 * 要获得当前选中的工具，可以使用 selectedTool 属性
		 * @param toolClass
		 * @return
		 *
		 */
		public function getTool(toolClass:Class):ToolBase
		{
			return tools[toolClass] as ToolBase;
		}
	}
}
