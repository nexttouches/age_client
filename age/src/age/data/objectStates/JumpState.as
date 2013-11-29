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
			// 跳跃中可以移动
			move(true);

			// 开始落地
			if (info.velocity.y < 0)
			{
				// 切换到 drop 动作并暂停
				if (info.actionName != "drop")
				{
					info.actionName = "drop";
					info.pause();
				}
				// 快落地时开始播放
				// 注：此处有更好的做法 ———— 计算落地时间，然后调整动画的 fps
				else if (info.position.y < info.avatarInfo.size.height)
				{
					info.play();
				}
			}
		}
	}
}
