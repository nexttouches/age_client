package nt.ui.core
{
	import flash.display.DisplayObject;
	import nt.ui.util.SkinParser;

	/**
	 * 可设置皮肤的组件
	 * @author KK
	 *
	 */
	public class SkinnableComponent extends Component implements ISkinnable
	{
		public var skin:DisplayObject;

		public function SkinnableComponent(skin:* = null)
		{
			super();
			SkinParser.parse(this, skin);
		}

		public function setSkin(value:DisplayObject):void
		{
			skin = value;
			addChild(value);
		}
	}
}
