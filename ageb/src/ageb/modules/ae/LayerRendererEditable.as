package ageb.modules.ae
{
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.assets.LayerInfo;
	import age.renderers.LayerRenderer;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	/**
	 * 可编辑的图层渲染器<br>
	 * 为编辑器提供专用的接口
	 * @author zhanghaocong
	 *
	 */
	public class LayerRendererEditable extends LayerRenderer
	{
		private var top:ArrangableQuad = new ArrangableQuad(1, 1, 0xffff00);

		private var left:ArrangableQuad = new ArrangableQuad(1, 1, 0xffff00);

		private var right:ArrangableQuad = new ArrangableQuad(1, 1, 0xffff00);

		private var bottom:ArrangableQuad = new ArrangableQuad(1, 1, 0xffff00);

		private var widthField:ArrangableTextField = new ArrangableTextField();

		private var heightField:ArrangableTextField = new ArrangableTextField();

		public function LayerRendererEditable(bgRendererClass:Class = null, objectRendererClass:Class = null)
		{
			super(bgRendererClass || BgRendererEditable, objectRendererClass || ObjectRendererEditable);
			widthField.pivotX = widthField.width / 2;
			widthField.pivotY = widthField.height;
			widthField.hAlign = HAlign.CENTER;
			widthField.vAlign = VAlign.TOP
			heightField.pivotX = heightField.width + 2;
			heightField.pivotY = heightField.height / 2;
			heightField.hAlign = HAlign.RIGHT;
		}

		/**
		 * 绘制轮廓
		 *
		 */
		public function removeOutline():void
		{
			if (info)
			{
				top.removeFromParent();
				left.removeFromParent();
				right.removeFromParent();
				bottom.removeFromParent();
				widthField.removeFromParent();
				heightField.removeFromParent();
			}
		}

		/**
		 * 绘制轮廓
		 *
		 */
		public function addOutline():void
		{
			if (info)
			{
				top.width = info.scaledWidth;
				left.height = info.scaledHeight;
				right.height = left.height;
				right.x = top.width;
				bottom.width = top.width;
				bottom.y = left.height;
				widthField.text = format("{0} ({1})", top.width.toFixed(3), info.scrollRatio.toFixed(2));
				widthField.x = top.width / 2;
				heightField.text = left.height.toFixed(3) + " (" + info.scrollRatio.toFixed(2) + ")";
				heightField.y = left.height / 2;
				addChild(top);
				addChild(left);
				addChild(right);
				addChild(bottom);
				addChild(widthField);
				addChild(heightField);
			}
		}

		override public function set info(value:LayerInfo):void
		{
			if (infoEditable)
			{
				infoEditable.objectsVectorList.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onObjectsChange);
				infoEditable.bgsVectorList.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onBgsChange);
			}
			removeOutline();
			super.info = value;
			addOutline();

			if (infoEditable)
			{
				infoEditable.objectsVectorList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onObjectsChange);
				infoEditable.bgsVectorList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onBgsChange);
			}
		}

		protected function onBgsChange(event:CollectionEvent):void
		{
			var info:BGInfoEditable;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					addBg(info);
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					removeBg(info);
				}
			}
		}

		protected function onObjectsChange(event:CollectionEvent):void
		{
			var info:ObjectInfoEditable;

			if (event.kind == CollectionEventKind.ADD)
			{
				for each (info in event.items)
				{
					addObject(info);
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				for each (info in event.items)
				{
					removeObject(info);
				}
			}
		}

		/**
		 * 关闭 flatten 功能
		 *
		 */
		override public function flatten():void
		{
			return;
		}

		private var _isShowLayerOutline:Boolean;

		/**
		 * 设置或获取是否显示轮廓
		 * @return
		 *
		 */
		public function get isShowLayerOutline():Boolean
		{
			return _isShowLayerOutline;
		}

		public function set isShowLayerOutline(value:Boolean):void
		{
			_isShowLayerOutline = value;
			top.isVisibleLocked = left.isVisibleLocked = right.isVisibleLocked = bottom.isVisibleLocked = widthField.isVisibleLocked = heightField.isVisibleLocked = false;
			top.visible = left.visible = right.visible = bottom.visible = widthField.visible = heightField.visible = value;
			top.isVisibleLocked = left.isVisibleLocked = right.isVisibleLocked = bottom.isVisibleLocked = widthField.isVisibleLocked = heightField.isVisibleLocked = true;
		}

		override protected function get gridCellClass():Class
		{
			return GridCellRendererEditable;
		}

		protected function get infoEditable():LayerInfoEditable
		{
			return _info as LayerInfoEditable;
		}

		override protected function get regionInfoRendererClass():Class
		{
			return RegionInfoRendererEditable;
		}
	}
}
