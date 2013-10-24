package age.assets
{

	/**
	 * 图层类型常量
	 * @see LayerInfo#type
	 * @author zhanghaocong
	 *
	 */
	public class LayerType
	{

		/**
		 * 背景图层
		 * @see LayerInfo#type
		 */
		[Translation(zh_CN="背景层")]
		public static const BG:int = 0;

		/**
		 * 对象图层
		 * @see LayerInfo#type
		 */
		[Translation(zh_CN="对象层")]
		public static const OBJECT:int = 1;

		public function LayerType()
		{
		}
	}
}
