package age.data.objectStates
{
	import age.data.ObjectInfo;

	/**
	 * 跑步状态
	 * @author zhanghaocong
	 *
	 */
	public class RunState extends AbstractObjectState
	{
		/**
		 * constructor
		 *
		 */
		public function RunState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():Boolean
		{
			// 攻击状态将不可移动
			if (info.state is AttackState)
			{
				return false;
			}
			info.actionName = "run";
			info.isRunning = true;
			return true;
		}
	}
}
