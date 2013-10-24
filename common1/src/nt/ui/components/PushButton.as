package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import nt.lang.L;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.SkinnableComponent;

	/**
	 * PushButton 定义了按钮组件
	 * @author KK
	 *
	 */
	public class PushButton extends SkinnableComponent
	{

		[Skin(optional=true)]
		public var upLabel:Label;

		[Skin]
		public var upBg:Scale9Image;

		[Skin(optional=true)]
		public var downLabel:Label;

		[Skin]
		public var downBg:Scale9Image;

		public function PushButton(skin:* = null)
		{
			super(skin || DefaultStyle.PushButtonSkin);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			buttonMode = true;
			mouseChildren = false;

			if (upLabel)
			{
				upLabel.autoSize = true;
			}

			if (downLabel)
			{
				downLabel.autoSize = true;
			}
			// tipContent = "<body><p>测试一下换行<br/>换</p><p color=\"0xff0000\">换P!<emo id=\"1\"/></p></body>"
		}

		override public function set height(value:Number):void
		{
			upBg.height = value;
			downBg.height = value;
			super.height = value;
		}

		override public function set width(value:Number):void
		{
			upBg.width = value;
			downBg.width = value;
			super.width = value;
		}

		override public function setSkin(value:DisplayObject):void
		{
			super.setSkin(value);
			state = PushButtonState.UP;
		}

		protected function mouseDownHandler(event:MouseEvent):void
		{
			state = PushButtonState.DOWN;
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}

		protected function stage_mouseUpHandler(event:MouseEvent):void
		{
			state = PushButtonState.UP;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}

		private var _minWidth:int;

		public function get minWidth():int
		{
			return _minWidth;
		}

		public function set minWidth(value:int):void
		{
			_minWidth = value;
			invalidate();
		}

		private var _padding:int = 8;

		public function get padding():int
		{
			return _padding;
		}

		public function set padding(value:int):void
		{
			_padding = value;
			invalidateNow();
		}

		private var _label:String;

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			value = L.localize(value);
			_label = value;
			downLabel.text = value;
			upLabel.text = value;
			invalidateNow();
		}

		private var stateChanged:Boolean;

		private var _state:String;

		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
			stateChanged = true;
			invalidate();
		}

		override protected function render():void
		{
			if (stateChanged)
			{
				stateChanged = false;
				upBg.visible = false;
				downBg.visible = false;

				if (state == PushButtonState.UP)
				{
					upBg.visible = true;
				}
				else if (state == PushButtonState.DOWN)
				{
					downBg.visible = true;
				}

				if (upLabel)
				{
					upLabel.visible = upBg.visible;
				}

				if (downLabel)
				{
					downLabel.visible = downBg.visible;
				}
			}
			super.render();

			// 有 Label
			if (upLabel)
			{
				if (_width == 0)
				{
					width = Math.max(upLabel.width + padding, minWidth);
				}

				if (_height == 0)
				{
					height = 22;
				}
				upLabel.y = (_height - upLabel.height) >> 1;
				downLabel.y = (_height - downLabel.height) >> 1;
			}
			else
			{
				width = upBg.skin.width;
				height = upBg.skin.height;
			}

			if (downLabel)
			{
				downLabel.x = (_width - downLabel.width) >> 1;
			}

			if (upLabel)
			{
				upLabel.x = (_width - upLabel.width) >> 1;
			}
		}

		/**
		* 设置或获取颜色
		* @return
		*
		*/
		public function get color():uint
		{
			return upLabel.color;
		}

		public function set color(value:uint):void
		{
			upLabel.color = value;
			downLabel.color = value;
		}

		/**
		 * 设置或获取是否使用粗体
		 * @return
		 *
		 */
		public function get bold():Boolean
		{
			return upLabel.bold;
		}

		public function set bold(value:Boolean):void
		{
			upLabel.bold = value;
			downLabel.bold = value;
		}
	}
}
