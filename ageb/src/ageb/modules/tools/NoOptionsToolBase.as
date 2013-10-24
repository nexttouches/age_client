package ageb.modules.tools
{
	import spark.components.Label;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.layouts.VerticalLayout;

	/**
	 * 为没有选项的工具提供一个基类
	 * @author zhanghaocong
	 *
	 */
	public class NoOptionsToolBase extends ToolBase
	{
		/**
		 * 创建一个新的 NoOptionsToolBase
		 * @param name
		 * @param shortcut
		 * @param icon
		 * @param availableDocuments
		 *
		 */
		public function NoOptionsToolBase(name:String = "无选项工具", shortcut:String = null, icon:Class = null, availableDocuments:Vector.<Class> = null)
		{
			super(name, shortcut, icon, availableDocuments);
			var l:VerticalLayout = new VerticalLayout();
			l.horizontalAlign = HorizontalAlign.CENTER;
			l.verticalAlign = VerticalAlign.MIDDLE;
			layout = l;
			var label:Label = new Label();
			label.text = "没有附加选项";
			addElement(label);
		}
	}
}
