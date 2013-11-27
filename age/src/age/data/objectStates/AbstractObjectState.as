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
		 * 状态的操作对象
		 */
		protected var info:ObjectInfo;

		/**
		 * constructor
		 *
		 */
		public function AbstractObjectState(info:ObjectInfo)
		{
			this.info = info;
			name = Type.of(this).shortname.replace(/State/g, "").toLowerCase();
		}

		/**
		 * 应用当前状态
		 * @return 是否应用成功
		 */
		public function apply():Boolean
		{
			throw new IllegalOperationError("错误：需子类实现");
			return false;
		}

		/**
		 * 取消该状态时调用
		 * @param info
		 *
		 */
		public function cancel():void
		{
		}
	}
}
