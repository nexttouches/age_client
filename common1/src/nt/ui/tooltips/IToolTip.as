package nt.ui.tooltips
{
	import flash.display.DisplayObjectContainer;
	import nt.ui.core.IToolTipClient;

	/**
	 * IToolTip 表示一个 ToolTip，比如 RichTextToolTip 用来显示文字
	 * @author KK
	 *
	 */
	public interface IToolTip
	{
		/**
		 * 根据参数显示指定的 ToolTip
		 * @param target 目标 IToolTipClient
		 * @param container 目标容器
		 *
		 */
		function show(target:IToolTipClient, container:DisplayObjectContainer):void;
		/**
		 * 更新位置
		 * @param target 目标 IToolTipClient
		 *
		 */
		function updatePosition(target:IToolTipClient):void;
		/**
		 * 隐藏 ToolTip
		 *
		 */
		function hide():void;
	}
}
