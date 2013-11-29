package age.data.objectStates
{
	import age.data.ObjectInfo;

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
		 * constructor
		 * @param sequence 当前是第几下 attack
		 * @param nextState 攻击完毕后自动进入该状态
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
			isContinue = newState is AttackState;
			return false;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			isContinue = false;
			info.actionName = "attack1";
			info.onLastFrame.addOnce(attack1_onLastFrame);
			info.velocity.z = 0;
			info.velocity.x = 0;
		}

		/**
		 * @private
		 *
		 */
		private function jumpattack_onLastFrame(info:ObjectInfo):void
		{
			if (isContinue)
			{
				info.actionName = "jumpattack";
				info.onLastFrame.addOnce(jumpattack_onLastFrame);
			}
			else
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}

		/**
		 * @private
		 *
		 */
		private function attack1_onLastFrame(info:ObjectInfo):void
		{
			if (isContinue)
			{
				isContinue = false;
				info.velocity.x = 50;
				info.actionName = "attack2";
				info.onLastFrame.addOnce(attack2_onLastFrame);
			}
			else
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}

		/**
		 * @private
		 *
		 */
		private function attack2_onLastFrame(info:ObjectInfo):void
		{
			if (isContinue)
			{
				isContinue = false;
				info.velocity.x = 150;
				info.actionName = "attack3";
				info.onLastFrame.addOnce(attack3_onLastFrame);
			}
			else
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}

		/**
		 * @private
		 *
		 */
		private function attack3_onLastFrame(info:ObjectInfo):void
		{
			if (isContinue)
			{
				isContinue = false;
				info.velocity.x = 50;
				info.actionName = "attack1";
				info.onLastFrame.addOnce(attack1_onLastFrame);
			}
			else
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function cancel():void
		{
			isContinue = false;
			info.onLastFrame.remove(attack1_onLastFrame);
			info.onLastFrame.remove(attack2_onLastFrame);
			info.onLastFrame.remove(attack3_onLastFrame);
		}
	}
}
