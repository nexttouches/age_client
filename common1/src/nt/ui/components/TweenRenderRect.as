package nt.ui.components
{
	import com.greensock.TweenLite;
	import nt.ui.core.Component;

	public class TweenRenderRect
	{
		private var host:Component;

		private var threshold:int;

		public function TweenRenderRect(host:Component, threshold:int)
		{
			this.host = host;
			this.threshold = threshold;

			if (host.renderRect)
			{
				_y = host.renderRect.y;
			}
		}

		private var _y:int;

		public function get y():int
		{
			return _y;
		}

		public function set y(value:int):void
		{
			_y = value;
			TweenLite.to(host.renderRect, .3, { y: value, onUpdate: updateScrollRect });
		}

		private function updateScrollRect():void
		{
			host.scrollRect = host.renderRect;
		}
	}
}
