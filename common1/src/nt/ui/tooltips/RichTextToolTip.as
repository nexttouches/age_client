package nt.ui.tooltips
{
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	import nt.ui.components.RichText;
	import nt.ui.components.Scale9Image;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.IToolTipClient;
	import nt.ui.core.SkinnableComponent;

	public class RichTextToolTip extends SkinnableComponent implements IToolTip
	{
		public static const PADDING:int = 3;

		public static const WIDTH:int = 300;

		public static const DISTANCE:int = 7;

		public var bg:Scale9Image;

		public var label:RichText;

		public function RichTextToolTip()
		{
			super();
			bg = new Scale9Image(DefaultStyle.ToolTipBg);
			addChild(bg);
			label = new RichText();
			label.x = label.y = PADDING;
			label.width = WIDTH;
			label.height = 0;
			label.autoHeight = true;
			label.autoWidth = true;
			// label 内容更新后再决定要出现的位置，这可以避免闪烁
			label.onRender.add(position);
			addChild(label);
			mouseChildren = false;
			mouseEnabled = false;
		}

		private function position(target:IToolTipClient):void
		{
			bg.width = label.width + (PADDING << 1);
			bg.height = label.height + (PADDING << 1);
			x = targetAnchor.x + (targetAnchor.width >> 1) - (bg.width >> 1);
			y = targetAnchor.y + targetAnchor.height + DISTANCE;

			if (container != this)
			{
				container.addChild(this);
			}
		}

		private var container:DisplayObjectContainer;

		private var targetAnchor:Rectangle;

		public function show(target:IToolTipClient, container:DisplayObjectContainer):void
		{
			// 记下要显示的位置
			targetAnchor = target.anchor;
			// 记一下视图
			this.container = container;
			// 设置内容
			label.content = XML(target.tipContent);
			// 此时尚未添加到显示列表，所以 label 的内容不会自动更新，需要手动刷一下
			label.invalidateNow();
		}

		public function updatePosition(target:IToolTipClient):void
		{
			targetAnchor = target.anchor;
			position(target);
		}

		public function hide():void
		{
			if (!container)
			{
				throw new IllegalOperationError("ToolTip 被添加之前，请不要重复调用 hide");
			}

			if (parent)
			{
				container.removeChild(this);
			}
			targetAnchor = null;
			container = null;
		}
	}
}
