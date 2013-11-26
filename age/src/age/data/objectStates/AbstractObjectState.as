package age.data.objectStates
{
	import flash.errors.IllegalOperationError;
	import age.data.ObjectInfo;
	import nt.lib.reflect.Type;

	/**
	 * 对象状态
	 * @author zhanghaocong
	 *
	 */
	public class AbstractObjectState
	{
		/**
		 * 状态名字
		 */
		public var name:String;

		/**
		 * constructor
		 *
		 */
		public function AbstractObjectState()
		{
			name = Type.of(this).shortname.replace(/State/g, "").toLowerCase();
		}

		/**
		 * 应用当前状态到指定的 ObjectInfo
		 * @param info
		 * @return 是否应用成功
		 */
		public function apply(info:ObjectInfo):Boolean
		{
			throw new IllegalOperationError("错误：需子类实现");
			return false;
		}
	}
}
