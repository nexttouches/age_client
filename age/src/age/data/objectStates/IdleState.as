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
		public function IdleState()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply(info:ObjectInfo):Boolean
		{
			if (info.state == ObjectStates.attack)
			{
				return false;
			}
			info.actionName = "idle";
			info.velocity.x = 0;
			info.velocity.z = 0;
			return true;
		}
	}
}
