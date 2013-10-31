package nt.ui.dnd
{
	import nt.ui.core.Component;
	import nt.lib.util.IDisposable;
	import org.osflash.signals.ISignal;

	public class DragProxy implements IDisposable
	{
		private var target:Component;

		public function DragProxy(target:Component)
		{
			this.target = target;
			target.onMouseDown.add(onMouseDown);
		}

		private function onMouseDown(target:Component):void
		{
			DnDManager.starDrag(target);
		}

		public function dispose():Boolean
		{
			target.onMouseDown.remove(onMouseDown);
			target = null;
			return _disposed = true;
		}

		private var _disposed:Boolean;

		public function get isDisposed():Boolean
		{
			return _disposed;
		}

		public function get onDispose():ISignal
		{
			return null;
		}
	}
}
