package ageb.modules.ae
{

	/**
	 * 用于渲染 ISelectable 对象的渲染器
	 * @author zhanghaocong
	 *
	 */
	public interface ISelectableRenderer
	{
		/**
		 * 获得当前渲染器的 ISelectableInfo
		 * @return
		 *
		 */
		function get selectableInfo():ISelectableInfo;
	}
}
