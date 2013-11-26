package age.data.objectStates
{
	import age.data.ObjectInfo;

	/**
	 * 行走状态
	 * @author zhanghaocong
	 *
	 */
	public class WalkState extends AbstractObjectState
	{
		/**
		 * constructor
		 *
		 */
		public function WalkState()
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
			info.actionName = "walk";
			info.isRunning = false;
			return true;
		}
	}
}
