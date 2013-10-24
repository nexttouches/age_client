package ageb.modules.document
{
	import mx.core.ClassFactory;
	import spark.components.List;
	import spark.components.ScrollSnappingMode;
	import spark.events.IndexChangeEvent;
	import spark.layouts.BasicLayout;

	public class HistoryPanel extends FormPanel
	{
		public var list:List;

		private var _doc:Document;

		public function get doc():Document
		{
			return _doc;
		}

		public function set doc(value:Document):void
		{
			if (_doc)
			{
				title = "历史记录";
				list.dataProvider = null;
				_doc.onHistoryCursorChange.remove(doc_onHistoryCursorChange);
			}
			_doc = value;

			if (_doc)
			{
				list.dataProvider = _doc.histores;
				_doc.onHistoryCursorChange.add(doc_onHistoryCursorChange);
				doc_onHistoryCursorChange();
			}
		}

		private function doc_onHistoryCursorChange():void
		{
			// Workaround:
			// 数据源发生变化时，需要马上调用 validateNow
			// 然后再操作 selectedIndex 和 ensureIndexIsVisible
			// 否则 ensureIndexIsVisible 将不会滚到正确位置
			list.validateNow();
			list.selectedIndex = _doc.historyCursor;
			list.ensureIndexIsVisible(_doc.historyCursor);
			title = format("历史记录 ({numHistores})", _doc);
		}

		public function HistoryPanel()
		{
			super();
			layout = new BasicLayout();
			title = "历史记录";
			// FIXME onRollOver 时强制聚焦
		}

		override protected function createChildren():void
		{
			super.createChildren();
			list = new List();
			list.itemRenderer = new ClassFactory(HistoryPanelItemRenderer);
			list.percentWidth = 100;
			list.percentHeight = 100;
			list.scrollSnappingMode = ScrollSnappingMode.CENTER;
			list.addEventListener(IndexChangeEvent.CHANGE, onChange);
			addElement(list);
		}

		/**
		 * 点击列表项后，更改历史记录
		 * @param event
		 *
		 */
		protected function onChange(event:IndexChangeEvent):void
		{
			callLater(function():void
			{
				// 重做
				if (event.newIndex > _doc.historyCursor)
				{
					while (event.newIndex > _doc.historyCursor)
					{
						_doc.redo();
					}
				}
				// 撤销
				else if (event.newIndex < doc.historyCursor)
				{
					while (event.newIndex < doc.historyCursor)
					{
						_doc.undo();
					}
				}
			});
		}
	}
}
