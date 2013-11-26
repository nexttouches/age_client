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
		public function RunState()
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
			info.actionName = "run";
			info.isRunning = true;
			return true;
		}
	}
}
