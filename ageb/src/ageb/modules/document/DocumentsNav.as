package ageb.modules.document
{
	import flash.utils.Dictionary;
	import spark.components.Group;

	/**
	 * 文档视图导航器，包含了所有文档视图
	 * @author zhanghaocong
	 *
	 */
	public class DocumentsNav extends Group
	{
		/**
		 * 储存所有创建了的 DocumentView
		 */
		private var cachedDocumentViews:Dictionary = new Dictionary;

		/**
		 * 创建一个新的文档视图导航器
		 *
		 */
		public function DocumentsNav()
		{
			super();
		}

		/**
		 * 根据参数获得一个视图，如果没有将自动创建，此后将重复使用该视图
		 * @param doc
		 * @return
		 *
		 */
		public function getView(doc:Document):DocumentView
		{
			if (!cachedDocumentViews[doc.viewClass])
			{
				cachedDocumentViews[doc.viewClass] = new doc.viewClass();
				addElement(getView(doc));
			}
			return cachedDocumentViews[doc.viewClass];
		}

		private var _currentView:DocumentView;

		/**
		 * 设置或获取当前视图
		 * @return
		 *
		 */
		public function get currentView():DocumentView
		{
			return _currentView;
		}

		public function set currentView(value:DocumentView):void
		{
			if (_currentView)
			{
				_currentView.visible = false;
					//removeElement(_currentView);
			}
			_currentView = value;

			if (_currentView)
			{
				_currentView.visible = true;
//				addElement(_currentView);
			}
		}
	}
}
