package age.data
{
	import age.renderers.Direction;

	/**
	 * 打击效果
	 * @author zhanghaocong
	 *
	 */
	public class SlashEffect extends ObjectInfo
	{
		/**
		 * constructor
		 *
		 */
		public function SlashEffect(parent:LayerInfo = null, actionName:String = null, direction:int = Direction.RIGHT)
		{
			super(null, parent);
			_isLoop = false;
			_avatarID = "hiteffects";
			_actionName = actionName || "slashsmall1";
			_direction = direction;
			mass = 0;
			onLastFrame.add(removeSelf);
			validateNow();
		}

		/**
		 * @private
		 *
		 */
		private function removeSelf(info:ObjectInfo):void
		{
			parent.removeObject(this);
		}
	}
}
