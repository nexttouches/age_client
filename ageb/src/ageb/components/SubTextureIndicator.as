package ageb.components
{
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import mx.core.UIComponent;

	/**
	 * 子贴图区块渲染器
	 * @author zhanghaocong
	 *
	 */
	public class SubTextureIndicator extends UIComponent
	{
		private var tf:TextField;

		public function SubTextureIndicator()
		{
			super();
			mouseChildren = false;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.filters = [ new GlowFilter(0, 1, 2, 2, 10)];
			tf.x = 1;
			tf.y = 1;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.defaultTextFormat = new TextFormat("微软雅黑", 24, 0xffffff);
			addChild(tf);
		}

		private var _isSelected:Boolean;

		[Bindable("nodeChanged")]
		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
			invalidateDisplayList();
		}

		private var _node:XML;

		[Bindable("nodeChanged")]
		public function get node():XML
		{
			return _node;
		}

		/**
		 * 设置或获取当前渲染的 SubTexture
		 * @param value
		 *
		 */
		public function set node(value:XML):void
		{
			_node = value;
			x = node.@x;
			y = node.@y;
			width = node.@width;
			height = node.@height;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();

			if (isSelected)
			{
				graphics.beginFill(0x00ff00, 0.2);
				graphics.lineStyle(2, 0x00ff00, 0.5);
			}
			else
			{
				graphics.beginFill(0x00ff00, 0.1);
			}
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			tf.text = node.@name;
		}
	}
}
