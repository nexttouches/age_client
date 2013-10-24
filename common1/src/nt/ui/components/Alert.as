package nt.ui.components
{
	import nt.ui.core.Component;
	import nt.ui.util.LayoutParser;
	import nt.ui.util.PopUpManager;

	public class Alert extends FramePanel
	{
		public static function show(text:String, onOK:Function = null):void
		{
			getInstance().show(text, onOK);
		}

		public static function confirm(text:String, onOK:Function):void
		{
			getInstance().confirm(text, onOK);
		}

		private static var _instance:Alert;

		public static function getInstance():Alert
		{
			return _instance ||= new Alert();
		}

		public function Alert(skin:* = null)
		{
			super(skin);
			this.width = 200;
			this.height = 100;
			this.title = "{Hint}";
			this.isShowCloseButton = false;
		}

		private var content:Component;

		private var onOK:Function;

		public function onClickOK(target:Component):void
		{
			onClickCancel(target);

			if (onOK != null)
			{
				onOK();
				onOK = null;
			}
		}

		public function onClickCancel(target:Component):void
		{
			PopUpManager.remove(this);
			removeChild(content);
			content = null;
		}

		public function show(text:*, onOK:Function):void
		{
			if (parent)
			{
				PopUpManager.remove(this);
			}
			PopUpManager.add(this, true, 0, true);
			this.onOK = onOK;
			content = LayoutParser.parse(LAYOUT_OK, this);
			Label(content.get("text")).text = text;
			addChild(content);
		}

		public function confirm(text:*, onOK:Function):void
		{
			if (parent)
			{
				PopUpManager.remove(this);
			}
			PopUpManager.add(this, true, 0, true);
			this.onOK = onOK;
			content = LayoutParser.parse(LAYOUT_OK_CANCLE, this);
			Label(content.get("text")).text = text;
			addChild(content);
		}
	}
}

const LAYOUT_OK_CANCLE:XML = <VBox x="8" y="37" id="box" width="180" height="60" align="center">
		<Label id="text" text="" width="180" height="20"/>
		<HBox><PushButton label="{OK}" onClick="onClickOK"/><PushButton label="{Cancel}" onClick="onClickCancel" /></HBox>
	</VBox>

const LAYOUT_OK:XML = <VBox x="8" y="37" id="box" width="180" height="60" align="center">
		<Label id="text" text="" width="180" height="20" />
		<PushButton label="{OK}" onClick="onClickOK"/>
	</VBox>
