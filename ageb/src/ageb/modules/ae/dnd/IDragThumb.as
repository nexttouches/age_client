package ageb.modules.ae.dnd
{
	import age.renderers.IArrangeable;
	import starling.display.DisplayObject;

	/**
	 * 拖拽时产生的缩略图
	 * @author zhanghaocong
	 *
	 */
	public interface IDragThumb extends IArrangeable
	{
		/**
		 * 设置当前 DragThumb 显示的源
		 * @param s
		 *
		 */
		function setSource(s:DisplayObject):void;
		/**
		 * 根据参数进行偏移<br>
		 * 这里输入的参数是屏幕坐标，根据情况转化到本地坐标
		 * @param x
		 * @param y
		 * @param snapX
		 * @param snapY
		 *
		 */
		function offset(x:Number, y:Number, snapX:Number = 1, snapY:Number = 1):void;
		/**
		 * 获得用于实际显示的 DisplayObject<br>
		 * 通常是返回自己
		 * @return
		 *
		 */
		function get displayObject():DisplayObject;
	}
}
