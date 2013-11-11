package age.renderers
{
	import flash.errors.IllegalOperationError;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import age.data.RegionInfo;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.VAlign;

	/**
	 * 用于渲染 RegionInfo
	 * @author zhanghaocong
	 *
	 */
	public class RegionInfoRenderer extends Sprite implements IArrangeable, IDetailRenderer, IDisplayObject3D
	{
		protected static const TEXT_WIDTH:int = 128;

		protected static const TEXT_COLOR:uint = 0xff0000;

		protected static const SPLITTER_COLOR:uint = 0xff0000;

		protected static const LINE_WEIGHT:uint = 8;

		protected static const LINE_GAP:uint = 1;

		/**
		 * 用于显示一些信息的文本
		 */
		protected var tf:TextField;

		/**
		 * 一根竖线
		 */
		protected var splitterV:Quad;

		/**
		 * 一根横线
		 */
		protected var splitterH:Quad;

		public function RegionInfoRenderer()
		{
			super();
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		protected var _info:RegionInfo;

		/**
		 * 设置或获取当前渲染的 RegionInfo
		 * @return
		 *
		 */
		public function get info():RegionInfo
		{
			return _info;
		}

		public function set info(value:RegionInfo):void
		{
			if (_info)
			{
				tf.removeFromParent(true);
				tf = null;
				splitterV.removeFromParent(true);
				splitterV = null;
				splitterH.removeFromParent(true);
				splitterH = null;
			}
			_info = value;

			if (_info)
			{
				// 简单除 2 就可以实现投影
				splitterV = new Quad(LINE_WEIGHT / 2, _info.height, _color);
				splitterV.alpha = 0.33;
				addChild(splitterV);
				splitterH = new Quad(_info.width, LINE_WEIGHT, _color);
				splitterH.alpha = 0.33;
				splitterH.y = (_info.id - 1) * (splitterH.height + LINE_GAP);
				addChild(splitterH);
				tf = new TextField(TEXT_WIDTH, 22, _info.toString(), "Verdana", 12, TEXT_COLOR, true);
				tf.vAlign = VAlign.CENTER;
				tf.x = -tf.width / 2;
				tf.y = _info.height / 2;
				tf.nativeFilters = [ new GlowFilter(0, 1, 2, 2, 10)];
				addChild(tf);
				x = _info.x;
				y = 0;
				flatten();
			}
		}

		private var _color:uint = SPLITTER_COLOR;

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			splitterV.color = _color;
			splitterH.color = _color;
			tf.color = _color;
		}

		override public function dispose():void
		{
			info = null;
			super.dispose();
		}

		public function get zIndex():int
		{
			return 0;
		}

		/**
		 * @inhertDoc
		 *
		 */
		public function updateDetail(visibleRect:Rectangle):void
		{
			// 左边界
			if (x + width < visibleRect.x)
			{
				visible = false;
				return;
			}

			// 上边界
			if (y + height < visibleRect.y)
			{
				visible = false;
				return;
			}

			// 右边界
			if (x - width > visibleRect.right)
			{
				visible = false;
				return;
			}

			// 下边界
			if (y - height > visibleRect.bottom)
			{
				visible = false;
				return;
			}
			visible = true;
		}

		private var _position:Vector3D = new Vector3D;

		/**
		 * @inheritDoc
		 *
		 */
		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(value:Vector3D):void
		{
			_position = value;
			validatePosition();
		}

		/**
		 * 相当于调用 position.setTo(x, y, z); validatePosition();
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			position.setTo(x, y, z);
			validatePosition();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setX(value:Number):void
		{
			position.x = value;
			validatePositionX();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setY(value:Number):void
		{
			position.y = value;
			validatePositionYZ();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setZ(value:Number):void
		{
			position.z = value;
			validatePositionYZ();
		}

		/**
		 * 当 position 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePosition():void
		{
			if (_projectY == null)
			{
				return;
			}
			super.x = position.x;
			super.y = _projectY(position.y, position.z);
		}

		/**
		 * 当 position.x 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionX():void
		{
			super.x = position.x;
		}

		/**
		 * 当 position.y 或 position.z 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionYZ():void
		{
			if (_projectY == null)
			{
				return;
			}
			super.y = _projectY(position.y, position.z);
		}

		private var _projectY:Function;

		/**
		 * @inheritDoc
		 *
		 */
		public function get projectY():Function
		{
			return _projectY;
		}

		public function set projectY(value:Function):void
		{
			_projectY = value;

			if (value != null)
			{
				validatePosition();
			}
		}

		/**
		 * @private
		 */
		[Deprecated("不允许从外部设置该属性。如要设置坐标，请使用 position 属性或 setPosition", "position")]
		public override function set y(value:Number):void
		{
			throw new IllegalOperationError("不允许从外部设置该属性，要设置坐标，请使用 position 属性");
		}

		/**
		 * @private
		 */
		[Deprecated("不允许从外部设置该属性。如要设置坐标，请使用 position 属性或 setPosition", "position")]
		public override function set x(value:Number):void
		{
			throw new IllegalOperationError("不允许从外部设置该属性，要设置坐标，请使用 position 属性");
		}

		private var _scale:Number;

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = value;
			scaleY = value;
		}
	}
}
