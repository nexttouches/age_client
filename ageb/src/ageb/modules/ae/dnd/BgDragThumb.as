package ageb.modules.ae.dnd
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import age.AGE;
	import age.renderers.IDisplayObject3D;
	import age.renderers.TextureRenderer;
	import ageb.modules.Modules;
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
		public var origin:Vector3D;

		public function BgDragThumb()
		{
			super();
			is3D = false;
		}

		public function setSource(s:DisplayObject):void
		{
			if (s is Image)
			{
				texture = Image(s).texture;
				color = Image(s).color;
			}
			else
			{
				// TODO
				// 有时间实现下
				/*const rt:RenderTexture = new RenderTexture(s.width, s.height, true);
				rt.draw(s);
				texture = rt;*/
			}
			readjustSize();
			transformationMatrix = s.transformationMatrix;
			origin = new Vector3D(s.x, s.y, IDisplayObject3D(s).z);
			var mousePosition:Point = new Point(Modules.getInstance().root.stage.mouseX - AGE.paddingLeft, Modules.getInstance().root.stage.mouseY - AGE.paddingTop);
			mousePosition = s.globalToLocal(mousePosition, mousePosition);
			pivotX = s.pivotX;
			pivotY = s.pivotY;
			offset(0, 0);
			z = 0;
		}

		override public function dispose():void
		{
			if (texture is RenderTexture)
			{
				texture.dispose();
			}
			super.dispose();
		}

		public function get displayObject():DisplayObject
		{
			return this;
		}

		final public function offset(x:Number, y:Number, snapX:Number = 1, snapY:Number = 1):void
		{
			this.x = roundTo(x + origin.x, snapX);
			this.y = roundTo(-y + origin.y, snapY);
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
