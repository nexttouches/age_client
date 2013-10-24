package nt.ui.components
{
	import org.osflash.signals.ISignal;

	public interface IViewport
	{
		/**
		 * 缩放时的  signal
		 * @return
		 *
		 */
		function get onResize():ISignal;
		/**
		 * position 发生变化时的 signal
		 * @return
		 *
		 */
		function get onPositionYChange():ISignal;
		/**
		 * position 发生变化时的 signal
		 * @return
		 *
		 */
		function get onPositionXChange():ISignal;
		/**
		 * contentHeight 变化时的 signal
		 * @return
		 *
		 */
		function get onContentHeightChange():ISignal;
		/**
		 * contentWidth 变化时的 signal
		 * @return
		 *
		 */
		function get onContentWidthChange():ISignal;
		/**
		 * 当前的滚动位置
		 * @return
		 *
		 */
		function get positionY():int;
		function set positionY(value:int):void;
		/**
		 * 当前滚动位置
		 * @return
		 *
		 */
		function get positionX():int;
		function set positionX(value:int):void;
		/**
		 * 内容的高度
		 * @return
		 *
		 */
		function get contentHeight():int;
		/**
		 * 内容的宽度
		 * @return
		 *
		 */
		function get contentWidth():int;
		/**
		 * 视口的高度
		 * @return
		 *
		 */
		function get height():Number;
		function set height(value:Number):void;
		/**
		 * 视口的宽度
		 * @return
		 *
		 */
		function get width():Number;
		function set width(value:Number):void;
		/**
		 * 一次滚动的距离，指的是鼠标点击上下按钮时候要滚动的距离因子
		 * @return
		 *
		 */
		function get delta():int;
		/**
		 * 设置或获取当前 viewport 是否要取消自动滚动
		 * @return
		 *
		 */
		function get autoScroll():Boolean;
		function set autoScroll(value:Boolean):void;
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
	}
}
