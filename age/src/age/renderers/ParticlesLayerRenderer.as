package age.renderers
{
	import flash.geom.Rectangle;
	import age.AGE;
	import age.data.FrameLayerInfo;
	import age.data.Particle3DConfig;
	import starling.events.Event;

	/**
	 * 粒子图层
	 * @author zhanghaocong
	 *
	 */
	public class ParticlesLayerRenderer extends ParticleSystem3D implements IDetailRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function ParticlesLayerRenderer()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}

		private function onAdd():void
		{
			projectY = SceneRenender(parent.parent).projectY;
		}

		private var _info:FrameLayerInfo;

		/**
		 * 设置或获取渲染的 FrameLayerInfo
		 */
		public function get info():FrameLayerInfo
		{
			return _info;
		}

		/**
		 * @private
		 */
		public function set info(value:FrameLayerInfo):void
		{
			if (_info != value)
			{
				_info = value;
			}

			if (_info)
			{
				AGE.renderJuggler.add(this);
			}
			else
			{
				AGE.renderJuggler.remove(this);
			}
		}

		private var _currentFrame:int;

		/**
		 * 设置或获取当前帧
		 * @return
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (_currentFrame != value)
			{
				_currentFrame = value;
			}

			if (_info.frames.length > _currentFrame)
			{
				// TODO 检查是否有性能问题
				if (_info.frames[_currentFrame].particleConfig)
				{
					config = _info.frames[_currentFrame].particleConfig;
				}

				if (_info.textures && _info.textures[_currentFrame])
				{
					texture = _info.textures[_currentFrame];
				}
				else
				{
					texture = null;
				}
			}

			// 为没有任何配置的情况下提供默认值
			if (_currentFrame == 0 && !config)
			{
				config = new Particle3DConfig();
			}
		}

		/**
		 * @inhertDoc
		 *
		 */
		public function updateDetail(visibleRect:Rectangle):void
		{
			// 左边界
			if (emitterX < visibleRect.x)
			{
				visible = false;
				return;
			}

			// 上边界
			if (emitterY < visibleRect.y)
			{
				visible = false;
				return;
			}

			// 右边界
			if (emitterX > visibleRect.right)
			{
				visible = false;
				return;
			}

			// 下边界
			if (emitterY > visibleRect.bottom)
			{
				visible = false;
				return;
			}
			visible = true;
		}
	}
}
