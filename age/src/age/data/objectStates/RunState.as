package age.data.objectStates
{
	import age.data.ObjectInfo;

	/**
	 * 跑步状态
	 * @author zhanghaocong
	 *
	 */
	public class RunState extends WalkState
	{
		/**
		 * constructor
		 *
		 */
		public function RunState(info:ObjectInfo)
		{
			super(info);
			moveSpeed *= 1.5;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			move();
			info.actionName = "run";
		}
	}
}
