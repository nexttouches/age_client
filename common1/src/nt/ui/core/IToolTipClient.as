package nt.ui.core
{
	import flash.geom.Rectangle;
	import org.osflash.signals.ISignal;

	/**
	 * IToolTipClient 表示一个可以设置 tipContent 的对象
	 * @author KK
	 *
	 */
	public interface IToolTipClient
	{
		/**
		 * IToolTip 需要在 onRollOver 时显示
		 * @return
		 *
		 */
		function get onRollOver():ISignal;
		/**
		 * IToolTip 需要在 onRollOut 时消失
		 * @return
		 *
		 */
		function get onRollOut():ISignal;
		/**
		 * IToolTip 需要在 onAdd 时检查是否在当前鼠标下，然后显示
		 * @return
		 *
		 */
		function get onAdd():ISignal;
		/**
		 * IToolTip 需要在 onRemove 时消失
		 * @return
		 *
		 */
		function get onRemove():ISignal;
		/**
		 * IToolTip 需要根据 visible 状况切换显示或隐藏
		 * @return
		 *
		 */
		function get onVisibleChange():ISignal;
		/**
		 * IToolTip 需要在 onMove 时更新位置
		 * @return
		 *
		 */
		function get onMove():ISignal;
		/**
		 * IToolTip 需要在 onResize 时更新位置
		 * @return
		 *
		 */
		function get onResize():ISignal;
		/**
		 * 设置或获取 tipContent
		 * @return
		 *
		 */
		function get tipContent():*;
		function set tipContent(value:*):void;
		/**
		 * 获取 Tooltip 应显示的矩形位置（相对于 stage）
		 * @return
		 *
		 */
		function get anchor():Rectangle;
	}
}
