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
			assert(objectInfos.length == 1);

			for (var i:int = 0; i < objectInfos.length; i++)
			{
				const o:ObjectInfo = objectInfos[i];

				if (ShortcutUtil.isDown(config.left))
				{
					o.velocity.x = -200;
				}
				else if (ShortcutUtil.isDown(config.right))
				{
					o.velocity.x = 200;
				}
				else
				{
					o.velocity.x = 0;
				}

				if (ShortcutUtil.isDown(config.near))
				{
					o.velocity.z = -200;
				}
				else if (ShortcutUtil.isDown(config.far))
				{
					o.velocity.z = 200;
				}
				else
				{
					o.velocity.z = 0;
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
