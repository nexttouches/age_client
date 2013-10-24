package nt.ui.tooltips
{
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	import nt.ui.core.IToolTipClient;

	/**
	 * 切换 ToolTip 显示隐藏的助手类
	 * @author KK
	 *
	 */
	internal class ToolTipShowHideHelper
	{
		/**
		 * 当前正显示的 ToolTip
		 */
		public var currentToolTip:IToolTip;

		/**
		 * 当前的 IToolTipClient
		 */
		public var currentClient:IToolTipClient;

		/**
		 * 用于显示所有 ToolTip 的容器
		 */
		public var container:DisplayObjectContainer;

		public function client_onVisibleChange(target:IToolTipClient, visible:Boolean):void
		{
			if (visible)
			{
				checkAndShow(target);
			}
			else
			{
				hide(target);
			}
		}

		public function checkAndShow(target:IToolTipClient):void
		{
			var anchor:Rectangle = target.anchor;
			var mouseX:int = container.mouseX;
			var mouseY:int = container.mouseY;

			if (mouseX >= anchor.x && mouseY >= anchor.y)
			{
				if (mouseX <= anchor.x + anchor.width && mouseY <= anchor.y + anchor.height)
				{
					show(target);
				}
			}
		}

		public function show(target:IToolTipClient):void
		{
			if (currentClient)
			{
				hide(currentClient);
			}
			target.onMove.add(updatePosition);
			target.onResize.add(updatePosition);
			currentClient = target;
			currentToolTip = ToolTipFactory.get(target.tipContent);
			currentToolTip.show(target, container);
		}

		public function hide(target:IToolTipClient):void
		{
			if (currentToolTip && target == currentClient)
			{
				target.onMove.remove(updatePosition);
				target.onResize.remove(updatePosition);
				currentToolTip.hide();
				currentToolTip = null;
				currentClient = null;
			}
		}

		public function updatePosition(target:IToolTipClient):void
		{
			if (!currentToolTip)
			{
				throw new IllegalOperationError("错误的调用了 updatePosition");
			}
			currentToolTip.updatePosition(target);
		}
	}
}
