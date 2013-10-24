package age.renderers
{
	import flash.filters.GlowFilter;
	import age.assets.AvatarInfo;
	import age.assets.Box;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;

	/**
	 * 名字渲染器
	 * @author zhanghaocong
	 *
	 */
	public class NameRenderer extends TextField implements IArrangeable, IDisplayObject3D
	{
		/**
		 * 当 info 为 null 时，渲染的默认大小
		 */
		public static const DEFAULT_SIZE:Box = new Box(0, 0, 0, 100, 200, 100, 0.5, 0, 0.5);

		/**
		 * 创建一个新的 NameRenderer
		 *
		 */
		public function NameRenderer()
		{
			super(200, 18, "", "微软雅黑", 10, 0xff00ff);
			nativeFilters = [ new GlowFilter(0, 1, 2, 2, 10)];
			pivotX = 100;
			hAlign = HAlign.CENTER;
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		public function get zIndex():int
		{
			return _z - 1;
		}

		private var _info:AvatarInfo;

		public function get info():AvatarInfo
		{
			return _info;
		}

		public function set info(value:AvatarInfo):void
		{
			_info = value;
			// 刷坐标
			x = _x;
			y = _y;
			z = _z;
		}

		override public function dispose():void
		{
			_projectY = null;
			_info = null;
			super.dispose();
		}

		private var _x:Number;

		override public function get x():Number
		{
			return _x;
		}

		override public function set x(value:Number):void
		{
			_x = value;
			// 去整以避免像素字体模糊
			super.x = int(value);
		}

		private var _z:Number = 0;

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			// 调用实际的 _projectY 方法
			super.y = _projectY != null ? int(_projectY(_y + 18 + (_info ? _info.size.height : DEFAULT_SIZE.height), _z)) : 0;
		}

		private var _y:Number;

		public override function set y(value:Number):void
		{
			_y = value;
			super.y = _projectY != null ? int(_projectY(_y + 18 + (_info ? _info.size.height : DEFAULT_SIZE.height), _z)) : 0;
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
				super.y = int(_projectY(_y + 18 + (_info ? _info.size.height : DEFAULT_SIZE.height), _z));
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
