package nt.ui.components
{
	import nt.ui.core.Component;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class RichTextArea extends RichText implements IViewport
	{
		private var tweenRenderRect:TweenRenderRect;

		public function RichTextArea(width:int = 400, height:int = 250, maxLines:uint = 500)
		{
			super(width, height, maxLines);
			tweenRenderRect = new TweenRenderRect(this, delta);
		}

		override protected function renderBlocks():void
		{
			super.renderBlocks();

			// 使用最后一个 block 计算 contentHeight
			if (blockRenderers.length > 0)
			{
				contentHeight = blockRenderers[blockRenderers.length - 1].height + blockRenderers[blockRenderers.length - 1].y;
			}

			if (_autoScroll && _needAutoScroll)
			{
				positionY = _contentHeight - height;
			}
		}

		override protected function render():void
		{
			super.render();

			if (!renderRect)
			{
				throw new Error("RichTextArea 必须设置 width 和 height");
			}
			tweenRenderRect.y = _positionV;
		}

		private var _contentHeight:int;

		public function get contentHeight():int
		{
			return _contentHeight;
		}

		public function set contentHeight(value:int):void
		{
			_contentHeight = value;
			_onContentHeightChange.dispatch(this);
		}

		public function get delta():int
		{
			return defaultFormat.fontSize;
		}

		private var _positionV:int;

		public function get positionY():int
		{
			return _positionV;
		}

		public function set positionY(value:int):void
		{
			_positionV = value;

			if (_positionV > contentHeight - height)
			{
				_positionV = contentHeight - height;
				_autoScroll = true;
			}
			else if (_positionV < 0)
			{
				_positionV = 0;
			}
			invalidateNow();
			_onPositionYChange.dispatch(this);
		}

		private var _autoScroll:Boolean = true;

		public function get autoScroll():Boolean
		{
			return _autoScroll;
		}

		public function set autoScroll(value:Boolean):void
		{
			_autoScroll = value;
		}
		
		private var _needAutoScroll:Boolean = true;
		
		public function get needAutoScroll():Boolean
		{
			return _needAutoScroll;
		}
		
		public function set needAutoScroll(value:Boolean):void
		{
			_needAutoScroll = value;
		}

		private var _onContentHeightChange:ISignal = new Signal(Component);

		public function get onContentHeightChange():ISignal
		{
			return _onContentHeightChange;
		}

		private var _onPositionYChange:ISignal = new Signal(Component);

		public function get onPositionYChange():ISignal
		{
			return _onPositionYChange;
		}

		public function get contentWidth():int
		{
			return width;
		}

		public function get onContentWidthChange():ISignal
		{
			// 不会有宽度变化
			return null;
		}

		private var _onPositionXChange:ISignal;

		public function get onPositionXChange():ISignal
		{
			// 该事件不会被触发，因为 RichTextArea 不会有横向滚动条
			return _onPositionXChange ||= new Signal(Component);;
		}

		public function get positionX():int
		{
			return 0;
		}

		public function set positionX(value:int):void
		{
			// 不作任何事情
		}
	}
}
