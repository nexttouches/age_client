package age.data.objectStates
{
	import age.data.ObjectInfo;
	import age.renderers.Direction;

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
		override public function apply():Boolean
		{
			if (info.state is AttackState || info.state is JumpState)
			{
				return false;
			}

			if (direction & Direction.LEFT)
			{
				moveLeft();
			}
			else if (direction & Direction.RIGHT)
			{
				moveRight();
			}

			if (direction & Direction.FRONT)
			{
				moveFront();
			}
			else if (direction & Direction.BACK)
			{
				moveBack();
			}
			info.actionName = "walk";
			return true;
		}
	}
}
