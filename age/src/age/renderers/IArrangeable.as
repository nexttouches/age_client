package age.renderers
{

	/**
	 * 图层里的所有对象需实现的基本接口
	 * @author zhanghaocong
	 *
	 */
	public interface IArrangeable
	{
		/**
		 * 返回一个 int，用于确定该对象的前后排列关系，数值小的在前面
		 * @return
		 *
		 */
		function get zIndex():int;
	}
}
