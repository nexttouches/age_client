package age.pad
{
	import flash.utils.getTimer;
	import age.AGE;
	import age.data.ObjectInfo;
	import age.data.objectStates.AbstractObjectState;
	import age.data.objectStates.AttackState;
	import age.data.objectStates.IdleState;
	import age.data.objectStates.RunState;
	import age.data.objectStates.WalkState;
	import nt.lib.util.assert;
	import nt.ui.util.ShortcutUtil;
	import starling.animation.IAnimatable;

	/**
	 * 键盘手柄<br>
	 * 主要用于侦听键盘事件再操作 ObjectInfo
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
			// 单个控制器只能控制一个角色
			assert(objectInfos.length == 1);
			const now:int = getTimer();

			for (var i:int = 0; i < objectInfos.length; i++)
			{
				var o:ObjectInfo = objectInfos[i];
				var state:AbstractObjectState;
				var isStateChange:Boolean = true;
				const oldState:AbstractObjectState = o.state;

				if (oldState is AttackState)
				{ // 是攻击状态
					if (now - ShortcutUtil.getKeyDownTime(config.attack) < 200)
					{ // 200ms 前按下了攻击键
						isStateChange = false;
						AttackState(o.state).isContinueToNextSeq = true;
					}
					else
					{
						isStateChange = false;
						AttackState(o.state).isContinueToNextSeq = false;
					}
				}
				else
				{
					if (ShortcutUtil.isDown(config.attack))
					{ // 攻击
						state = o.createState(AttackState);
					}
					else
					{
						// 行走方向
						if (ShortcutUtil.isDown(config.left))
						{
							o.moveLeft();

							if (ShortcutUtil.getInterval(config.left) < config.runTimeout)
							{
								state = o.createState(RunState);
							}
							else
							{
								state = o.createState(WalkState);
							}
						}
						else if (ShortcutUtil.isDown(config.right))
						{
							o.moveRight();

							if (ShortcutUtil.getInterval(config.right) < config.runTimeout)
							{
								state = o.createState(RunState);
							}
							else
							{
								state = o.createState(WalkState);
							}
						}

						if (ShortcutUtil.isDown(config.near))
						{
							o.moveNear();

							if (ShortcutUtil.getInterval(config.near) < config.runTimeout)
							{
								state = o.createState(RunState);
							}
							else
							{
								state = o.createState(WalkState);
							}
						}
						else if (ShortcutUtil.isDown(config.far))
						{
							o.moveFar();

							if (ShortcutUtil.getInterval(config.far) < config.runTimeout)
							{
								state = o.createState(RunState);
							}
							else
							{
								state = o.createState(WalkState);
							}
						}
					}
				}

				// 如果没有任何键盘输入，默认是 IdleState
				if (isStateChange)
				{
					o.state = state || o.createState(IdleState);
				}
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
