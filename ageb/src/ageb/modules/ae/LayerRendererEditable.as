package ageb.modules.ae
{
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import age.data.LayerInfo;
	import age.data.LayerType;
	import age.renderers.BGRenderer;
	import age.renderers.LayerRenderer;
	import age.renderers.Quad3D;
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
		private var top:Quad3D = new Quad3D(1, 1, 0xffff00);

		private var left:Quad3D = new Quad3D(1, 1, 0xffff00);

		private var right:Quad3D = new Quad3D(1, 1, 0xffff00);

		private var bottom:Quad3D = new Quad3D(1, 1, 0xffff00);

		private var widthField:ArrangableTextField = new ArrangableTextField();

		private var heightField:ArrangableTextField = new ArrangableTextField();

		/**
		 * constructor
		 *
		 */
		public function LayerRendererEditable(bgRendererClass:Class = null, objectRendererClass:Class = null)
		{
			super(bgRendererClass || BGRendererEditable, objectRendererClass || ObjectRendererEditable);
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
				const w:Number = info.scaledWidth;
				const h:Number = info.scaledHeight;
				top.projectY = info.parent.projectY;
				left.projectY = info.parent.projectY;
				right.projectY = info.parent.projectY;
				bottom.projectY = info.parent.projectY;
				// top
				top.draw(w, 1);
				top.x = 0;
				top.y = h;
				// left
				left.draw(1, h);
				left.pivotY = h;
				left.x = 0;
				left.y = 0;
				// right
				right.draw(1, h);
				right.pivotY = h;
				right.y = 0;
				right.x = w;
				// bottom
				bottom.draw(w, 1);
				bottom.x = 0;
				bottom.y = 0;
				// 其他文本框
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

		/**
		 * @inheritDoc
		 *
		 */
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

		/**
		 * @private
		 *
		 */
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

		/**
		 * @private
		 *
		 */
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

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get gridCellClass():Class
		{
			return GridCellRendererEditable;
		}

		/**
		 * @private
		 *
		 */
		protected function get infoEditable():LayerInfoEditable
		{
			return _info as LayerInfoEditable;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function get regionInfoRendererClass():Class
		{
			return RegionInfoRendererEditable;
		}

		/**
		 * 更新背景图的位置
		 *
		 */
		public function updateBGPositions():void
		{
			if (_info.type == LayerType.OBJECT)
			{
				return;
			}

			for (var i:int = 0, n:int = numChildren; i < n; i++)
			{
				const bg:BGRenderer = getChildAt(i) as BGRenderer;

				if (!bg)
				{
					continue;
				}
				bg.z = bg.z;
			}
		}
	}
}
