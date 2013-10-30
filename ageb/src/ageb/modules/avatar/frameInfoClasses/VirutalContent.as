package ageb.modules.avatar.frameInfoClasses
{
	import flash.events.Event;
	import spark.components.NumericStepper;
	import age.assets.Box;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.avatar.op.ChangeFrameBox;

	/**
	 * 类型为 VIRUTAL 的 FrameInfo 的面板<br>
	 * 主要操作了 box 属性
	 * @author zhanghaocong
	 *
	 */
	public class VirutalContent extends FrameInfoPanelContent
	{

		[SkinPart(required="true")]
		public var xField:NumericStepper;

		[SkinPart(required="true")]
		public var yField:NumericStepper;

		[SkinPart(required="true")]
		public var zField:NumericStepper;

		[SkinPart(required="true")]
		public var widthField:NumericStepper;

		[SkinPart(required="true")]
		public var heightField:NumericStepper;

		[SkinPart(required="true")]
		public var depthField:NumericStepper;

		[SkinPart(required="true")]
		public var pivotXField:NumericStepper;

		[SkinPart(required="true")]
		public var pivotYField:NumericStepper;

		[SkinPart(required="true")]
		public var pivotZField:NumericStepper;

		/**
		 * 创建一个新的 VirutalContent
		 *
		 */
		public function VirutalContent()
		{
			super();
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function get skinClass():Class
		{
			return VirtualContentSkin;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			xField.addEventListener(Event.CHANGE, doChangeBox);
			yField.addEventListener(Event.CHANGE, doChangeBox);
			zField.addEventListener(Event.CHANGE, doChangeBox);
			widthField.addEventListener(Event.CHANGE, doChangeBox);
			heightField.addEventListener(Event.CHANGE, doChangeBox);
			depthField.addEventListener(Event.CHANGE, doChangeBox);
			pivotXField.addEventListener(Event.CHANGE, doChangeBox);
			pivotYField.addEventListener(Event.CHANGE, doChangeBox);
			pivotZField.addEventListener(Event.CHANGE, doChangeBox);
		}

		/**
		 * @private
		 * @param event
		 *
		 */
		protected function doChangeBox(event:Event):void
		{
			const box:Box = new Box(xField.value, yField.value, zField.value, widthField.value, heightField.value, depthField.value, pivotXField.value, pivotYField.value, pivotZField.value);
			new ChangeFrameBox(doc, keyframes, box).execute();
		}

		/**
		 * @inheritDoc
		 * @param value
		 *
		 */
		override public function set keyframes(value:Vector.<FrameInfoEditable>):void
		{
			if (keyframe)
			{
				keyframe.onBoxChange.remove(onBoxChange);
			}
			super.keyframes = value;

			if (keyframe)
			{
				keyframe.onBoxChange.add(onBoxChange);
			}
			onBoxChange();
		}

		/**
		 * @private
		 *
		 */
		private function onBoxChange():void
		{
			if (keyframe && keyframe.box)
			{
				// 关键帧
				const box:Box = keyframe.box;
				xField.value = box.x
				yField.value = box.y;
				zField.value = box.z;
				widthField.value = box.width;
				heightField.value = box.height;
				depthField.value = box.depth;
				pivotXField.value = box.pivot.x;
				pivotYField.value = box.pivot.y;
				pivotZField.value = box.pivot.z;
			}
			else
			{
				// 空白关键帧
				xField.value = 0;
				yField.value = 0;
				zField.value = 0;
				widthField.value = 0;
				heightField.value = 0;
				depthField.value = 0;
				pivotXField.value = 0;
				pivotYField.value = 0;
				pivotZField.value = 0;
			}
		}
	}
}
