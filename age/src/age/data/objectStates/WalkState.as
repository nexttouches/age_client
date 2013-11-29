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
		public function WalkState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			move();
			info.actionName = "walk";
		}
	}
}
