package ageb.modules.document
{

	/**
	 * 文档状态的所有枚举值
	 * @author zhanghaocong
	 *
	 */
	public class DocumentState
	{

		/**
		 * 刚刚新建的文档，必须使用另存为才可以保存
		 */
		[Translation(zh_CN="新建")]
		public static var NEW:int = -1;

		/**
		 * 文档已准备好
		 */
		[Translation(zh_CN="就绪")]
		public static var READY:int = 0;

		/**
		 * 文档正在保存
		 */
		[Translation(zh_CN="保存中")]
		public static var SAVING:int = 1;

		/**
		 * 文档已保存
		 */
		[Translation(zh_CN="保存完毕")]
		public static var CHANGED:int = 2;

		public function DocumentState()
		{
		}
	}
}
