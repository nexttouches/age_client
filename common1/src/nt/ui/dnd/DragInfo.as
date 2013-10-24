package nt.ui.dnd
{
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;

	public class DragInfo implements IDisposable
	{
		public var source:IDraggable;

		public var target:IDroppable;

		public var phase:int;

		public var thumb:DragThumb = new DragThumb();

		public var mouseOffsetX:int;

		public var mouseOffsetY:int;

		public function DragInfo()
		{
		}

		public function renew():void
		{
			_disposed = false;
		}

		public function dispose():Boolean
		{
			if (_disposed)
			{
				throw new Error("不能重复调用 dispose");
			}
			thumb.dispose();
			source = null;
			target = null;
			phase = DragPhase.Idle;
			return _disposed = true;
		}

		private var _disposed:Boolean;

		public function get isDisposed():Boolean
		{
			return _disposed;
		}

		public function get onDispose():ISignal
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function toString():String
		{
			return format("[DragInfo] phase={phase}, source={source}, target={target}, data={data}", this);
		}

		public function get data():*
		{
			return source.dragData;
		}
	}
}
