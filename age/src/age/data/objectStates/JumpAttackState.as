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
			move(false);
		}
	}
}
