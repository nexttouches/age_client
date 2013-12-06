package age.data.objectStates
{
	import age.data.ObjectInfo;
	import age.renderers.Direction;

	/**
	 * 后跳
	 * @author zhanghaocong
	 *
	 */
	public class BackstepState extends AbstractObjectState
	{
		/**
		 * constructor
		 *
		 */
		public function BackstepState(info:ObjectInfo)
		{
			super(info);
			isForce = true;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function canSwitch(newState:AbstractObjectState):Boolean
		{
			// 重复设置 BackstepState 时，要将 isShowGhost 关闭 
			if (newState == this)
			{
				info.isShowGhost = false;
			}
			return info.position.y <= 0;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function apply():void
		{
			info.isShowGhost = true;
			info.actionName = "jump";
			info.isLoop = false;
			info.velocity.y = 200;

			if (info.direction & Direction.RIGHT)
			{
				info.velocity.x = -200;
			}
			else if (info.direction & Direction.LEFT)
			{
				info.velocity.x = 200;
			}
		}
	}
}
