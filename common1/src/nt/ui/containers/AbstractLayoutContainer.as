package nt.ui.containers
{
	import flash.display.DisplayObject;
	import nt.ui.core.Component;
	import nt.ui.core.Container;

	public class AbstractLayoutContainer extends Container
	{
		public function AbstractLayoutContainer()
		{
			super();
		}

		protected var _gap:int;

		public function get gap():int
		{
			return _gap;
		}

		public function set gap(value:int):void
		{
			_gap = value;
			layout();
			doAlign();
		}

		protected var _align:String;

		public function get align():String
		{
			return _align;
		}

		public function set align(value:String):void
		{
			_align = value;
			layout();
			doAlign();
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			var result:DisplayObject = $addChild(child);
			Component(child).onResize.add(child_onResize);
			layout();
			doAlign();
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}
			invalidate();
			return result;
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var result:DisplayObject = $addChildAt(child, index);
			Component(child).onResize.add(child_onResize);
			layout();
			doAlign();
			measureContentSize();

			if (_autoSize)
			{
				measureAutoSize();
			}
			invalidate();
			return result;
		}

		protected function layout():void
		{
		}

		protected function doAlign():void
		{
		}
	}
}
