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
		 * 当前状态是否可以强制切换到新状态，默认 false
		 */
		public var isForce:Boolean = false;

		/**
		 * 状态名字。自动通过反射获取并且全小写
		 */
		public var name:String;

		/**
		 * 方向参数。默认值为 0，也就是没有任何方向
		 */
		public var direction:int = 0;

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
		 */
		public function apply():void
		{
			throw new IllegalOperationError("错误：需子类实现");
		}

		/**
		 * 取消该状态时调用
		 * @param info
		 *
		 */
		public function cancel():void
		{
		}

		/**
		 * 从当前状态切换到指定新状态时调用<br>
		 * 抽象类 AbstractObjectState 的该方法总是返回 true
		 * @param newState 新状态
		 * @return 如果可以切换就返回 true，否则返回 false
		 *
		 */
		public function canSwitch(newState:AbstractObjectState):Boolean
		{
			return true;
		}

		/**
		 * @private
		 */
		protected var moveSpeed:Number = 150;

		/**
		 * 左移
		 *
		 */
		final protected function moveLeft(isChangeDirection:Boolean):void
		{
			// 先转向后移动
			if (info.direction & Direction.LEFT || !isChangeDirection)
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
		final protected function moveRight(isChangeDirection:Boolean):void
		{
			// 先转向后移动
			if (info.direction & Direction.RIGHT || !isChangeDirection)
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
		final protected function moveFront():void
		{
			info.velocity.z = -moveSpeed;
		}

		/**
		 * 上移
		 *
		 */
		final protected function moveBack():void
		{
			info.velocity.z = moveSpeed;
		}

		/**
		 * 检查 direction 并移动
		 * @param isChangeDirection 反向移动时是否要换方向
		 */
		final public function move(isChangeDirection:Boolean = true):void
		{
			if (direction & Direction.LEFT)
			{
				moveLeft(isChangeDirection);
			}
			else if (direction & Direction.RIGHT)
			{
				moveRight(isChangeDirection);
			}

			if (direction & Direction.FRONT)
			{
				moveFront();
			}
			else if (direction & Direction.BACK)
			{
				moveBack();
			}
		}

		/**
		 * 水平方向停止移动
		 *
		 */
		[Inline]
		final public function stop():void
		{
			info.velocity.x = 0;
			info.velocity.z = 0;
		}
	}
}
