package ageb.modules.avatar.frameInfoClasses.skinClasses
{
	import spark.components.BorderContainer;
	import spark.layouts.VerticalLayout;

	/**
	 * 可以把属性分组显示的 BorderContainer<br>
	 * 具有默认 padding，percentWidth 等
	 * @author zhanghaocong
	 *
	 */
	public class PropertyGroup extends BorderContainer
	{
		/**
		 * 创建一个新的 PropertyGroup
		 *
		 */
		public function PropertyGroup()
		{
			super();
			const padding:Number = 4;
			const l:VerticalLayout = new VerticalLayout();
			l.paddingBottom = padding;
			l.paddingLeft = padding;
			l.paddingRight = padding;
			l.paddingTop = padding;
			layout = l;
			const size:int = 100;
			percentWidth = size;
		}
	}
}
