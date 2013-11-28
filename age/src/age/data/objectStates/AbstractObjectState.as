package age.data.objectStates
{
	import flash.errors.IllegalOperationError;
	import age.data.ObjectInfo;
	import age.renderers.Direction;
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
		 * 方向参数
		 */
		public var direction:int;

		/**
		 * 当前状态的操作对象
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

		private var moveSpeed:Number = 150;

		/**
		 * 左移
		 *
		 */
		public function moveLeft():void
		{
			// 先转向后移动
			if (info.direction & Direction.LEFT)
			{
				info.velocity.x = -moveSpeed;
			}
			else
			{
				info.direction = Direction.LEFT;
			}
		}

		/**
		 * 右移
		 *
		 */
		public function moveRight():void
		{
			// 先转向后移动
			if (info.direction & Direction.RIGHT)
			{
				info.velocity.x = moveSpeed;
			}
			else
			{
				info.direction = Direction.RIGHT;
			}
		}

		/**
		 * 下移动
		 *
		 */
		public function moveFront():void
		{
			info.velocity.z = -moveSpeed;
		}

		/**
		 * 上移
		 *
		 */
		public function moveBack():void
		{
			info.velocity.z = moveSpeed;
		}
	}
}
