package age.renderers
{

	/**
	 * 方向渲染器
	 * @author zhanghaocong
	 *
	 */
	public interface IDirectionRenderer
	{
		/**
		 * 设置或获取方向
		 * @see Direction
		 * @return
		 *
		 */
		function get direction():int;
		function set direction(value:int):void;
	}
}
