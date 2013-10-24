package ageb.modules.ae
{
	import flash.geom.Vector3D;
	import org.osflash.signals.Signal;

	/**
	 * AE 中可选对象的接口<br>
	 * SelectTool 点击时，将处理已实现该接口的对象
	 * @see aeb.modules.tools.SelectTool
	 * @author zhanghaocong
	 *
	 */
	public interface ISelectableInfo extends ICloneable, IChild
	{
		/**
		 * isSelected 变化时广播
		 * @return
		 *
		 */
		function get onIsSelectedChange():Signal;
		/**
		 * 设置或获取是否已经选中
		 * @return
		 *
		 */
		function get isSelected():Boolean;
		function set isSelected(value:Boolean):void;
		/**
		 * isSelectable 广播
		 * @return
		 *
		 */
		function get onIsSelectableChange():Signal;
		/**
		 * 设置或获取对象是否可选
		 * @return
		 *
		 */
		function get isSelectable():Boolean;
		function set isSelectable(value:Boolean):void;
		/**
		 * XY 变化时广播
		 * @return
		 *
		 */
		function get onPositionChange():Signal;
		/**
		 * 移动到指定坐标
		 * @param x
		 * @param y
		 * @param snapX
		 * @param snapY
		 *
		 */
		function moveTo(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void;
		/**
		 * 增量移动到指定坐标
		 * @param x
		 * @param y
		 * @param snapX
		 * @param snapY
		 */
		function moveBy(x:Number, y:Number, z:Number, snapX:Number = 1, snapY:Number = 1, snapZ:Number = 1):void;
		/**
		 * isDragging 发生变化时触发
		 * @return
		 *
		 */
		function get onIsDraggingChange():Signal;
		/**
		 * 设置或获取对象是否在拖拽中<br>
		 *
		 */
		function get isDragging():Boolean;
		function set isDragging(value:Boolean):void;
		/**
		 * 获取拖拽时的比率
		 * @return
		 *
		 */
		function get dragRatio():Vector3D;
	}
}
