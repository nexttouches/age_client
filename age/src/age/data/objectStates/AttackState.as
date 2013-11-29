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
		 * 记录当前第几下，默认 0<br>
		 * apply 时，该值设置到 1<br>
		 * cancle 时，该值设置到 0
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
		}
	}
}
