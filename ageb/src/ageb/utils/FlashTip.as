package ageb.utils
{
	import com.greensock.TweenLite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import mx.managers.PopUpManager;
	import spark.components.Label;
	import ageb.modules.Modules;

	/**
	 * 跳出一个提示，自动淡出<br>
	 * 请调用静态方法 show 来显示文字
	 * @author zhanghaocong
	 *
	 */
	public class FlashTip extends Label
	{
		private static var tip:FlashTip;

		private var closeTimeout:int;

		public function FlashTip()
		{
			super();
			setStyle("fontSize", 16);
			setStyle("color", 0xffff00);
			setStyle("fontFamily", "微软雅黑");
			setStyle("textAlign", "center");
			filters = [ new GlowFilter(0, 1, 6, 6, 3, BitmapFilterQuality.HIGH)];
			mouseEnabled = false;
			focusEnabled = false;
			width = 1000;
		}

		override public function set text(value:String):void
		{
			super.text = value;
			clearTimeout(closeTimeout);
			closeTimeout = setTimeout(close, 666);
		}

		private function close():void
		{
			tip = null;
			TweenLite.to(this, 1, { alpha: 0, y: y - 30, onComplete: function(self:FlashTip):void
			{
				PopUpManager.removePopUp(self);
			}, onCompleteParams: [ this ]});
		}

		/**
		 * 显示一串 message
		 * @param message
		 *
		 */
		public static function show(message:String):void
		{
			if (!tip)
			{
				tip = new FlashTip();
				tip.text = message;
				PopUpManager.addPopUp(tip, Modules.getInstance().root, false);
			}
			else
			{
				tip.text += "\n" + message;
			}
			tip.validateNow();
			tip.y = tip.stage.stageHeight - tip.height;
			tip.x = (tip.parent.width - tip.width) / 2;
		}
	}
}
