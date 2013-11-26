package age.data.objectStates
{
	import age.data.ObjectInfo;

	/**
	 * 普攻状态
	 * @author zhanghaocong
	 *
	 */
	public class AttackState extends AbstractObjectState
	{
		/**
		 * constructor
		 *
		 */
		public function AttackState()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply(info:ObjectInfo):Boolean
		{
			info.actionName = "attack1";
			info.onLastFrame.addOnce(onLastFrame);
			info.velocity.x = 0;
			info.velocity.z = 0;
			return true;
		}

		/**
		 * @private
		 *
		 */
		private function onLastFrame(info:ObjectInfo):void
		{
			info.state = null;
			info.state = ObjectStates.idle;
		}
	}
}
