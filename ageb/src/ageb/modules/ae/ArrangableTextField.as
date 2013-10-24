package ageb.modules.ae
{
	import age.renderers.IArrangeable;
	import starling.text.TextField;

	public class ArrangableTextField extends TextField implements IArrangeable
	{
		public function ArrangableTextField(width:int = 192, height:int = 22, fontName:String = "Verdana", fontSize:Number = 12, color:uint = 0xffff00, bold:Boolean = false)
		{
			super(width, height, "", fontName, fontSize, 0xffff00, bold);
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
