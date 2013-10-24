package nt.ui.components
{
	import nt.ui.configs.DefaultStyle;

	public class HSlider extends VSlider
	{
		public function HSlider(skin:* = null)
		{
			super(skin || DefaultStyle.HSliderSkin, SliderDirection.H);
		}
	}
}
