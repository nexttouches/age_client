package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.Event;
	import spark.components.NumericStepper;
	import age.assets.Box;
	import ageb.modules.ae.AvatarInfoEditable;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.ChangeAvatarSize;
	import nt.lib.util.assert;

	/**
	 * Avatar 属性面板
	 * @author zhanghaocong
	 *
	 */
	public class AvatarContent extends FrameInfoPanelContent
	{

		[SkinPart(required="true")]
		public var widthField:NumericStepper;

		[SkinPart(required="true")]
		public var heightField:NumericStepper;

		[SkinPart(required="true")]
		public var depthField:NumericStepper;

		/**
		 * constructor
		 *
		 */
		public function AvatarContent()
		{
			super();
			label = "Avatar 属性";
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get skinClass():Class
		{
			return AvatarContentSkin;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			widthField.addEventListener(Event.CHANGE, onChange);
			heightField.addEventListener(Event.CHANGE, onChange);
			depthField.addEventListener(Event.CHANGE, onChange);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function onChange(event:Event):void
		{
			new ChangeAvatarSize(doc, new Box(0, 0, 0, widthField.value, heightField.value, depthField.value, 0.5, 0, 0.5)).execute();
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set frames(value:Vector.<FrameInfoEditable>):void
		{
			assert(value == null || value.length == 0);

			if (value == null)
			{
				info = null;
			}
			else
			{
				info = doc.avatar;
			}
		}

		private var _info:AvatarInfoEditable;

		/**
		 * 设置或获取当前显示的 AvatarInfoEditable
		 * @return
		 *
		 */
		public function get info():AvatarInfoEditable
		{
			return _info;
		}

		public function set info(value:AvatarInfoEditable):void
		{
			if (_info)
			{
				_info.onSizeChange.remove(onSizeChange);
			}
			_info = value;

			if (_info)
			{
				_info.onSizeChange.add(onSizeChange);
			}
			// force render
			onSizeChange();
		}

		/**
		 * 尺寸变化时回调
		 *
		 */
		private function onSizeChange():void
		{
			if (_info)
			{
				widthField.value = _info.size.width;
				heightField.value = _info.size.height;
				depthField.value = _info.size.depth;
			}
			else
			{
				widthField.value = 0;
				heightField.value = 0;
				depthField.value = 0;
			}
		}
	}
}
