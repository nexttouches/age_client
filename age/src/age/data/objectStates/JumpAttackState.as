package age.data.objectStates
{
	import age.data.ObjectInfo;
	import starling.animation.IAnimatable;

	/**
	 * 跳跃攻击
	 * @author zhanghaocong
	 *
	 */
	public class JumpAttackState extends AbstractObjectState implements IAnimatable
	{
		/**
		 * constructor
		 *
		 */
		public function JumpAttackState(info:ObjectInfo)
		{
			super(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function canSwitch(newState:AbstractObjectState):Boolean
		{
			info.isLoop = newState is AttackState || newState is JumpAttackState;
			return info.position.y <= 0;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			info.actionName = "jumpattack";
			info.isLoop = true;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(time:Number):void
		{
			// 跳跃攻击时可以移动，但是不会转向
			move(false);

			// 开始落地
			if (info.isComplete && info.velocity.y < 0)
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
