package age.data
{
	import flash.errors.IllegalOperationError;
	import age.age_internal;
	import org.osflash.signals.Signal;

	/**
	 * 储存每一帧的基本信息，如宽高，坐标，长度等
	 * @author zhanghaocong
	 *
	 */
	public class FrameInfo
	{
		/**
		 * 当前帧的框信息
		 */
		public var box:Box;

		/**
		 * 父级，也就是 FrameLayerInfo
		 */
		public var parent:FrameLayerInfo;

		/**
		 * 帧类型<br>
		 * 这将返回 parent.type
		 * @return
		 * @see ae.assets.FrameLayerInfo#type
		 */
		public function get type():int
		{
			return parent.type;
		}

		/**
		 * 是否是关键帧
		 * 默认 false
		 */
		public var isKeyframe:Boolean;

		/**
		 * 当前帧声音具体 MP3 路径
		 */
		public var soundPath:String;

		private var _onSoundChange:Signal;

		/**
		 * soundPath 发生变化时广播
		 * @return
		 *
		 */
		public function get onSoundChange():Signal
		{
			return _onSoundChange ||= new Signal;
		}

		private var _sound:String;

		/**
		 * 声音，是 avatarID_actionName#sound 这样的格式
		 */
		public function get sound():String
		{
			return _sound;
		}

		/**
		 * @private
		 */
		public function set sound(value:String):void
		{
			if (value != _sound)
			{
				_sound = value;
				parseSound(_sound);

				if (_onSoundChange)
				{
					_onSoundChange.dispatch();
				}
			}
		}

		/**
		 * 将 sound 分解成 soundPath
		 * @param sound
		 *
		 */
		protected function parseSound(sound:String):void
		{
			if (sound)
			{
				soundPath = sound + ".mp3";
			}
		}

		/**
		 * 子贴图名称
		 */
		public var textureName:String;

		/**
		 * 贴图路径
		 */
		public var texturePath:String

		private var _texture:String;

		/**
		 * 贴图路径，是 folder/texturePath#textureName 格式的字符串，# 后是子贴图的名字<br>
		 * 设置后，将自动分解到 textureName 和 texturePath 中
		 */
		public function get texture():String
		{
			return _texture;
		}

		/**
		 * @private
		 */
		public function set texture(value:String):void
		{
			age_internal::setTexture(value);

			if (_onTextureChange)
			{
				_onTextureChange.dispatch();
			}
		}

		/**
		 * 设置贴图，将不会广播事件
		 * @param value
		 *
		 */
		age_internal function setTexture(value:String):void
		{
			if (_texture)
			{
				textureName = null;
				texturePath = null;
			}
			_texture = value;
			parseTexture(_texture);
		}

		/**
		 * 将 texture 分解成 texturePath 和 textureName
		 * @param texture
		 *
		 */
		protected function parseTexture(texture:String):void
		{
			if (texture)
			{
				var s:Array = texture.split("#");
				texturePath = s[0];
				textureName = s[1];
			}
		}

		private var _onTextureChange:Signal;

		/**
		 * texture 发生变化时广播
		 * @return
		 *
		 */
		public function get onTextureChange():Signal
		{
			return _onTextureChange ||= new Signal();
		}

		/**
		 * 设置或获取粒子配置，当图层类型为 Particle 时该值有效。默认值 null
		 */
		public var particleConfig:Particle3DConfig;

		/**
		 * 当前帧相对于 parent 的位置<br>
		 * 如果没有 parent，返回 -1
		 * @return
		 *
		 */
		public function get index():int
		{
			if (!parent)
			{
				return -1;
			}
			return parent.frames.indexOf(this);
		}

		/**
		 * 当前帧所在层级<br>
		 * 如果没有 parent，返回 -1
		 * @return
		 *
		 */
		public function get layerIndex():int
		{
			if (!parent)
			{
				return -1;
			}
			return parent.index;
		}

		/**
		 * 获得下一帧
		 * @return
		 *
		 */
		public function get next():FrameInfo
		{
			if (parent)
			{
				const i:int = index;

				if (i + 1 < parent.frames.length)
				{
					return parent.frames[i + 1];
				}
			}
			return null;
		}

		/**
		 * 下一个关键帧
		 * @return
		 *
		 */
		public function get nextKeyFrame():FrameInfo
		{
			if (isTail)
			{
				return null;
			}

			if (parent)
			{
				var f:FrameInfo = this;

				do
				{
					f = f.next;
				} while (f && !f.isKeyframe);
				return f;
			}
			return null;
		}

		/**
		 * 上一个关键帧
		 * @return
		 *
		 */
		public function get prevKeyFrame():FrameInfo
		{
			if (isHead)
			{
				return null;
			}

			if (parent)
			{
				var f:FrameInfo = this;

				do
				{
					f = f.prev;
				} while (f && !f.isKeyframe);
				return f;
			}
			return null;
		}

		/**
		 * 获得前一帧
		 * @return
		 *
		 */
		public function get prev():FrameInfo
		{
			if (parent)
			{
				const i:int = index;
			}

			if (i > 0)
			{
				return parent.frames[i - 1];
			}
			return null;
		}

		/**
		 * 检查是否是第一帧
		 * @return
		 *
		 */
		public function get isHead():Boolean
		{
			return index == 0;
		}

		/**
		 * 检查是否是最后一帧
		 * @return
		 *
		 */
		public function get isTail():Boolean
		{
			return index == parent.numFrames - 1;
		}

		/**
		 * 获得当前帧相关的关键帧<br>
		 * 如果本身就是关键帧，返回自己，否则返回 prevKeyframe
		 * @return
		 *
		 */
		public function get keyframe():FrameInfo
		{
			if (isKeyframe)
			{
				return this;
			}
			return prevKeyFrame;
		}

		/**
		 * 当前帧是否是空白关键帧
		 * @return
		 *
		 */
		public function get isEmpty():Boolean
		{
			if (!isKeyframe)
			{
				throw new IllegalOperationError("非关键帧不能访问 isEmpty 属性");
			}

			if (type == FrameLayerType.VIRTUAL)
			{
				return !box;
			}
			else if (type == FrameLayerType.ANIMATION)
			{
				return !(texture && box);
			}
			else if (type == FrameLayerType.SOUND)
			{
				return !(sound);
			}
			else if (type == FrameLayerType.PARTICLE)
			{
				return !(particleConfig && box && texture);
			}
			throw new Error("没有捕捉到 type: " + type);
			return false;
		}

		/**
		 * 创建一个新的 FrameInfo
		 * @param raw
		 *
		 */
		public function FrameInfo(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * 从 JSON 反序列化
		 * @param s
		 *
		 */
		public function fromJSON(s:*):void
		{
			if (s)
			{
				restore(s, this, "sound");
				restore(s, this, "texture");
				restore(s, this, "isKeyframe");
				restore(s, this, "particleConfig");

				if (s.box)
				{
					box = new Box();
					box.fromJSON(s.box);
				}
			}
		}

		/**
		 * JSON.stringify 内部会调用该方法
		 * @param k
		 * @return
		 *
		 */
		public function toJSON(k:*):*
		{
			var result:Object = {};
			export(this, result, "sound", null);
			export(this, result, "box", null);
			export(this, result, "texture", null);
			export(this, result, "particleConfig", null);
			export(this, result, "isKeyframe", false);
			return result;
		}
	}
}
