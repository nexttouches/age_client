package age.renderers
{
	import flash.geom.Rectangle;

	/**
	 * 细节渲染器允许实现该接口的对象实现自己的细节更新处理
	 * @author zhanghaocong
	 *
	 */
	public interface IDetailRenderer
	{
		/**
		 *
		 * 根据参数更新要显示的细节
		 * @param visibleRect 可见区域
		 *
		 */
		function updateDetail(visibleRect:Rectangle):void;
	}
}
