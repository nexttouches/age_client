package age.renderers
{

	/**
	 * 规定了 3D 显示对象<br>
	 * 目前比较简单，只有 z 轴相关的设定
	 * @author zhanghaocong
	 *
	 */
	public interface IDisplayObject3D extends IArrangeable
	{
		/**
		 * 设置或获取尺寸
		 * @return
		 *
		 */
		function get scale():Number;
		function set scale(value:Number):void;
		/**
		 * 设置或获取 x
		 * @return
		 *
		 */
		function get x():Number;
		function set x(value:Number):void;
		/**
		 * 设置或获取 y
		 * @return
		 *
		 */
		function get y():Number;
		function set y(value:Number):void;
		/**
		 * z 轴
		 * @return
		 *
		 */
		function get z():Number;
		function set z(value:Number):void;
		/**
		 * 通过该方法结合 y 和 z 投影到 Starling 坐标系的 y 中<br>
		 * 该方法的签名应是<br>
		 * <code>function (y:Number, z:Number):Number</code>
		 * 其中输入的 y 和 z 属笛卡尔坐标系，返回的是 UI 坐标
		 * @return
		 *
		 */
		function get projectY():Function;
		function set projectY(value:Function):void;
		/**
		 * 释放资源
		 *
		 */
		function dispose():void;
	}
}
