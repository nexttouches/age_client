package ageb.modules.ae.dnd
{
	import flash.geom.Vector3D;
	import age.renderers.IDisplayObject3D;
	import age.renderers.TextureRenderer;
	import ageb.modules.ae.roundTo;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.RenderTexture;

	/**
	 * 用于产生一个拖拽期间的缩略图
	 * @author zhanghaocong
	 *
	 */
	public class BgDragThumb extends TextureRenderer implements IDragThumb
	{
		/**
		 * 旧坐标
		 */
		public var origin:Vector3D;

		/**
		 * constructor
		 *
		 */
		public function BgDragThumb()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function setSource(s:DisplayObject):void
		{
			if (s is Image)
			{
				texture = Image(s).texture;
				color = Image(s).color;
			}
			else
			{
				// TODO 有时间实现下
				/*const rt:RenderTexture = new RenderTexture(s.width, s.height, true);
				rt.draw(s);
				texture = rt;*/
			}
			readjustSize();
			transformationMatrix = s.transformationMatrix;
			origin = IDisplayObject3D(s).position.clone();
			pivotX = s.pivotX;
			pivotY = s.pivotY;
			scale = IDisplayObject3D(s).scale;
			offset(0, 0);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			if (texture is RenderTexture)
			{
				texture.dispose();
			}
			super.dispose();
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function get displayObject():DisplayObject
		{
			return this;
		}

		/**
		 * @inheritDoc
		 *
		 */
		public function offset(x:Number, y:Number, snapX:Number = 1, snapY:Number = 1):void
		{
			setPosition(roundTo(x + origin.x, snapX), roundTo(y + origin.y, snapY), origin.z);
		}

		/**
		 * 保证总是在最上层
		 * @return
		 *
		 */
		override public function get zIndex():int
		{
			return int.MIN_VALUE;
		}
	}
}
