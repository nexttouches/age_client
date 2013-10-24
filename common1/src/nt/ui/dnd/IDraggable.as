package nt.ui.dnd
{
	import flash.display.IBitmapDrawable;
	import flash.geom.Rectangle;
	import flash.geom.Transform;

	/**
	 * 表示一个可以拖拽的组件
	 * @author KK
	 *
	 */
	public interface IDraggable extends IBitmapDrawable
	{
		/**
		 * 设置或获取是否可以 drag
		 * @return
		 *
		 */
		function get isDraggable():Boolean;
		function set isDraggable(value:Boolean):void;
		/**
		 * IDraggable 在任何不能拖放的地方松开鼠标后调用
		 *
		 */
		function dragDropOutSide(info:DragInfo):void;
		/**
		 * 拖放操作完成时调用
		 * @param info
		 *
		 */
		function dragComplete(info:DragInfo):void;
		/**
		 * 拖拽时使用的数据源
		 * @return
		 *
		 */
		function get dragData():*;
		/**
		 * 返回当前 IDraggable 相对于 stage 的矩形框<br/>
		 * 通常实现是
		 * <pre>return getRect(stage);</pre>
		 * @return
		 *
		 */
		function get anchor():Rectangle;
		/**
		 * DisplayObject.transform 自动实现该方法
		 * @return
		 *
		 */
		function get transform():Transform;
		/**
		 * DisplayObject 自带该方法
		 * @return
		 *
		 */
		function get mouseX():Number;
		/**
		 * DisplayObject 自带该方法
		 * @return
		 *
		 */
		function get mouseY():Number;
	}
}
