package age.renderers
{
	import starling.display.Quad;
	import starling.events.Event;

	public class Quad3D extends Quad implements IDisplayObject3D, IArrangeable
	{
		public function Quad3D(width:Number, height:Number, color:uint = 0xffffff, premultipliedAlpha:Boolean = true)
		{
			super(width, height, color, premultipliedAlpha);
			uniqueIndex = ZIndexHelper.getUniqueZIndex();
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		/**
		 * 重设 Quad 到指定大小
		 * @param width
		 * @param height
		 *
		 */
		public function draw(width:Number, height:Number):void
		{
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);
			onVertexDataChanged();
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		protected var uniqueIndex:int;

		public function get zIndex():int
		{
			return z * ZIndexHelper.Z_RANGE;
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
			if (is3D)
			{
				_y = value;
				super.y = _projectY != null ? _projectY(_y, _z) : 0;
			}
			else
			{
				super.y = value;
			}
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

		private var _scale:Number = 1;

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
			if (value != _scale)
			{
				_scale = value;
				scaleX = value;
				scaleY = value;
			}
		}

		override public function dispose():void
		{
			_projectY = null;
			super.dispose();
		}
	}
}
