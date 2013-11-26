package age.pad
{
	import age.AGE;
	import age.data.ObjectInfo;
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
			const INTERVAL:int = 200;

			for (var i:int = 0; i < objectInfos.length; i++)
			{
				var o:ObjectInfo = objectInfos[i];
				var actionName:String = "idle";
				var isRunning:Boolean = false;

				// 行走方向
				if (ShortcutUtil.isDown(config.left))
				{
					o.moveLeft();

					if (ShortcutUtil.getInterval(config.left) < INTERVAL)
					{
						actionName = "run";
						isRunning = true;
					}
					else if (actionName != "run")
					{
						actionName = "walk";
					}
				}
				else if (ShortcutUtil.isDown(config.right))
				{
					o.moveRight();

					if (ShortcutUtil.getInterval(config.right) < INTERVAL)
					{
						actionName = "run";
						isRunning = true;
					}
					else if (actionName != "run")
					{
						actionName = "walk";
					}
				}
				else
				{
					o.stopMoveLeftRight();
				}

				if (ShortcutUtil.isDown(config.near))
				{
					o.moveNear();

					if (ShortcutUtil.getInterval(config.near) < INTERVAL)
					{
						actionName = "run";
						isRunning = true;
					}
					else if (actionName != "run")
					{
						actionName = "walk";
					}
				}
				else if (ShortcutUtil.isDown(config.far))
				{
					o.moveFar();

					if (ShortcutUtil.getInterval(config.far) < INTERVAL)
					{
						actionName = "run";
						isRunning = true;
					}
					else if (actionName != "run")
					{
						actionName = "walk";
					}
				}
				else
				{
					o.stopMoveNearFar();
				}
				o.actionName = actionName;
				o.isRunning = isRunning;
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
