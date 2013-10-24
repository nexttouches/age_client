package ageb.modules.scene.propertyPanelClasses
{
	import spark.components.NavigatorContent;
	import spark.layouts.HorizontalLayout;
	import ageb.modules.Modules;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.document.Document;

	/**
	 * 属性面板内容面板的基类
	 * @author zhanghaocong
	 *
	 */
	public class PropertyPanelContentBase extends NavigatorContent
	{
		/**
		 * 创建新的 PropertyPanelContentBase
		 *
		 */
		public function PropertyPanelContentBase()
		{
			super();
			var l:HorizontalLayout = new HorizontalLayout();
			layout = l;
		}

		protected function resetAllFields():void
		{
		}

		private var _infos:Vector.<ISelectableInfo>;

		/**
		 * 设置或获取 infos
		 * @return
		 *
		 */
		public function get infos():Vector.<ISelectableInfo>
		{
			return _infos;
		}

		public function set infos(value:Vector.<ISelectableInfo>):void
		{
			if (_infos)
			{
				resetAllFields();
			}
			_infos = value;
		}

		/**
		 * 获取 infos 第一个元素
		 * @return
		 *
		 */
		final protected function get info():ISelectableInfo
		{
			return (_infos && _infos.length > 0) ? _infos[0] : null;
		}

		protected function get doc():Document
		{
			return Modules.getInstance().document.currentDoc;
		}
	}
}
