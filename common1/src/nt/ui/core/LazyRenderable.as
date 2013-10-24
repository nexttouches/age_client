package nt.ui.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * 提供可以延迟处理渲染任务的基类
	 * @author zhanghaocong
	 *
	 */
	public class LazyRenderable extends Sprite
	{
		protected var _onRender:ISignal;

		public function get onRender():ISignal
		{
			return _onRender ||= new Signal(Component);
		}

		public function LazyRenderable()
		{
			super();
			addEventListener(Event.RENDER, renderHandler);
			addEventListener(Event.ADDED_TO_STAGE, renderHandler);
			invalidateTimer = new Timer(1);
			invalidateTimer.addEventListener(TimerEvent.TIMER, invalidateTimer_timerHandler);
		}

		protected function invalidateTimer_timerHandler(event:TimerEvent):void
		{
			invalidateTimer.reset();
			event.updateAfterEvent();

			if (stage)
			{
				stage.invalidate();
			}
		}

		private var invalidateTimer:Timer;

		private var _invalidate:Boolean = false;

		/**
		 * 调用 stage.invalidate，等待适当的时候进行重绘
		 * @param event
		 *
		 */
		public function invalidate(event:Event = null):void
		{
			_invalidate = true;

			if (stage)
			{
				invalidateTimer.start();
			}
		}

		/**
		 * 要求现在就进行重绘
		 *
		 */
		public function invalidateNow(e:Event = null):void
		{
			_invalidate = false;
			render();
		}

		private function renderHandler(event:Event):void
		{
			if (_invalidate)
			{
				_invalidate = false;
				render();

				if (_onRender)
				{
					_onRender.dispatch(this);
				}
			}
		}

		/**
		 * 重绘方法
		 *
		 */
		protected function render():void
		{
		}
	}
}
