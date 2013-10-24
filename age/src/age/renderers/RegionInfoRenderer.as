package age.renderers
{
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import age.assets.RegionInfo;
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

		protected var is3D:Boolean = true;

		private var _z:Number = 0;

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			// 调用实际的 _projectY 方法
			super.y = _projectY != null ? _projectY(_y, _z) : 0;
		}

		private var _y:Number;

		public override function set y(value:Number):void
		{
			_y = value;
			super.y = _projectY != null ? _projectY(_y, _z) : 0;
		}

		private var _projectY:Function;

		public function get projectY():Function
		{
			return _projectY;
		}

		public function set projectY(value:Function):void
		{
			_projectY = value;

			if (value != null)
			{
				super.y = _projectY(_y, _z);
			}
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
