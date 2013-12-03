package age.data.objectStates
{
	import age.data.ObjectInfo;
	import age.renderers.Direction;

	/**
	 * 普攻状态，根据参数可以设置为普攻的第几下
	 * @author zhanghaocong
	 *
	 */
	public class AttackState extends AbstractObjectState
	{
		/**
		 * 攻击动作动作名字前缀（attack1, attack2 ... attackN）
		 */
		private static const ACTION_NAME_PREFIX:String = "attack";

		/**
		 * 设置或获取是否继续下一个攻击。<br>
		 * false：当前攻击动作结束后设置为 IdleState
		 * true：当前攻击动作结束后设置为下一动作： attack1 -> attack2 -> attack3 -> attack1 ... 循环
		 */
		public var isContinue:Boolean;

		/**
		 * 记录当前第几下，默认 0<br>
		 * 每攻击一次 +1<br>
		 * 调用 cancle 时，该值设置到 0
		 */
		private var index:int = 0;

		/**
		 * 索引最大值（固定为 3）
		 */
		private static const MAX_INDEX:int = 3;

		/**
		 * constructor
		 */
		public function AttackState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function canSwitch(newState:AbstractObjectState):Boolean
		{
			if (newState.isForce)
			{
				isContinue = false;
				return true;
			}
			isContinue = newState is AttackState;
			return !isContinue && info.isComplete;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			attack();
		}

		/**
		 * 执行攻击动作
		 *
		 */
		private function attack():void
		{
			if (index >= MAX_INDEX)
			{
				index = 0;
			}
			index++;
			isContinue = false;
			info.actionName = ACTION_NAME_PREFIX + index;
			info.isLoop = false;
			info.onLastFrame.addOnce(onLastFrame);
			info.onCurrentFrameChange.addOnce(onCurrentFrameChange);

			// 攻击中可以移动的判定
			if (info.direction & Direction.RIGHT)
			{
				if (direction & Direction.RIGHT)
				{
					moveSpeed = 300;
				}
				else if (direction & Direction.LEFT)
				{
					moveSpeed = 0;
				}
				else
				{
					moveSpeed = 150;
				}
			}
			else if (info.direction & Direction.LEFT)
			{
				if (direction & Direction.LEFT)
				{
					moveSpeed = -300;
				}
				else if (direction & Direction.RIGHT)
				{
					moveSpeed = 0;
				}
				else
				{
					moveSpeed = -150;
				}
			}
		}

		/**
		 * 此处判断第一个判定帧出现后，向前移动一定距离
		 *
		 */
		private function onCurrentFrameChange(info:ObjectInfo):void
		{
			info.velocity.x = moveSpeed;
		}

		/**
		 * 动作完毕后调用，此时会判断是否继续下一击或停止
		 *
		 */
		private function onLastFrame(info:ObjectInfo):void
		{
			if (isContinue)
			{
				attack();
			}
			else
			{
				index = 0;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function cancel():void
		{
			index = 0;
			isContinue = false;
			info.onLastFrame.remove(onLastFrame);
			info.onCurrentFrameChange.remove(onCurrentFrameChange);
		}
	}
}
