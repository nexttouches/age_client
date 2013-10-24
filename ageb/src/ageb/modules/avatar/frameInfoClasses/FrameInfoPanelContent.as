package ageb.modules.avatar.frameInfoClasses
{
	import spark.components.NavigatorContent;
	import ageb.modules.Modules;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.AvatarDocument;

	/**
	 * 每个类型的帧的子面板
	 * @author zhanghaocong
	 *
	 */
	public class FrameInfoPanelContent extends NavigatorContent
	{
		/**
		 * 默认标题
		 */
		public static const LABEL_FORMAT:String = "帧（{0}:{1}）";

		/**
		 * constructor
		 *
		 */
		public function FrameInfoPanelContent()
		{
			super();
			percentWidth = 100;

			if (skinClass)
			{
				setStyle("skinClass", skinClass);
			}
		}

		/**
		 * 设置或获取是否跨图层选择
		 */
		public var isCrossLayer:Boolean;

		private var _keyframes:Vector.<FrameInfoEditable>;

		/**
		 * 选中帧的所有关键帧
		 */
		public function get keyframes():Vector.<FrameInfoEditable>
		{
			return _keyframes;
		}

		/**
		 * @private
		 */
		public function set keyframes(value:Vector.<FrameInfoEditable>):void
		{
			if (keyframe)
			{
				label = "";
			}
			_keyframes = value;

			if (keyframe)
			{
				label = format(LABEL_FORMAT, keyframe.parent.name, keyframe.index);
			}
		}

		private var _frames:Vector.<FrameInfoEditable>;

		/**
		 * 设置或获取当前显示的 FrameInfo(s)
		 * @return
		 *
		 */
		public function get frames():Vector.<FrameInfoEditable>
		{
			return _frames;
		}

		public function set frames(value:Vector.<FrameInfoEditable>):void
		{
			_frames = value;
		}

		/**
		 * 当前渲染的关键帧（是 keyframes[0]）
		 * @return
		 *
		 */
		protected function get keyframe():FrameInfoEditable
		{
			return _keyframes && _keyframes.length > 0 ? keyframes[0] : null;
		}

		/**
		 * 设置当前使用的皮肤类
		 * @return
		 *
		 */
		protected function get skinClass():Class
		{
			return null;
		}

		/**
		 * 当前打开了的 AvatarDocument
		 * @return
		 *
		 */
		protected function get doc():AvatarDocument
		{
			return Modules.getInstance().document.currentDoc as AvatarDocument;
		}
	}
}
