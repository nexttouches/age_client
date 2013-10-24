package age.renderers
{
	import org.osflash.signals.Signal;

	/**
	 * 规定了可以触摸的对象
	 * @author zhanghaocong
	 *
	 */
	public interface ITouchable
	{
		/**
		 * 当前鼠标状态<br>
		 * <strong style="color: #000">可用值见下</strong>
		 * @see MouseEvent.MOUSE_DOWN
		 * @see MouseEvent.MOUSE_UP
		 * @see MouseEvent.ROLL_OVER
		 * @see MouseEvent.ROLL_OUT
		 */
		function get state():String;
		/**
		 * onMouseDown 时广播<br>
		 * 正确的回调方法是<br>
		 * <code>function (target:ITouchable):void;</code>
		 * @return
		 *
		 */
		function get onMouseDown():Signal;
		/**
		 * onMouseUp 时广播<br>
		 * 正确的回调方法是<br>
		 * <code>function (target:ITouchable):void;</code>
		 * @return
		 *
		 */
		function get onMouseUp():Signal;
		/**
		 * onRollOver 时广播<br>
		 * 正确的回调方法是<br>
		 * <code>function (target:ITouchable):void;</code>
		 * @return
		 *
		 */
		function get onRollOver():Signal;
		/**
		 * onRollOut 时广播<br>
		 * 正确的回调方法是<br>
		 * <code>function (target:ITouchable):void;</code>
		 * @return
		 *
		 */
		function get onRollOut():Signal;
		/**
		 * 设置或获取该对象是否可触摸
		 * @return
		 *
		 */
		function get touchable():Boolean;
		function set touchable(value:Boolean):void
	}
}
