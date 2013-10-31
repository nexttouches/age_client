package ageb.modules.document
{
	import flash.events.MouseEvent;
	import mx.core.ClassFactory;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	import spark.layouts.BasicLayout;

	/**
	 * 历史面板
	 * @author zhanghaocong
	 *
	 */
	public class HistoryPanel extends FormPanel
	{
		public var list:List;

		/**
		 * constructor
		 *
		 */
		public function HistoryPanel()
		{
			super();
			layout = new BasicLayout();
			title = "历史记录";
			list = new List();
			list.itemRenderer = new ClassFactory(HistoryPanelItemRenderer);
			list.percentWidth = 100;
			list.percentHeight = 100;
			list.addEventListener(IndexChangeEvent.CHANGE, onChange);
			list.setStyle("verticalScrollPolicy", "on");
			list.addEventListener(MouseEvent.ROLL_OVER, list_onRollOver);
			addElement(list);
		}

		private var _doc:Document;

		/**
		 * 设置或获取当前关联的文档
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
				title = "历史记录";
				list.dataProvider = null;
				list.validateNow(); // 必须调用 validateNow，否则滚动条会不见
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

		/**
		 * @private
		 *
		 */
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

		/**
		 * @private
		 *
		 */
		protected function list_onRollOver(event:MouseEvent):void
		{
			list.setFocus();
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
