package nt.ui.dnd
{

	/**
	 * 表示该组件可以被放置
	 * @author KK
	 *
	 */
	public interface IDroppable
	{
		/**
		 * 表示有对象进入当前 IDroppable<br/>
		 * 根据具体情况，返回 true 表示允许当前 info 释放，否则表示不接受<br/>
		 * @param info
		 * @return 是否允许释放
		 *
		 */
		function dragEnter(info:DragInfo):Boolean;
		/**
		 * 松开鼠标后调用该方法，仅当 dragEnter 返回 true 时调用
		 * @param info
		 *
		 */
		function dragDrop(info:DragInfo):void;
		/**
		 * 对象离开后调用
		 * @param info
		 *
		 */
		function dragExit(info:DragInfo):void;
		/**
		 * 设置或获取是否可以 drop
		 * @return
		 *
		 */
		function get isDroppable():Boolean;
		function set isDroppable(value:Boolean):void;
	}
}
