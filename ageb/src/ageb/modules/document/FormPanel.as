package ageb.modules.document
{
	import mx.events.FlexEvent;
	import spark.components.Panel;
	import spark.layouts.VerticalLayout;
	import ageb.modules.Modules;

	/**
	 * 出现在 DocumentView 中的小面板基类
	 * @author zhanghaocong
	 *
	 */
	public class FormPanel extends Panel
	{
		/**
		 * 创建一个新的 FormPanel
		 *
		 */
		public function FormPanel()
		{
			super();
			var l:VerticalLayout = new VerticalLayout();
			l.paddingBottom = 6;
			l.paddingTop = 5;
			l.paddingLeft = l.paddingRight = 6;
			layout = l;
			addEventListener(FlexEvent.ADD, onAdd);
			addEventListener(FlexEvent.REMOVE, onRemove);
		}

		protected function onRemove(event:FlexEvent):void
		{
			documentView.removeEventListener(FlexEvent.SHOW, onShow);
			documentView.removeEventListener(FlexEvent.HIDE, onHide);
		}

		protected function onAdd(event:FlexEvent):void
		{
			documentView.addEventListener(FlexEvent.SHOW, onShow);
			documentView.addEventListener(FlexEvent.HIDE, onHide);
		}

		protected function onHide(event:FlexEvent):void
		{
		}

		protected function onShow(event:FlexEvent):void
		{
		}

		/**
		 * 获得所有模块
		 * @return
		 *
		 */
		public function get modules():Modules
		{
			return Modules.getInstance();
		}

		/**
		 * 当前面板关联的文档视图
		 * @return
		 *
		 */
		public function get documentView():DocumentView
		{
			return parentDocument as DocumentView;
		}
	}
}
