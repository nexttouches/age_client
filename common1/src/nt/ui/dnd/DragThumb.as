package nt.ui.dnd
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class DragThumb extends Sprite implements IDisposable
	{
		private var ctf:ColorTransform = new ColorTransform(1, 1, 1, 0.7);

		private var bitmapData:BitmapData;

		private var bitmap:Bitmap;

		public function DragThumb()
		{
			super();
			mouseEnabled = false;
			mouseChildren = false;
			bitmap = new Bitmap();
			addChild(bitmap);
			_disposed = true;
		}

		public function draw(source:IDraggable):void
		{
			if (!_disposed)
			{
				throw new Error("DragThumb 尚未释放");
			}
			_disposed = false;
			var rect:Rectangle = source.anchor;
			// 画个替代图片
			bitmapData = new BitmapData(rect.width || 1, rect.height || 1, true, 0x0);
			bitmapData.draw(source, null, ctf);
			bitmap.bitmapData = bitmapData;
			// 调整到鼠标位置
			bitmap.x = -source.mouseX;
			bitmap.y = -source.mouseY;
			x = rect.x;
			y = rect.y;
			startDrag(true);
		}

		public function dispose():Boolean
		{
			if (_disposed)
			{
				throw new Error("不能重复调用 dispose");
			}
			stopDrag();
			graphics.clear();
			bitmapData.dispose();
			bitmapData = null;
			return _disposed = true;
		}

		private var _disposed:Boolean;

		public function get isDisposed():Boolean
		{
			return _disposed;
		}

		private var _onDispose:Signal;

		public function get onDispose():ISignal
		{
			return _onDispose ||= new Signal(DragThumb);
		}
	}
}
