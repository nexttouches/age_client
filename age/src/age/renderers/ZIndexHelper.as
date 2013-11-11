package age.renderers
{

	/**
	 * 记录一些渲染器的排序索引，索引越小越在前面
	 * @author zhanghaocong
	 *
	 */
	public class ZIndexHelper
	{
		/**
		 * 唯一索引最大值
		 */
		private static const UNIQUE_ZINDEX_MAX:uint = 100;

		/**
		 * 获得一个唯一 z 索引，这是为了解决两个渲染器可能会计算出相同的索引导致闪烁的问题
		 * @return
		 *
		 */
		[Inline]
		public static function getUniqueZIndex():uint
		{
			return nextUniqueZIndex <= UNIQUE_ZINDEX_MAX ? ++nextUniqueZIndex : nextUniqueZIndex = 0;
		}

		/**
		 * @private
		 *
		 */
		private static var nextUniqueZIndex:uint = 0;

		public static const Z_RANGE:uint = 20000;

		public static const ANIMATION_OFFSET:int = 0; // 动画在最前面

		public static const SHADOW_OFFSET:int = 100; // 阴影置底

		public static const MOUSE_RESPONDER_OFFSET:int = 200; // 鼠标区域
	}
}
