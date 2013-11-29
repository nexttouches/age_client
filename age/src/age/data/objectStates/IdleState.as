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
		override public function apply():void
		{
			info.actionName = "idle";
			stop();
		}
	}
}
