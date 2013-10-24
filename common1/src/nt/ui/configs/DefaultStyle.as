package nt.ui.configs
{
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import nt.lib.util.FontUtil;

	public class DefaultStyle
	{
		public static var FontName:String = FontUtil.getAvailableFont([ "宋体",
																		"微软雅黑",
																		"华文黑体" ]);

		public static var Font:FontDescription = new FontDescription(FontName);

		public static var FontBold:FontDescription = new FontDescription(FontName, FontWeight.BOLD);

		public static var Format:ElementFormat = new ElementFormat(Font, 12, 0xBABABA);

		public static var FormatBold:ElementFormat = new ElementFormat(FontBold, 12, 0xBABABA);

		/**
		 * PushButton 使用的默认皮肤
		 */
		public static var PushButtonSkin:Class;

		/**
		 * Panel 使用的默认皮肤
		 */
		public static var PanelSkin:Class;

		/**
		 * FramePanel 使用的默认皮肤
		 */
		public static var FramePanelSkin:Class;

		/**
		 * InputText 使用的默认皮肤
		 */
		public static var InputTextSkin:Class;

		/**
		 * VSlider 使用的默认皮肤
		 */
		public static var VSliderSkin:Class;

		/**
		 * HSlider 使用的默认皮肤
		 */
		public static var HSliderSkin:Class;

		/**
		 * VScrollBar 使用的默认皮肤
		 */
		public static var VScrollBarSkin:Class;

		/**
		 * HScrollBarSkin 使用的默认皮肤
		 */
		public static var HScrollBarSkin:Class;

		/**
		 * ToolTipBg
		 */
		public static var ToolTipBg:Class;
	}
}
