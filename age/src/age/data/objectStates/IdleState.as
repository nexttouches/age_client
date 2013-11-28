package age.data.objectStates
{
	import age.data.ObjectInfo;

	/**
	 * 空闲状态
	 * @author zhanghaocong
	 *
	 */
	public class IdleState extends AbstractObjectState
	{
		/**
		 * constructor
		 *
		 */
		public function IdleState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():Boolean
		{
			if (info.state is AttackState)
			{
				AttackState(info.state).isContinueToNextSeq = false;
				return false;
			}

			if (!info.state || info.state is WalkState)
			{
				info.actionName = "idle";
				info.velocity.x = 0;
				info.velocity.z = 0;
				return true;
			}
			return false;
		}
	}
}
