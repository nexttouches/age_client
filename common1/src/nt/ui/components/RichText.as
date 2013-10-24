package nt.ui.components
{
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import nt.lib.util.getURL;
	import nt.ui.components.richtextclasses.TextBlockRenderer;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.Component;
	import nt.ui.debug.DebugHelper;
	import org.osflash.signals.Signal;

	public class RichText extends Component
	{
		protected static const OverrideStyleAttributes:Array = [ "@color", "@underline",
																 "@bold" ];

		/**
		 * 默认字体尺寸和颜色<br/>
		 * 在所有 RichText 实例中共享
		 */
		protected static var defaultFormat:ElementFormat = DefaultStyle.Format.clone();
		// 设置文字对齐方式，IDEOGRAPHIC_BOTTOM 表示无论文字还是图片，都使用底对齐
		defaultFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_BOTTOM;
		defaultFormat.alignmentBaseline = TextBaseline.IDEOGRAPHIC_BOTTOM;

		protected var blocks:Vector.<TextBlock> = new Vector.<TextBlock>;

		protected var blockRenderers:Vector.<TextBlockRenderer> = new Vector.<TextBlockRenderer>;

		protected var linkDispatcher:EventDispatcher;

		public function RichText(width:int = 400, height:int = 250, maxLine:uint = 500)
		{
			super();
			this.width = width;
			this.height = height;
			this.maxLines = maxLine;
			init();
		}

		private const testAppend:XML = <p lineHeight="10" underline="true" bold="true" color="0xffffff"><emo id="1"/><![CDATA[<emo id="1"/>超长的<br/>]]></p>;

		protected function init():void
		{
			content = <body spacing="5"></body>;
			// 给链接元素使用的侦听镜像
			linkDispatcher = new EventDispatcher();
			linkDispatcher.addEventListener(MouseEvent.MOUSE_OVER, link_mouseOverHandler);
			linkDispatcher.addEventListener(MouseEvent.MOUSE_OUT, link_mouseOutHandler);
			linkDispatcher.addEventListener(MouseEvent.CLICK, link_clickHandler);
			linkDispatcher.addEventListener(MouseEvent.MOUSE_MOVE, link_mouseMoveHandler);
			linkDispatcher.addEventListener(MouseEvent.MOUSE_DOWN, link_mouseDownHandler);
		}

		private var isInTest:Boolean;

		public function runTest(extras:XML = null):void
		{
			if (isInTest)
			{
				throw new IllegalOperationError("已经在测试模式了");
			}
			isInTest = true;
			content = <body spacing="5">
					<p color="0xff0000" lineSpacing="12">间距特别长的红的1第一行没<br/>有图片</p><p>2第<span color="0x00ff00" underline="true">绿色</span>一行没有图片</p>
					<p color="0xff0000" bold="true" underline="true"><![CDATA[又粗又长又红还带下划线又粗又长又红还带下划线又粗又长又红还带下划线]]><emo id="1"/></p>
					<p>1<span underline="true">换个行<span underline="false">好</span>痛苦</span><emo id="1"/>图<emo id="1"/>文<emo id="1"/>混<emo id="1"/>排。<emo id="1"/>图<emo id="1"/>文<emo id="1"/>混<emo id="1"/>排</p>
					<p>2<emo id="1"/>图<emo id="1"/>文<emo id="1"/>混<emo id="1"/>排；</p>;
					<p><a href="http://www.google.com" underline="true" color="0x0000ff">谷歌<emo id="1"/></a>SPACE<a href="http://www.baidu.com">百度</a></p>
					<p><a color="0xffffff" href="http://www.baidu.com"><span color="0xff0000">百度</span></a>尼玛</p>
					<p>最后一行也没有图片<span underline="true">下划线<span underline="false" color="0x0x0000ff">我没有下划线</span>好痛苦</span></p>
					<p><a href="event:fireOnLink">event:fireOnLink breakline</a></p>
					<p>力量	+10000	智力	+5</p>
					<p>防御力	+3000	攻击力	+10</p>
				</body>;

			if (extras)
			{
				content.appendChild(extras);
			}
			var i:int = 0;
			var id:int = setInterval(function():void
			{
				i++;
				append(<p>测试{i}</p>);

				if (i >= 20)
				{
					clearInterval(id);
				}
			}, 100);
			// 测试 link 事件
			function this_onLink(target:RichText, text:String, element:ContentElement):void
			{
				trace("game.ui.components.RichText.this_onLink(target:RichText, text:String):void");
				trace(text, element.text);
			}
			onLink.add(this_onLink);
		}

		protected function link_mouseMoveHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
		}

		protected function link_mouseDownHandler(event:MouseEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			event.stopPropagation();
		}

		protected function link_clickHandler(event:MouseEvent):void
		{
			var line:TextLine = event.currentTarget as TextLine;

			for each (var region:TextLineMirrorRegion in line.mirrorRegions)
			{
				if (region.bounds.contains(line.mouseX, line.mouseY))
				{
					Mouse.cursor = MouseCursor.BUTTON;
					const sign:String = "event:";

					if (region.element.userData.href.indexOf(sign) == 0)
					{
						if (_onLink)
						{
							_onLink.dispatch(this, region.element.userData.href.substr(sign.length), region.element);
						}
					}
					else
					{
						getURL(region.element.userData.href);
					}
					break;
				}
			}
		}

		protected function link_mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}

		protected function link_mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
		}

		/**
		 * 追加时的内容缓存在这里
		 */
		private var appendContent:XML;

		/**
		 * 追加一行。该方法不会导致全局刷新，性能较好
		 * @param content
		 *
		 */
		public function append(p:XML):void
		{
			if (!appendContent)
			{
				appendContent = <body></body>;
			}
			// 下划线要是再出问题打开这里进行测试
			/*			p.prependChild(<font color="0xff00ff" underline="false">没有下划线</font>);
			p.prependChild(<font color="0xffffff" underline="true">有下划线</font>);
			p.prependChild(<font underline="true">很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线</font>);
			p.prependChild(<font color="0xff0000" underline="true">我只有一一一一小</font>);
			p.prependChild(<font color="0xff00ff" underline="false">没有下划线</font>);
			p.prependChild(<font color="0xffffff" underline="true">有下划线</font>);
			p.prependChild(<font underline="true">很长很长的下划线很长很<span color="0xff0000" underline="false">没有下划线</span>很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线很长很长的下划线</font>);
			*/
			appendContent.appendChild(p);
			invalidate();
		}

		/**
		 * added by no4matrix
		 * 追加一行。该方法不会导致全局刷新，性能较好
		 * 一个或多个<p>标签
		 * @param str
		 *
		 */
		public function appendString(str:String):void
		{
			try
			{
				var r:String = "<root>" + str + "</root>";
				var xml:XML = new XML(r);

				for each (var child:XML in xml..p)
				{
					this.append(child);
				}
			}
			catch (e:Error)
			{
			}
		}

		/**
		 * 合并 appendContent 到 content
		 *
		 */
		private function mergeAppendContent():void
		{
			if (appendContent)
			{
				_content.appendChild(appendContent.children());
				appendContent = null;
			}
		}

		private var contentChanged:Boolean;

		private var _content:XML;

		/**
		 * 设置或获取内容
		 * @return
		 *
		 */
		public function get content():XML
		{
			return _content;
		}

		public function set content(value:XML):void
		{
			contentChanged = true;
			_content = value;
			mergeAppendContent();
			invalidate();
		}

		private var _maxLines:uint = uint.MAX_VALUE;

		/**
		 * 设置或获取最大行数，该值越大性能越差<br/>
		 * 对于页游的聊天系统而言，50 行足矣
		 * @return
		 *
		 */
		public function get maxLines():uint
		{
			return _maxLines;
		}

		public function set maxLines(value:uint):void
		{
			if (_maxLines != value)
			{
				_maxLines = value;
				invalidate();
			}
		}

		protected var _onLink:Signal;

		public function get onLink():Signal
		{
			return _onLink ||= new Signal(RichText, String, ContentElement);
		}

		protected override function render():void
		{
			if (contentChanged || appendContent)
			{
				contentChanged = false;
				var bodyToParse:XML;

				// 决定只进行追加操作还是全局刷新
				if (appendContent)
				{
					bodyToParse = appendContent;
				}
				else
				{
					bodyToParse = _content;
					blocks.length = 0;
				}
				// 把每个 <p> 转换成 TextBlock
				var started:Number;
				started = getTimer();
				var newBlocks:Vector.<TextBlock> = parseBody(bodyToParse, _content);

				if (DebugHelper.showOutline)
				{
					traceex("[RichText] {1} parse completed in {0}", getTimer() - started, name);
				}
				blocks = blocks.concat(newBlocks);

				// 转换完毕后，尝试合并 appendContent 到 content（如果有）
				if (appendContent)
				{
					mergeAppendContent();
				}

				// 接下来删除多余的 blocks：先确认 blocks 的长度是否已超过 maxLines，如果已超过就丢弃
				while (blocks.length > _maxLines)
				{
					delete content..p[0]; // 不要忘记删掉 content
					blocks.shift();

					// 取出第一个并放到队列的最后，这样可以重复利用 TextBlockRenderer，最多只会有 n 个 TextBlockRenderer，n = maxLines
					if (blockRenderers.length > 1)
					{
						var renderer:TextBlockRenderer = blockRenderers.shift();
						renderer.block = null;
						blockRenderers.push(renderer);
					}
				}

				// 如果新的 content 行数比原来的小，则要把多出来的 blockRenderer 也删掉
				while (blocks.length < blockRenderers.length)
				{
					removeChild(blockRenderers.pop());
				}
				// 一切准备就绪，让 TextBlockRenderer 进行渲染
				started = getTimer();
				renderBlocks();

				if (DebugHelper.showOutline)
				{
					traceex("[RichText] {2} rendered in {0}, {1} blocks", getTimer() - started, blocks.length, name);
				}
			}
			super.render();
		}

		/**
		 * 渲染 TextBlockRenderer，该方法主要做排列操作，具体的渲染流程在 TextBlockRenderer 内部
		 *
		 */
		protected function renderBlocks():void
		{
			var lastRenderer:TextBlockRenderer;
			var n:int = blocks.length; // 先记一个 n 效率会更高

			for (var i:int = 0; i < n; i++)
			{
				var renderer:TextBlockRenderer;

				// 决定创建或重复利用 TextBlockRenderer
				if (blockRenderers.length - 1 >= i)
				{
					renderer = blockRenderers[i];
				}
				else
				{
					renderer = new TextBlockRenderer(_autoWidth ? 0 : _width);
					addChild(renderer);
					blockRenderers.push(renderer);
				}
				// 告诉 TextBlockRenderer 要渲染的 TextBlock
				renderer.block = blocks[i];

				// 重新排列位置
				if (lastRenderer)
				{
					renderer.y = lastRenderer.height + lastRenderer.y;
				}
				else
				{
					renderer.y = 0;
				}
				// 记录最后一个渲染器，以便下一循环排列
				lastRenderer = renderer;
			}

			if (_autoHeight && blockRenderers.length > 0)
			{
				height = blockRenderers[int(blockRenderers.length - 1)].height + blockRenderers[int(blockRenderers.length - 1)].y;
			}

			if (_autoWidth && blockRenderers.length > 0)
			{
				for each (renderer in blockRenderers)
				{
					i = Math.max(i, renderer.width);
				}
				width = i;
			}
			fireOnResize();
		}

		/**
		 * 转换节点到 TextBlock
		 * @param node
		 * @param styles
		 * @return
		 *
		 */
		protected function parseBody(node:XML, styles:XML):Vector.<TextBlock>
		{
			var result:Vector.<TextBlock> = new Vector.<TextBlock>;

			// add by no4matrix, 每个p标签作为一个TextBlock
			for each (var child:XML in node..p)
			{
				var block:TextBlock = new TextBlock(parseParagraph(child, styles));

				if (styles.hasOwnProperty("@spacing"))
				{
					if (!block.userData)
					{
						block.userData = {};
					}
					block.userData.spacing = int(styles.@spacing);
				}
				result.push(block);
			}
			return result;
		}

		protected function parseSpan(node:XML, styles:XML):GroupElement
		{
			var elements:Vector.<ContentElement> = new Vector.<ContentElement>;

			for each (var child:XML in node.children())
			{
				if (child.nodeKind() == "text") // 文本
				{
					elements.push(parseText(child, node));
				}
				else
				{
					overrideStyles(child, node);
					// TODO 找个 hash 存一下对应的分析方法以便扩展
					var nodeName:String = child.name();
					// modified by no4matrix, 统一转小写
					nodeName = nodeName.toLowerCase();

					if (nodeName == "a") // 超链接
					{
						elements.push(parseAnchor(child, node));
					}
					else if (nodeName == "emo") // 表情
					{
						// 确定需求后加回去
						if (emotionCreator != null)
						{
							var eElement:GraphicElement = parseEmotion(child, node);

							// add by no4matrix, 增加合法性判断 
							if (null != eElement)
							{
								elements.push(eElement);
							}
						}
					}
					// modified by no4matrix, 支持font标签
					else if (nodeName == "span" || nodeName == "font") // span or font
					{
						elements.push(parseSpan(child, node));
					}
					else if (nodeName == "br") // 换行
					{
						elements.push(parseBreak(child, node));
					}
					else if (nodeName == "p")
					{
						throw new Error("不支持嵌套的 <p>");
					}
					else
					{
						throw new Error(format("不支持的 tag <{0}>", nodeName));
					}
				}
			}
			return new GroupElement(elements, defaultFormat)
		}

		/**
		 * 转换 P 到 GroupElement
		 * @param node
		 * @param styles
		 * @return
		 *
		 */
		protected function parseParagraph(node:XML, styles:XML):GroupElement
		{
			// 本质上 <p> 也是 <span> 的一种，利用一下 parseSpan 处理嵌套的元素
			var result:GroupElement = parseSpan(node, styles);

			// 设置行间距
			if (node.hasOwnProperty("@lineSpacing"))
			{
				if (!result.userData)
				{
					result.userData = {};
				}
				result.userData.lineSpacing = Number(node.@lineSpacing);
			}

			// add by no4matrix, 缩进
			if (node.hasOwnProperty("@indent"))
			{
				if (!result.userData)
				{
					result.userData = {};
				}
				result.userData.indent = Number(node.@indent);
			}
			return result;
		}

		/**
		 * 处理换行
		 * @param child
		 * @param node
		 * @return
		 *
		 */
		protected function parseBreak(child:XML, node:XML):ContentElement
		{
			// \n 表示换行
			// 另外在 flash 中 \r 也算一个换行
			// 由于控制台的 \r 是返回行首
			// 这里我们用的是 \n
			return parseText(child.copy().appendChild("\n"), node);
		}

		/**
		 * 处理 <a> 到 GroupElement
		 * @param node
		 * @param styles
		 * @return
		 *
		 */
		protected function parseAnchor(node:XML, styles:XML):GroupElement
		{
			// 本质上 <a> 也是 <span> 的一种，利用一下 parseSpan 处理嵌套的元素
			var result:GroupElement = parseSpan(node, styles);

			// link 可能没有 href 标签
			if (node.hasOwnProperty("@href"))
			{
				// 然后添加链接相关的属性
				if (!result.userData)
				{
					result.userData = {};
				}
				result.userData.href = node.@href;
				// 把 linkDispatcher 作为当前节点的事件镜像，以便可以接收到鼠标事件
				result.eventMirror = linkDispatcher;
			}
			return result;
		}

		/**
		 * 传递该方法来实现表情分析<br>
		 * 正确的签名应为<br>
		 * function emotionCreator (node:XML):DisplayObject
		 * {
		 * 	...
		 * }
		 */
		public var emotionCreator:Function;

		/**
		 * 转换表情节点到 GraphicElement
		 * @param node
		 * @param styles
		 * @return
		 *
		 */
		protected function parseEmotion(node:XML, styles:XML):GraphicElement
		{
			// 得到表情的 DisplayObject
			var emo:DisplayObject = emotionCreator(node);

			if (null == emo)
			{
				return null;
			}
			// 通常表情是不需要设置属性的，但是考虑到可能会被添加下划线，此时颜色和字体有作用了，所以还是要处理一下
			var newFormat:ElementFormat;

			if (styles.hasOwnProperty("@color") || styles.hasOwnProperty("@bold"))
			{
				newFormat = defaultFormat.clone();

				if (styles.hasOwnProperty("@color"))
				{
					newFormat.color = tryConvert2Color16(styles.@color);
				}

				if (styles.@bold == "true")
				{
					var description:FontDescription = newFormat.fontDescription.clone();
					description.fontWeight = FontWeight.BOLD;
					newFormat.fontDescription = description;
				}
			}
			else
			{
				newFormat = defaultFormat;
			}
			// 创建 GraphicElement 并设置下划线一些属性
			var result:GraphicElement = new GraphicElement(emo, emo.width, emo.height, newFormat);

			if (styles.hasOwnProperty("@underline"))
			{
				if (!result.userData)
				{
					result.userData = {};
				}
				result.userData.underline = styles.@underline == "true";
			}
			return result;
		}

		/**
		 * 转换 node 到 TextElement
		 * @param node
		 * @param styles
		 * @return
		 *
		 */
		protected function parseText(node:XML, styles:XML):TextElement
		{
			var newFormat:ElementFormat;

			if (styles.hasOwnProperty("@color") || styles.hasOwnProperty("@bold") || styles.hasOwnProperty("@lineSpacing") || styles.hasOwnProperty("@size"))
			{
				newFormat = defaultFormat.clone();

				if (styles.hasOwnProperty("@color"))
				{
					newFormat.color = tryConvert2Color16(styles.@color);
				}

				if (styles.@bold == "true")
				{
					var description:FontDescription = newFormat.fontDescription.clone();
					description.fontWeight = FontWeight.BOLD;
					newFormat.fontDescription = description;
				}

				// add by no4matrix, 字体大小
				if (styles.hasOwnProperty("@size"))
				{
					newFormat.fontSize = styles.@size;
				}
			}
			else
			{
				newFormat = defaultFormat;
			}
			var result:TextElement = new TextElement(node, newFormat);

			if (styles.hasOwnProperty("@underline"))
			{
				if (!result.userData)
				{
					result.userData = {};
				}
				result.userData.underline = styles.@underline == "true";
			}
			return result;
		}

		/**
		 * 覆盖样式
		 * @param node
		 * @param styles
		 *
		 */
		private function overrideStyles(node:XML, styles:XML):void
		{
			for each (var attr:String in OverrideStyleAttributes)
			{
				if (!node.hasOwnProperty(attr) && styles.hasOwnProperty(attr))
				{
					node[attr] = styles[attr]; // 如果当前节点没有并且父节点有该属性就覆盖
				}
			}
		}

		/**
		 * add by no4matrix
		 * #FFFFFF -> 0xFFFFFF
		 * @return
		 *
		 */
		private function tryConvert2Color16(color:String):uint
		{
			if (color.charAt(0) == "#")
			{
				var newColor:String = "0x" + color.substring(1);
				return uint(newColor);
			}
			return uint(color);
		}

		//1断行中1111111111111111111111111111111111111111111 111
		private var _autoHeight:Boolean;

		private var _autoWidth:Boolean;

		public function get autoWidth():Boolean
		{
			return _autoWidth;
		}

		public function set autoWidth(value:Boolean):void
		{
			if (value != _autoWidth)
			{
				_autoWidth = value;
				invalidate()
			}
		}

		public function get autoHeight():Boolean
		{
			return _autoHeight;
		}

		public function set autoHeight(value:Boolean):void
		{
			if (value != _autoHeight)
			{
				_autoHeight = value;
				invalidate();
			}
		}

		/**
		 * add by wangning
		 * clear content
		 */
		public function cleanContent():void
		{
			this.appendContent = null;
			this.content = <body spacing="5"></body>;
			invalidateNow();
		}

		override public function dispose():Boolean
		{
			if (_onLink)
			{
				_onLink.removeAll();
			}
			return super.dispose();
		}
	}
}
