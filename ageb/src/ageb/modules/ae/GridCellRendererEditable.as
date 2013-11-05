package ageb.modules.ae
{
	import age.renderers.GridCellRenderer;

	/**
	 * GridCellRenderer 编辑器专用版
	 * @author zhanghaocong
	 *
	 */
	public class GridCellRendererEditable extends GridCellRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function GridCellRendererEditable()
		{
			super();
			touchable = true;
		}
	}
}
