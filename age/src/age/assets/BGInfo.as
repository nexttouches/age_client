package age.assets
{
	import org.osflash.signals.Signal;

	/**
	 * BGInfo 是图层上的背景图，不参与碰撞检测<br>
	 * 只允许出现在 LayerInfo.type == LayerType.OBJECT 的图层上<br>
	 * 与 ObjectInfo 不同，BG 并不支持 z 排序<br>
	 * 也就是说，BG 依赖于所在层进行前后层次的排序<br>
	 * 如果强制设置在对象图层上，由于 BG 的 z 视为 0，所以会遮挡后面所有对象
	 * @author zhanghaocong
	 *
	 */
	public class BGInfo
	{
		/**
		 * 位于所在图层的唯一 name
		 */
		public var name:String;

		/**
		 * 位于所在场景的唯一 ID
		 */
		public var id:String;

		/**
		 * 贴图的路径（*.png 文件）
		 */
		public var texturePath:String;

		/**
		 * 位于 Atlas 中的名字
		 */
		public var textureName:String;

		private var _texture:String;

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
		 * 以 texturePath#textureName 格式的字符串
		 */
		final public function get texture():String
		{
			return _texture;
		}

		/**
		 * @private
		 */
		public function set texture(value:String):void
		{
			if (_texture)
			{
				textureName = null;
				texturePath = null;
			}

			// 向前兼容：
			// 去掉 .png 后缀
			if (value.lastIndexOf(".png") >= 0)
			{
				// 使用比正则更快 split
				value = value.split(".png").join("");
			}
			_texture = value;

			// 解析贴图
			if (_texture)
			{
				var s:Array = _texture.split("#");
				texturePath = s[0];
				textureName = s[1];
			}

			if (_onTextureChange)
			{
				_onTextureChange.dispatch();
			}
		}

		/**
		 * 像素 X
		 */
		public var x:int;

		/**
		 * 像素 Y
		 */
		public var y:int;

		/**
		 * z
		 */
		public var z:Number = 0;

		/**
		 * 贴图是否 X 轴反转
		 */
		public var isFlipX:Boolean;

		/**
		 * 贴图是否 Y 轴反转
		 */
		public var isFlipY:Boolean;

		/**
		 * 所属图层
		 */
		public var parent:LayerInfo;

		/**
		 * 所属图层索引
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
		 * 创建一个新的 BGInfo
		 *
		 */
		public function BGInfo(raw:Object = null, parent:LayerInfo = null)
		{
			this.parent = parent;

			if (raw)
			{
				for (var key:String in raw)
				{
					if (hasOwnProperty(key)) // 选择性无视错误 :D
					{
						this[key] = raw[key];
					}
				}

				// 向前兼容：
				// 转化到笛卡尔坐标系
				if (!raw.hasOwnProperty("z"))
				{
					z = 0;
					y = parent.parent.height - y;
				}
			}
		}
	}
}
