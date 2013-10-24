package nt.ui.components
{
	import nt.ui.configs.DefaultStyle;

	public class HScrollBar extends VScrollBar
	{
		public function HScrollBar(skin:* = null)
		{
			super(skin || DefaultStyle.HScrollBarSkin, SliderDirection.H);
		}
	}
}
