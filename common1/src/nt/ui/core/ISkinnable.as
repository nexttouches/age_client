package nt.ui.core
{
	import flash.display.DisplayObject;

	/**
	 * ISkinnable 标记这是一个可换皮的组件，SkinnableComponent 在分析带 [Skin] 的 Metadata 时会做特别照顾<br/>
	 * @author KK
	 * @see SkinnableComponent
	 * @see SkinnableContainer
	 */
	public interface ISkinnable
	{
		function setSkin(value:DisplayObject):void;
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
	}
}
