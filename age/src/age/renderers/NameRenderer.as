package age.renderers
{
	import flash.errors.IllegalOperationError;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	import age.data.AvatarInfo;
	import age.data.Box;
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
			return position.z - 1;
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
			validatePosition();
		}

		override public function dispose():void
		{
			_projectY = null;
			_info = null;
			super.dispose();
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
			super.x = int(position.x);
			super.y = int(_projectY(position.y + 18 + (_info ? _info.size.height : DEFAULT_SIZE.height), position.z));
		}

		/**
		 * 当 position.x 发生变化时调用该方法以投影新坐标
		 *
		 */
		[Inline]
		final protected function validatePositionX():void
		{
			super.x = int(position.x);
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
			super.y = int(_projectY(position.y + 18 + (_info ? _info.size.height : DEFAULT_SIZE.height), position.z));
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
