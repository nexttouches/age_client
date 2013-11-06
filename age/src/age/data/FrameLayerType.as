package age.data
{

	/**
	 * 帧图层类型
	 * @author zhanghaocong
	 *
	 */
	public class FrameLayerType
	{

		/**
		 * 虚拟图层，只是一堆数据，不参与任何渲染
		 * @see FrameLayerType
		 * @see FrameLayerInfo#type
		 */
		[Translation(zh_CN="虚拟")]
		public static const VIRTUAL:int = 0;

		/**
		 * 动画
		 * @see FrameLayerType
		 * @see FrameLayerInfo#type
		 */
		[Translation(zh_CN="动画")]
		public static const ANIMATION:int = 1;

		/**
		 * 粒子（未实现）
		 * @see FrameLayerType
		 * @see FrameLayerInfo#type
		 */
		[Translation(zh_CN="粒子")]
		public static const PARTICLE:int = 2;

		/**
		 * 音乐
		 */
		[Translation(zh_CN="声音")]
		public static const SOUND:int = 3;

		public function FrameLayerType()
		{
		}
	}
}
