package ageb.modules.ae
{
	import age.renderers.IArrangeable;
	import starling.display.Quad;

	public class ArrangableQuad extends Quad implements IArrangeable
	{
		public function ArrangableQuad(width:Number, height:Number, color:uint = 16777215, premultipliedAlpha:Boolean = true)
		{
			super(width, height, color, premultipliedAlpha);
		}

		public function get zIndex():int
		{
			return int.MAX_VALUE;
		}

		/**
		* 标记 visible 是否已经锁定<br>
		* 一旦锁定，将不能操作 visible 属性
		*/
		public var isVisibleLocked:Boolean = false;

		override public function set visible(value:Boolean):void
		{
			if (isVisibleLocked)
			{
				return;
			}
			super.visible = value;
		}
	}
}
