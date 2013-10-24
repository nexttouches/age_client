package ageb.modules.tools
{
	import mx.events.FlexEvent;
	import spark.events.IndexChangeEvent;

	/**
	 * 工具面板
	 * @author zhanghaocong
	 *
	 */
	public class ToolsPanel extends ToolsPanelTemplate
	{
		/**
		 * 创建一个新的工具面板
		 *
		 */
		public function ToolsPanel()
		{
			super();
		}

		/**
		 * 选择工具时的回调
		 *
		 */
		protected function onSelectTool():void
		{
			icons.selectedIndex = tools.selectedIndex;
		}

		/**
		 * 不可见时调用
		 * @param event
		 *
		 */
		override protected function onHide(event:FlexEvent):void
		{
			tools.onSelectTool.remove(onSelectTool);
		}

		/**
		 * 可见时调用
		 * @param event
		 *
		 */
		override protected function onShow(event:FlexEvent):void
		{
			addOptionPanels();
			tools.onSelectTool.add(onSelectTool);
			onSelectTool();
		}

		/**
		 * 视图对象创建完毕时调用
		 * @param event
		 *
		 */
		override protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(event.type, arguments.callee);
			addOptionPanels();
			tools.onSelectTool.add(onSelectTool);
			onSelectTool();
		}

		private function addOptionPanels():void
		{
			for (var i:int = 0; i < tools.toolsArray.length; i++)
			{
				options.addElement(ToolBase(tools.toolsArray.getItemAt(i)));
			}
		}

		/**
		 * 用户点击工具图标时调用
		 * @param event
		 *
		 */
		override protected function buttons_onChange(event:IndexChangeEvent):void
		{
			tools.selectedIndex = event.newIndex;
		}

		/**
		 * 获得工具模块的引用
		 * @return
		 *
		 */
		public function get tools():ToolsModule
		{
			return modules.tools;
		}
	}
}
