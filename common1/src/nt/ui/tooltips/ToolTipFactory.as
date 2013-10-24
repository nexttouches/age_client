package nt.ui.tooltips
{
	import flash.utils.Dictionary;

	public class ToolTipFactory
	{
		private static var registered:Dictionary = new Dictionary();

		public static function register(contentType:Class, toolTip:IToolTip):void
		{
			if (registered[contentType])
			{
				throw new Error("不能重复注册 ToolTip " + contentType);
			}
			registered[contentType] = toolTip;
		}

		public static function get(toolTip:*):IToolTip
		{
			if (!registered[toolTip.constructor])
			{
				throw new Error(toolTip.constructor + "没有注册");
			}
			return registered[toolTip.constructor];
		}
		
		// 注册一个默认的 RichTextToolTip
		ToolTipFactory.register(String, new RichTextToolTip());
	}
}
