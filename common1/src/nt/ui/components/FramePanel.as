package nt.ui.components
{
	import flash.display.DisplayObject;
	import nt.lang.L;
	import nt.lib.reflect.Type;
	import nt.ui.configs.DefaultStyle;
	import nt.ui.core.Component;
	import nt.ui.util.PopUpManager;

	public class FramePanel extends Panel
	{

		[Skin]
		public var closeButton:PushButton;

		[Skin]
		public var titleField:Label;

		public function FramePanel(skin:* = null)
		{
			super(skin || DefaultStyle.FramePanelSkin);
			// bg.tipContent = "<body><p>单击空白处以拖拽</p></body>";
		}

		override public function set width(value:Number):void
		{
			super.width = value;
			titleField.width = value;
		}

		override public function setSkin(value:DisplayObject):void
		{
			super.setSkin(value);

			if (!_title)
			{
				// 从语言包中提一个默认的标题
				title = L[Type.of(this).shortname];
			}
			// FramePanel 默认可拖动
			isDraggable = true;
			closeButton.onClick.add(closeButton_clickHandler);
		}

		protected function closeButton_clickHandler(target:Component):void
		{
			if (PopUpManager.has(this))
			{
				close();
			}
			else if (parent)
			{
				parent.removeChild(this);
			}
		}

		override protected function render():void
		{
			super.render();
			closeButton.x = bg.width - 25 - closeButton.width;
			closeButton.y = 9;
		}

		private var _title:String;

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;

			if (titleField)
			{
				titleField.text = value;
			}
		}

		private var _isShowCloseButton:Boolean;

		public function get isShowCloseButton():Boolean
		{
			return _isShowCloseButton;
		}

		public function set isShowCloseButton(value:Boolean):void
		{
			_isShowCloseButton = value;
			closeButton.visible = value;
		}
	}
}
