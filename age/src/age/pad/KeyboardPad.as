package age.pad
{
	import flash.utils.getTimer;
	import age.AGE;
	import age.data.ObjectInfo;
	import age.data.objectStates.AbstractObjectState;
	import age.data.objectStates.AttackState;
	import age.data.objectStates.BackstepState;
	import age.data.objectStates.IdleState;
	import age.data.objectStates.JumpAttackState;
	import age.data.objectStates.JumpState;
	import age.data.objectStates.RunState;
	import age.data.objectStates.WalkState;
	import age.renderers.Direction;
	import nt.ui.util.ShortcutUtil;
	import starling.animation.IAnimatable;

	/**
	 * 键盘手柄<br>
	 * 负责侦听键盘事件然后设置 ObjectInfo 的状态
	 * @author zhanghaocong
	 *
	 */
	public class KeyboardPad extends Pad implements IAnimatable
	{
		/**
		 * 键盘控制器的配置
		 */
		public var config:KeyboardPadConfig = new KeyboardPadConfig();

		/**
		 * constructor
		 *
		 */
		public function KeyboardPad()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function advanceTime(time:Number):void
		{
			const now:int = getTimer();
			// 方向键使用频率最高，先收集一下
			const isLeft:Boolean = ShortcutUtil.isDown(config.left)
			const isRight:Boolean = ShortcutUtil.isDown(config.right);
			const isFront:Boolean = ShortcutUtil.isDown(config.front);
			const isBack:Boolean = ShortcutUtil.isDown(config.back);
			const isJump:Boolean = ShortcutUtil.isDown(config.jump);
			const isBackstep:Boolean = ShortcutUtil.isDown(config.backstep);
			const direction:int //
				= (isLeft ? Direction.LEFT : 0) // 朝左
				| (isRight ? Direction.RIGHT : 0) // 朝右
				| (isFront ? Direction.FRONT : 0) // 朝前
				| (isBack ? Direction.BACK : 0); // 朝后

			for (var i:int = 0; i < objectInfos.length; i++)
			{
				// 当前操作对象
				var o:ObjectInfo = objectInfos[i];
				// 更新旧状态
				o.state.direction = direction;
				// 新状态
				var newState:AbstractObjectState;

				// 后跳
				if (isBackstep)
				{
					newState = o.createState(BackstepState);
				}
				// 跳跃
				else if (isJump)
				{
					newState = o.createState(JumpState);
				}
				// 攻击	
				else if (ShortcutUtil.isDown(config.attack) || now - ShortcutUtil.getKeyDownTime(config.attack) < 150)
				{
					if (o.state is JumpState)
					{
						newState = o.createState(JumpAttackState);
					}
					else
					{
						newState = o.createState(AttackState);
					}
				}
				else if (direction != 0)
				{
					if ((isLeft && ShortcutUtil.getInterval(config.left) < config.runTimeout) // 左
						|| (isRight && ShortcutUtil.getInterval(config.right) < config.runTimeout) // 右
						|| (isFront && ShortcutUtil.getInterval(config.front) < config.runTimeout) // 前
						|| (isBack && ShortcutUtil.getInterval(config.back) < config.runTimeout)) // 后
					{
						newState = o.createState(RunState);
					}
					else
					{
						newState = o.createState(WalkState);
					}
				}

				if (!newState)
				{
					newState = o.createState(IdleState);
				}
				newState.direction = direction;
				o.state = newState;
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function addObject(o:ObjectInfo):void
		{
			const lengthBefore:int = objectInfos.length;
			super.addObject(o);

			if (lengthBefore == 0)
			{
				AGE.physicsJuggler.add(this);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function removeObject(o:ObjectInfo):void
		{
			super.removeObject(o);

			if (objectInfos.length == 0)
			{
				AGE.physicsJuggler.remove(this);
			}
		}
	}
}
