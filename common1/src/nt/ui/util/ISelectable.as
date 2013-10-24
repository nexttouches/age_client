package nt.ui.util
{
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public interface ISelectable
	{
		/**
		 * 点击时触发的 signal
		 * @return
		 *
		 */
		function get onClick():ISignal;
		
		/**
		 * 当选择状态变化时触发
		 * @return
		 *
		 */
		function get onSelectedChange():ISignal;
		/**
		 * 设置或获取当前 ISelectable 是否已被选中
		 * @return
		 *
		 */
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		/**
		 * 设置或获取当前 ISelectable 是否可选
		 * @return
		 *
		 */
		function get selectable():Boolean;
		function set selectable(value:Boolean):void;
		/**
		 * 设置或获取当前 ISelectable 的 index<br/>
		 * @see SelectionGroup
		 * @return
		 *
		 */
		function get index():int;
		function set index(value:int):void;
	}
}
