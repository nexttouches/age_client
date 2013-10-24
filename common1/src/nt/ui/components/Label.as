package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	import nt.lang.L;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.Component;
	import nt.ui.core.ISkinnable;

	/**
	 * Label 使用 FTE 渲染文本
	 * @author KK
	 *
	 */
	public class Label extends Component implements ISkinnable
	{
		protected var block:TextBlock;

		protected var format:ElementFormat;

		protected var element:TextElement;

		protected var line:TextLine;

		/**
		 * 创建一个新的 Label 对象<br/>
		 * Label 会设置与指定的 TextField 一样的文本格式（字体，加粗，颜色）
		 * @param tf
		 * @see ISkinnableComponent
		 */
		public function Label(tf:TextField = null)
		{
			mouseEnabled = false;
			mouseChildren = false;
			setSkin(tf);
			block = new TextBlock();
			element = new TextElement();
		}

		public function setSkin(value:DisplayObject):void
		{
			var tf:TextField = value as TextField;

			if (!tf)
			{
				format = DefaultStyle.Format.clone();
			}
			else
			{
				var textFormat:TextFormat = tf.defaultTextFormat;
				var fd:FontDescription;

				if (textFormat.bold)
				{
					fd = DefaultStyle.FontBold;
				}
				else
				{
					fd = DefaultStyle.Font;
				}
				format = new ElementFormat(fd, Number(textFormat.size), uint(textFormat.color), Number(tf.alpha));
				// 不要忘记滤镜
				filters = tf.filters;
				// 调整坐标，请注意 TextField 有 2 像素 margin 也要算进去
				x = tf.x + 2;
				y = tf.y + 2;
				tf.parent.removeChild(tf);
			}
		}

		/**
		 * 设置或获取颜色
		 * @return
		 *
		 */
		public function get color():uint
		{
			return format.color;
		}

		public function set color(value:uint):void
		{
			format.color = value;
			textChanged = true;
			invalidate();
		}

		private var _bold:Boolean;

		/**
		 * 设置或获取是否使用粗体
		 * @return
		 *
		 */
		public function get bold():Boolean
		{
			return _bold;
		}

		public function set bold(value:Boolean):void
		{
			_bold = value;

			if (value)
			{
				format = DefaultStyle.FormatBold.clone();
			}
			else
			{
				format = DefaultStyle.Format.clone();
			}
			textChanged = true;
			invalidate();
		}

		override protected function render():void
		{
			if (textChanged)
			{
				if (_text.length > 0)
				{
					textChanged = false;
					element.elementFormat = format;
					element.text = _text;
					block.content = element;

					if (line)
					{
						line = block.recreateTextLine(line);
					}
					else
					{
						line = block.createTextLine();
					}

					if (line)
					{
						line.y = line.ascent;
						addChild(line);

						if (_autoSize || _width == 0)
						{
							width = line.width;
						}
						else
						{
							//line.x = (_width - line.width) >> 1;
						}

						if (_autoSize || _height == 0)
						{
							height = line.totalHeight;
						}
						else
						{
							//line.y = (_height - line.totalHeight + line.totalDescent) >> 1;
						}
							// FIXME 这里可能需要 +2 ，否则有些字体有问题
					}
					block.releaseLineCreationData();
					block.releaseLines(line, line);
				}
				else
				{
					if (line && line.parent)
					{
						removeChild(line);
						line = null;
					}
				}
			}
			super.render();
		}

		protected var _text:String = "";

		private var textChanged:Boolean;

		public function set text(value:*):void
		{
			value = L.localize(value);

			if (value != _text)
			{
				textChanged = true;
				_text = value;

				if (_text == null)
				{
					_text = "";
				}
				invalidateNow();
			}
		}

		public function get text():String
		{
			return _text;
		}

		private var _autoSize:Boolean;

		public function get autoSize():Boolean
		{
			return _autoSize;
		}

		public function set autoSize(value:Boolean):void
		{
			_autoSize = value;
			invalidate();
		}
	}
}
