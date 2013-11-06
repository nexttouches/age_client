package age.data
{
	import nt.lib.util.assert;
	import org.osflash.signals.Signal;

	/**
	 * ActionInfo 表示一个 AvatarInfo 的某个动作<br>
	 * 包含了所有渲染时需要的图层和原点等基本信息
	 * @author zhanghaocong
	 *
	 */
	public class ActionInfo
	{
		/**
		 * 名字
		 */
		public var name:String

		/**
		 * 参考帧率
		 */
		public var fps:int;

		/**
		 * ActionInfo 的父级
		 */
		public var parent:AvatarInfo;

		private var _onNumFramesChange:Signal;

		/**
		 * numFrames 变化时广播
		 * @return
		 *
		 */
		public function get onNumFramesChange():Signal
		{
			return _onNumFramesChange ||= new Signal();
		}

		private var _numFrames:int;

		/**
		 * 设置或获取当前动作的总长度
		 *
		 */
		final public function get numFrames():int
		{
			return _numFrames;
		}

		/**
		 * @private
		 */
		public function set numFrames(value:int):void
		{
			if (_numFrames != value)
			{
				_numFrames = value;

				if (_onNumFramesChange)
				{
					_onNumFramesChange.dispatch();
				}
			}
		}

		/**
		 * 每帧的长度（秒）
		 * @return
		 *
		 */
		[Inline]
		final public function get defautFrameDuration():Number
		{
			return 1.0 / fps;
		}

		/**
		 * 动画的总时间
		 * @return
		 *
		 */
		[Inline]
		final public function get totalTime():Number
		{
			return defautFrameDuration * numFrames;
		}

		/**
		 * 当前动作的所有图层信息<br>
		 * 如名字图层，粒子图层，贴图图层，被击图层，攻击图层等
		 */
		public var layers:Vector.<FrameLayerInfo> = new Vector.<FrameLayerInfo>;

		/**
		 * 图层数
		 * @return
		 *
		 */
		public function get numLayers():int
		{
			return layers.length;
		}

		/**
		 * 获得图层所在索引
		 * @param info
		 * @return
		 *
		 */
		[Inline]
		final public function getLayerIndex(info:FrameLayerInfo):int
		{
			assert(info.parent == this, "info.parent 不为当前动作");
			return layers.indexOf(info);
		}

		/**
		 * 创建一个新的 ActionInfo
		 * @param raw
		 *
		 */
		public function ActionInfo(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * 用于创建 FrameLayerInfo 具体的类
		 * @return
		 *
		 */
		protected function get frameLayerInfoClass():Class
		{
			return FrameLayerInfo;
		}

		/**
		 * 如果图层中的帧数变化了，需要调用该方法以更新总帧数
		 *
		 */
		final public function updateNumFrames():void
		{
			var n:int = 0;

			for each (var layer:FrameLayerInfo in layers)
			{
				if (n < layer.numFrames)
				{
					n = layer.numFrames;
				}
			}
			numFrames = n;
		}

		/**
		* 从 JSON 恢复数据
		* @param s
		*
		*/
		public function fromJSON(s:*):void
		{
			if (!s)
			{
				return;
			}
			restore(s, this, "numFrames");
			restore(s, this, "name");
			restore(s, this, "fps");

			// 新版
			if ("layers" in s)
			{
				parseLayers(s);
			}
			// 向前兼容
			else
			{
				parseOldLayers(s);
			}
		}

		/**
		 * 根据参数添加图层
		 * @param raw
		 *
		 */
		[Inline]
		final protected function parseLayers(raw:Object):void
		{
			for (var i:int = 0, n:int = raw.layers.length; i < n; i++)
			{
				layers.push(new frameLayerInfoClass(raw.layers[i], this));
			}
			// 省略了 numFrames 字段
			updateNumFrames();
		}

		[Inline]
		final protected function parseOldLayers(raw:Object):void
		{
			// 旧数据没有 "layers" 字段
			// 这里帮忙生成一份默认的，保证渲染那边不会乱
			//
			// 先准备一些临时变量
			var layer:FrameLayerInfo;
			var frame:FrameInfo;
			var i:int, n:int;

			// 2：（虚拟）攻击判定层
			// PS 不一定有
			if (raw.hitRects)
			{
				layer = new frameLayerInfoClass(null, this);
				layer.type = FrameLayerType.VIRTUAL;
				layer.name = VirtualLayerName.ATTACK_BOX;

				for (i = 0, n = raw.hitRects.length; i < n; i++)
				{
					layer.addFrameFromRaw({ isKeyframe: true, box: [ raw.hitRects[i].x, // lower.x
																	 raw.hitRects[i].y + raw.hitRects[i].height, // lower.y
																	 -raw.hitRects[i].width * 0.5, // lower.z
																	 raw.hitRects[i].width, // upper.x
																	 raw.hitRects[i].height, // upper.y
																	 raw.hitRects[i].width * 0.5, // upper.z
																	 0, 0, 0.5 ]});
				}

				if (layer.validate())
				{
					layers.push(layer);
				}
			}
			// 1：（虚拟）被击判定层
			// 该图层就一帧
			const defaultHitBox:Box = new Box(0, 0, 0, 100, 174, 100, 0.5, 0, 0.5);
			layer = new frameLayerInfoClass(null, this);
			layer.type = FrameLayerType.VIRTUAL;
			layer.name = VirtualLayerName.HIT_BOX;
			// 第一帧是关键帧
			layer.addFrameFromRaw({ isKeyframe: true, box: defaultHitBox.toJSON(null)});

			// 后面都是延长帧
			for (i = 1, n = numFrames; i < n; i++)
			{
				layer.addFrameFromRaw({});
			}
			layer.numFrames = numFrames;

			if (layer.validate())
			{
				layers.push(layer);
			}
			// 0：动画层
			layer = new frameLayerInfoClass(null, this);
			layer.type = FrameLayerType.ANIMATION;
			layer.name = "Animation 1"; // 给个名字好看点
			const alignPoint:Object = raw.alignPoint;

			// 遍历添加帧，这里要设置宽高 pivot 之类的信息
			for (i = 0, n = numFrames; i < n; i++)
			{
				layer.addFrameFromRaw({ texture: FrameLayerInfo.AUTO, isKeyframe: true,
										  box: [ 0,
												 0,
												 0,
												 alignPoint.width,
												 alignPoint.height,
												 0,
												 alignPoint.x / alignPoint.width,
												 1 - (alignPoint.y / alignPoint.height), // 坐标系是颠倒的
												 0 ]});
			}

			if (layer.validate())
			{
				layers.push(layer);
			}
		}

		/**
		 * 导出到 JSON
		 * @param k
		 * @return
		 *
		 */
		public function toJSON(k:*):*
		{
			return { name: name, fps: fps, layers: layers };
		}
	}
}
