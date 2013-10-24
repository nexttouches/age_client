package ageb.modules.scene
{
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.document.Document;
	import ageb.modules.document.SceneDocument;
	import ageb.modules.scene.propertyPanelClasses.PropertyPanelContentBase;
	import ageb.modules.tools.selectToolClasses.SelectTool;

	/**
	 * 下方属性面板
	 * @author zhanghaocong
	 *
	 */
	public class PropertyPanel extends PropertyPanelTemplate
	{
		private static const DEFAULT_TITLE:String = "属性";

		private static const EMPTY_SELECTION:String = "属性 (没有选择)";

		private static const MULTI_TYPES:String = "属性 (选中了多个类型)";

		/**
		 * 创建一个新的 PropertyPanel
		 *
		 */
		public function PropertyPanel()
		{
			super();
		}

		private var _doc:Document;

		/**
		 * 设置或获取当前关联的文档对象
		 * @return
		 *
		 */
		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			if (_doc)
			{
				sceneDoc.info.onSelectedObjectsChange.remove(onSelectedObjectsChange);
				modules.tools.onSelectTool.remove(onSelectTool);
			}
			_doc = value;

			if (_doc)
			{
				sceneDoc.info.onSelectedObjectsChange.add(onSelectedObjectsChange);
				modules.tools.onSelectTool.add(onSelectTool);
				onSelectTool();
				onSelectedObjectsChange();
			}
		}

		private function onSelectedObjectsChange(trigger:Object = null):void
		{
			// 不可见或触发器为自己时不做任何处理
			if (trigger == this || !visible)
			{
				return;
			}
			// 取出所有选中项
			var objects:Vector.<ISelectableInfo> = sceneDoc.info.selectedObjects;

			// 没有选中任何项
			if (objects.length == 0)
			{
				title = DEFAULT_TITLE;
				panels.selectedChild.enabled = false;
				selectedPropertyPanel.infos = null;
				return;
			}
			// 相同类型处理
			var type:Class = getType(objects);

			if (type)
			{
				panels.selectedIndex = panelDict[type];
				panels.selectedChild.enabled = true;
				title = panels.selectedChild.label;
				selectedPropertyPanel.infos = objects;
				return;
			}
			// 不同类型处理
			panels.selectedChild.enabled = false;
			selectedPropertyPanel.infos = null;
			title = MULTI_TYPES;
		}

		/**
		 * 获得 objects 的类型<br>
		 * 如果他们的类型不一致，返回 null
		 * @param objects
		 * @return
		 *
		 */
		private function getType(objects:Vector.<ISelectableInfo>):Class
		{
			var type:Class;

			// 检查选中的对象是否为同一类型
			for each (var s:ISelectableInfo in objects)
			{
				if (type)
				{
					if (type != s["constructor"])
					{
						return null;
					}
				}
				else
				{
					type = s["constructor"];
				}
			}
			return type;
		}

		private function onSelectTool():void
		{
			visible = modules.tools.selectedTool is SelectTool;
		}

		public function get sceneDoc():SceneDocument
		{
			return _doc as SceneDocument;
		}

		protected function get selectedPropertyPanel():PropertyPanelContentBase
		{
			return panels.selectedChild as PropertyPanelContentBase;
		}
	}
}
