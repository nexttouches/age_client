package age.data.objectStates
{
	import age.data.ObjectInfo;
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
		 */
		override public function canSwitch(newState:AbstractObjectState):Boolean
		{
			return newState is JumpAttackState || info.position.y <= 0;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			info.actionName = "jump";
			info.isLoop = false;
			info.velocity.y = 600;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(time:Number):void
		{
			move(true);

			// 开始落地
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
		}
	}
}
