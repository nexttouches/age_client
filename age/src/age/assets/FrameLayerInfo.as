package age.assets
{
	import flash.debugger.enterDebugger;
	import flash.media.Sound;
	import age.age_internal;
	import nt.assets.AssetGroup;
	import nt.assets.AssetLoadQueue;
	import nt.assets.IAsset;
	import nt.assets.IAssetUser;
	import nt.lib.reflect.Type;
	import org.osflash.signals.Signal;
	import starling.textures.Texture;

	/**
	 * 帧图层信息<br>
	 * <ul>
	 * <li>继承自 AssetGroup，所以会广播下载完毕等事件</li>
	 * <li>是特殊的 AssetGroup，资源增删关联都由内部进行，请不要从外部添加</li>
	 * </ul>
	 * @author zhanghaocong
	 *
	 */
	public class FrameLayerInfo extends AssetGroup
	{
		/**
		 * 某字段是自动处理时采用的值
		 */
		public static const AUTO:String = "{AUTO}";

		private var _onVisibleChange:Signal;

		/**
		 * isVisible 变化后广播
		 * @return
		 *
		 */
		public function get onVisibleChange():Signal
		{
			return _onVisibleChange ||= new Signal();
		}

		private var _isVisible:Boolean;

		/**
		 * 设置或获取图层是否可见
		 */
		public function get isVisible():Boolean
		{
			return _isVisible;
		}

		/**
		 * @private
		 */
		public function set isVisible(value:Boolean):void
		{
			if (value != _isVisible)
			{
				_isVisible = value;

				if (_onVisibleChange)
				{
					_onVisibleChange.dispatch();
				}
			}
		}

		/**
		 * 父对象的类型是 ActionInfo
		 */
		public var parent:ActionInfo;

		/**
		 * 帧图层类型
		 * @see FrameLayerInfo
		 */
		public var type:int;

		/**
		 * 图层名字
		 */
		public var name:String

		/**
		 * frameInfo 数组
		 */
		public var frames:Vector.<FrameInfo> = new Vector.<FrameInfo>;

		private var _onTexturesChange:Signal;

		/**
		 * textures 变化时广播
		 * @return
		 *
		 */
		public function get onTexturesChange():Signal
		{
			return _onTexturesChange ||= new Signal();
		}

		private var _textures:Vector.<Texture>;

		/**
		 * 贴图序列（仅当类型为 ANIMATION 可用）<br>
		 * 其他情况都为 null
		 */
		[Inline]
		final public function get textures():Vector.<Texture>
		{
			return _textures;
		}

		/**
		 * @private
		 */
		public function set textures(value:Vector.<Texture>):void
		{
			_textures = value;

			if (_onTexturesChange)
			{
				_onTexturesChange.dispatch();
			}
		}

		private var _onSoundsChange:Signal;

		/**
		 * Sounds 对象发生变化时广播
		 * @return
		 *
		 */
		public function get onSoundsChange():Signal
		{
			return _onSoundsChange ||= new Signal();
		}

		private var _sounds:Vector.<Sound>;

		/**
		 * 指示贴图是否使用缩略图<br>
		 * 默认 true
		 */
		protected var isTextureUseThumb:Boolean = true;

		/**
		 * 声音数组<br>
		 * 该数组可以直接给 Sound 对象使用<br>
		 * 默认 null
		 */
		[Inline]
		final public function get sounds():Vector.<Sound>
		{
			return _sounds;
		}

		/**
		 * @private
		 */
		public function set sounds(value:Vector.<Sound>):void
		{
			_sounds = value;

			if (_onSoundsChange)
			{
				_onSoundsChange.dispatch();
			}
		}

		/**
		 * 当前图层在 parent 处的索引<br>
		 * 如没有任何父级返回 -1
		 * @return
		 *
		 */
		public function get index():int
		{
			if (!parent)
			{
				return -1;
			}
			return parent.getLayerIndex(this);
		}

		/**
		 * 设置或获取当前图层的长度<br>
		 * 根据情况， 这将截断或使用 null 填充到指定长度
		 */
		public function get numFrames():uint
		{
			return frames.length;
		}

		public function set numFrames(value:uint):void
		{
			frames.length = value;
		}

		/**
		 * 获得实际用于创建 FrameInfo 的类
		 * @return
		 *
		 */
		protected function get frameInfoClass():Class
		{
			return FrameInfo;
		}

		/**
		 * 根据参数创建 FrameLayerInfo
		 * @param raw
		 *
		 */
		public function FrameLayerInfo(raw:Object = null, parent:ActionInfo = null)
		{
			this.parent = parent;

			if (raw)
			{
				fromJSON(raw);
			}
		}

		/**
		 * 根据 raw 添加一个 FrameInfo
		 * @param raw
		 *
		 */
		public function addFrameFromRaw(raw:Object):void
		{
			var info:FrameInfo = new frameInfoClass(raw);
			info.parent = this;
			frames.push(info);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function dispose():void
		{
			super.dispose();
			assets = null;
			textures = null;
			sounds = null;
		}

		/**
		 * 初始化（填充） textures 数组
		 *
		 */
		final protected function initTextures():void
		{
			const n:uint = frames.length;
			var newTextures:Vector.<Texture> = new Vector.<Texture>(n, true);
			var keyframe:FrameInfo;

			for (var i:int = 0; i < n; i++)
			{
				keyframe = frames[i].keyframe;

				if (!keyframe.texture)
				{
					continue;
				}
				const asset:TextureAsset = TextureAsset.get(AvatarInfo.folder + "/" + keyframe.texturePath);

				// 检查是否有子贴图，为 null 或空字符串表示没有子贴图
				if (keyframe.textureName && asset.textureAtlas)
				{
					newTextures[i] = asset.textureAtlas.getTexture(keyframe.textureName);
				}
				else
				{
					newTextures[i] = asset.texture;
				}
			}
			textures = newTextures;
		}

		/**
		 * @inheritDoc
		 * @param user
		 *
		 */
		override public function removeUser(user:IAssetUser):void
		{
			super.removeUser(user);

			// 一旦没有用户了，就解掉所有资源的引用
			if (numUsers == 0)
			{
				dispose();
			}
		}

		/**
		 * 初始化粒子相关资源
		 *
		 */
		final protected function initParticles():void
		{
			enterDebugger();
		}

		/**
		 * 初始化（填充） sounds
		 *
		 */
		final protected function initSounds():void
		{
			enterDebugger();
		}

		/**
		 * 加载当前图层所有需要的资源<br>
		 * 根据类型不同，将载入声音或贴图等资源
		 * @param queue
		 *
		 */
		override public function load(queue:AssetLoadQueue = null):void
		{
			// 判断类型并添加 assets
			if (!assets)
			{
				if (type == FrameLayerType.ANIMATION)
				{
					addAnimationAssets();
				}
				else if (type == FrameLayerType.SOUND)
				{
					throw new Error("没做好");
				}
				else if (type == FrameLayerType.PARTICLE)
				{
					throw new Error("没做好");
				}
			}

			if (isComplete)
			{
				onAssetLoadComplete(this);
			}
			super.load(queue);
		}

		/**
		 * 添加图层类型为 ANIMATION 需要的资源
		 *
		 */
		[Inline]
		final protected function addAnimationAssets():void
		{
			// 总之先清空
			empty();
			// 检查所有 FrameInfo.texture 属性是否需要自动填充
			fillFramesTexture();

			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				if (frames[i].isKeyframe)
				{
					// 判断是否有贴图
					if (frames[i].texture)
					{
						var asset:TextureAsset = TextureAsset.get(AvatarInfo.folder + "/" + frames[i].texturePath);
						asset.useThumb = isTextureUseThumb;
						addAsset(asset);
					}
				}
			}
		}

		public override function empty():void
		{
			textures = null;
			super.empty();
		}

		/**
		 * 填充所有动画图层的 texture 属性
		 *
		 */
		final public function fillFramesTexture():void
		{
			for (var i:int = 0, n:int = frames.length; i < n; i++)
			{
				// 向前兼容
				// 遇 "{AUTO}" 将自动设定路径
				if (frames[i].isKeyframe)
				{
					if (frames[i].texture == AUTO)
					{
						frames[i].age_internal::setTexture(parent.parent.id + "_" + parent.name + "#" + i);
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 * @param asset
		 *
		 */
		override public function onAssetLoadComplete(asset:IAsset):void
		{
			// 全部下载完毕后初始化
			if (isComplete)
			{
				if (type == FrameLayerType.ANIMATION)
				{
					initTextures();
				}
				else if (type == FrameLayerType.SOUND)
				{
					initSounds();
				}
				else if (type == FrameLayerType.PARTICLE)
				{
					initParticles();
				}
			}
			super.onAssetLoadComplete(asset);
		}

		/**
		 * 检查当前帧是否有效<br>
		 * 下列情况视为无效，将返回 false
		 * <ul>
		 * <li>长度为 0 的</li>
		 * <li>第一帧不是关键帧的</li>
		 * <li>是关键帧，但是缺少 box 的</li>
		 * </ul>
		 * @return 是否有效
		 *
		 */
		public function validate():Boolean
		{
			// 长度为 0
			if (numFrames == 0)
			{
				return false;
			}

			// 第一帧不是关键帧的
			if (!frames[0].isKeyframe)
			{
				return false;
			}

			// 任意关键帧缺少 box 的
			for (var i:int = frames.length - 1; i >= 0; i--)
			{
				if (frames[i].isKeyframe && frames[i].box == null)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * 从 JSON 恢复数据
		 * @param s
		 *
		 */
		public function fromJSON(s:*):void
		{
			name = s.name;
			isVisible = s.isVisible;
			type = s.type;

			if (s.frames is Array)
			{
				for (var i:int = 0, n:int = s.frames.length; i < n; i++)
				{
					addFrameFromRaw(s.frames[i]);
				}
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
			return { name: name, type: type, frames: frames, isVisible: isVisible };
		}

		/**
		 * @private
		 * @return
		 *
		 */
		public function toString():String
		{
			return format("[{0}] name={1}, index={2}, type={3}", Type.of(this).shortname, name, index, type);
		}
	}
}
