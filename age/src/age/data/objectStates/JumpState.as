package age.data.objectStates
{
	import age.data.ObjectInfo;
	import age.renderers.Direction;
	import starling.animation.IAnimatable;

	/**
	 * 跳跃状态
	 * @author zhanghaocong
	 *
	 */
	public class JumpState extends AbstractObjectState implements IAnimatable
	{
		/**
		 * constructor
		 *
		 */
		public function JumpState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():Boolean
		{
			if (info.state is IdleState || info.state is WalkState)
			{
				info.actionName = "jump";
				info.isLoop = false;
				info.velocity.y = 600;
				return true;
			}
			return false;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(time:Number):void
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

			if (info.velocity.y < 0)
			{
				if (info.actionName != "drop")
				{
					info.actionName = "drop";
					info.pause();
				}
				else if (info.position.y < info.avatarInfo.size.height)
				{
					info.play();
				}
			}
			else if (info.position.y <= 0)
			{
				info.state = null;
				info.state = info.createState(IdleState);
			}
		}
	}
}
