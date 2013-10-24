package nt.ui.containers
{
	import avmplus.getQualifiedClassName;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	import nt.lib.reflect.Type;
	import nt.lib.reflect.Variable;
	import nt.ui.core.ISkinnable;
	import nt.ui.util.SkinParser;

	/**
	 * SkinnableContainer 表示一个可换皮的组件容器
	 * @author KK
	 * @see game.ui.core.ISkinnableComponent
	 */
	public class SkinnableContainer extends AbstractLayoutContainer implements ISkinnable
	{
		protected var skin:DisplayObject;

		public function SkinnableContainer(skin:*)
		{
			super();
			SkinParser.parse(this, skin);
		}

		public function setSkin(value:DisplayObject):void
		{
			skin = value;
			$addChild(value);
		}
	}
}
