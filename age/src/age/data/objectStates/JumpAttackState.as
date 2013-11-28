package age.data.objectStates
{
	import age.data.ObjectInfo;
	import age.renderers.Direction;

	/**
	 * 跳跃攻击
	 * @author zhanghaocong
	 *
	 */
	public class JumpAttackState extends JumpState
	{
		public function JumpAttackState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():Boolean
		{
			if (info.state is JumpState)
			{
				info.actionName = "jumpattack";
				info.isLoop = true;
				return true;
			}
			return false;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function advanceTime(time:Number):void
		{
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

			if (info.position.y <= 0)
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}
	}
}
