package ageb.modules.ae
{

	/**
	 * IParent 表示一个父级可以添加子对象
	 * @author zhanghaocong
	 *
	 */
	public interface IParent
	{
		/**
		 * 添加一个子对象
		 * @param child
		 *
		 */
		function add(child:IChild):void;
		/**
		 * 删除一个子对象
		 * @param child
		 *
		 */
		function remove(child:IChild):void;
	}
}
