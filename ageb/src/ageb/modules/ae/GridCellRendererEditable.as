package ageb.modules.ae
{
	import age.renderers.GridCellRenderer;
	import starling.textures.Texture;

	public class GridCellRendererEditable extends GridCellRenderer
	{
		public function GridCellRendererEditable(texture:Texture = null)
		{
			super(texture);
			touchable = true;
		}
	}
}
