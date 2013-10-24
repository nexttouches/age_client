package ageb.modules.ae
{

	/**
	 * 可克隆对象的接口
	 * @author zhanghaocong
	 *
	 */
	public interface ICloneable
	{
		/**
		 * 克隆一个对象
		 * @return 克隆了的对象
		 *
		 */
		function clone():ICloneable;
	}
}
