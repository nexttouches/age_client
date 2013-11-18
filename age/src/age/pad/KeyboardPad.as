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

			for (var i:int = 0; i < objectInfos.length; i++)
			{
				const o:ObjectInfo = objectInfos[i];
				var actionName:String = "idle";

				if (ShortcutUtil.isDown(config.left))
				{
					o.moveLeft();
					actionName = "walk";
				}
				else if (ShortcutUtil.isDown(config.right))
				{
					o.moveRight();
					actionName = "walk";
				}
				else
				{
				}

				if (ShortcutUtil.isDown(config.near))
				{
					o.moveNear();
					actionName = "walk";
				}
				else if (ShortcutUtil.isDown(config.far))
				{
					o.moveFar();
					actionName = "walk";
				}
				else
				{
				}
				o.actionName = actionName;
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
