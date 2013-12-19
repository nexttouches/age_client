package age.data
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Vector3D;
	import age.AGE;
	import nt.assets.Asset;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;

	/**
	 * LayerInfo 是场景图层信息<br>
	 * 一个场景可以包含任意数目的图层<br>
	 * 图层具有下列特性
	 * <ul>
	 * 	<li>分背景和对象图层两种</li>
	 * 	<li>实现了 IAnimatable，当 type 为 LayerType.OBJECT 时，将参与物理计算</li>
	 * </ul>
	 * @see LayerType
	 * @author zhanghaocong
	 *
	 */
	public class LayerInfo implements IAnimatable
	{
		/**
		 * 所有攻击者
		 */
		public var attackObjects:Vector.<ObjectInfo> = new Vector.<ObjectInfo>;

		/**
		 * 所有被击者
		 */
		public var hitObjects:Vector.<ObjectInfo> = new Vector.<ObjectInfo>;

		/**
		 * 创建一个新的 LayerInfo
		 * @param raw
		 * @param parent
		 *
		 */
		public function LayerInfo(raw:Object = null, parent:SceneInfo = null)
		{
			this.parent = parent;

			if (raw)
			{
				scrollRatio = raw.scrollRatio ? raw.scrollRatio : 1;
				type = raw.type;
				isVisible = (isVisible in raw) ? raw.isVisible : true;
				var i:int, n:int;

				// 根据图层类型分别处理
				// 背景
				if (type == LayerType.BG)
				{
					if (raw.bgs)
					{
						for (i = 0, n = raw.bgs.length; i < n; i++)
						{
							bgs.push(new bgInfoClass(raw.bgs[i], this));
						}
					}
				}
				// 对象
				else if (type == LayerType.OBJECT)
				{
					if (raw.objects)
					{
						for (i = 0, n = raw.objects.length; i < n; i++)
						{
							objects.push(new objectInfoClass(raw.objects[i], this));
						}
					}
				}
			}
		}

		private var _onTypeChange:Signal;

		/**
		 * type 发生变化时广播
		 */
		[Transient]
		public function get onTypeChange():Signal
		{
			return _onTypeChange ||= new Signal();
		}

		private var _type:int = LayerType.BG;

		/**
		 * 图层类型
		 * @see LayerType
		 * @see LayerType.BG
		 * @see LayerType.OBJECT
		 */
		final public function get type():int
		{
			return _type;
		}

		/**
		 * @private
		 */
		public function set type(value:int):void
		{
			if (_type != value)
			{
				_type = value;

				if (_type == LayerType.BG)
				{
					isFlatten = true;
					isAutoSort = false;
				}
				else if (_type == LayerType.OBJECT)
				{
					isFlatten = false;
					isAutoSort = true;
				}

				if (_onTypeChange)
				{
					_onTypeChange.dispatch();
				}
			}
		}

		/**
		 * 卷动时的比例，数值越小速度越慢
		 */
		public var scrollRatio:Number;

		/**
		 * 指示是否使用平板化处理<br>
		 * 当 type 为 LayerType.BG 时为 true<br>
		 * 其他情况为 false
		 */
		public var isFlatten:Boolean;

		/**
		 * 指示是否启用每帧自动排序功能<br>
		 * 当 type 为 LayerType.OBJECT 时为 true<br>
		 * 其他情况为 false
		 */
		public var isAutoSort:Boolean;

		/**
		 * 是否是角色层
		 */
		[Transient]
		public var isCharLayer:Boolean;

		/**
		 * 当前图层的所有背景贴图
		 */
		public var bgs:Vector.<BGInfo> = new Vector.<BGInfo>;

		/**
		 * 当前图层所有对象
		 */
		public var objects:Vector.<ObjectInfo> = new Vector.<ObjectInfo>;

		/**
		 * 添加一个攻击对象
		 * @param info
		 *
		 */
		public function addAttackObject(info:ObjectInfo):void
		{
			attackObjects.push(info);
		}

		/**
		 * 删除一个攻击对象
		 * @param info
		 *
		 */
		public function removeAttackObject(info:ObjectInfo):void
		{
			attackObjects.splice(attackObjects.indexOf(info), 1);
		}

		/**
		 * 添加一个被击对象
		 * @param info
		 *
		 */
		public function addHitObject(info:ObjectInfo):void
		{
			hitObjects.push(info);
		}

		/**
		 * 删除一个被击对象
		 * @param info
		 *
		 */
		public function removeHitObject(info:ObjectInfo):void
		{
			hitObjects.splice(hitObjects.indexOf(info), 1);
		}

		private var _onIsVisibleChange:Signal;

		/**
		 * isVisible 发生变化时广播
		 * @return
		 *
		 */
		[Transient]
		public function get onIsVisibleChange():Signal
		{
			return _onIsVisibleChange ||= new Signal();
		}

		private var _isVisible:Boolean = true;

		/**
		 * 设置或获取是否可见<br>
		 * 默认为 true
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
			_isVisible = value;

			if (_onIsVisibleChange)
			{
				_onIsVisibleChange.dispatch();
			}
		}

		/**
		 * 获得实际用于创建的 BGInfo 的类
		 * @return
		 *
		 */
		protected function get bgInfoClass():Class
		{
			return BGInfo;
		}

		/**
		 * 获得实际用于创建 ObjectInfo 的类
		 * @return
		 *
		 */
		protected function get objectInfoClass():Class
		{
			return ObjectInfo;
		}

		protected var _onAddObject:Signal;

		/**
		 * 添加对象时调用，正确的签名是 <tt>function (info:ObjectInfo):void;</tt>
		 * @return
		 *
		 */
		[Transient]
		public function get onAddObject():Signal
		{
			return _onAddObject ||= new Signal(ObjectInfo);
		}

		/**
		 * 添加对象
		 * @param info
		 *
		 */
		public function addObject(info:ObjectInfo):void
		{
			info.parent = this;
			objects.push(info);
			addAttackObject(info);
			addHitObject(info);

			if (_onAddObject)
			{
				_onAddObject.dispatch(info);
			}
		}

		protected var _onRemoveObject:Signal;

		/**
		 * 删除对象时调用，正确的签名是 <tt>function (info:ObjectInfo):void;</tt>
		 * @return
		 *
		 */
		[Transient]
		public function get onRemoveObject():Signal
		{
			return _onRemoveObject ||= new Signal(ObjectInfo);
		}

		/**
		 * 删除对象
		 * @param info
		 *
		 */
		public function removeObject(info:ObjectInfo):void
		{
			info.parent = null;
			objects.splice(objects.indexOf(info), 1);

			if (_onRemoveObject)
			{
				_onRemoveObject.dispatch(info);
			}
		}

		/**
		 * 根据指定的 actions 获得 objects 中使用的 assets
		 * @param actions
		 * @return
		 *
		 */
		public function getObjectFullAssets(actions:Vector.<String>):Vector.<Asset>
		{
			throw new Error("尚未实现");
		}

		/**
		 * 根据指定的 actions 获得 objects 中使用的 assets 的缩略图
		 * @param actions
		 * @return
		 *
		 */
		public function getObjectThumbAssets(actions:Vector.<String>):Vector.<Asset>
		{
			throw new Error("尚未实现");
		}

		/**
		 * 获得所有背景贴图的 assets
		 * @return
		 *
		 */
		public function getBGAssets():Vector.<Asset>
		{
			var uniqueListHelper:Object = {};

			for each (var o:BGInfo in bgs)
			{
				uniqueListHelper[SceneInfo.folder + "/" + o.texturePath] = true;
			}
			var result:Vector.<Asset> = new Vector.<Asset>();

			for (var path:String in uniqueListHelper)
			{
				result.push(TextureAsset.get(path));
			}
			return result;
		}

		/**
		 * 关联的 SceneInfo
		 */
		[Transient]
		public var parent:SceneInfo;

		/**
		 * 缩放后的宽度
		 * @return
		 *
		 */
		[Transient]
		public function get scaledWidth():Number
		{
			if (!parent)
			{
				throw new IllegalOperationError("没有 parent，无法计算 scaledWidth");
			}
			return parent.width * scrollRatio;
		}

		/**
		 * 缩放后的高度
		 * @return
		 *
		 */
		[Transient]
		public function get scaledHeight():Number
		{
			if (!parent)
			{
				throw new IllegalOperationError("没有 parent，无法计算 scaledHeight");
			}
			return parent.height * scrollRatio;
		}

		/**
		 * 缩放后的深度
		 * @return
		 *
		 */
		[Transient]
		public function get scaledDepth():Number
		{
			if (!parent)
			{
				throw new IllegalOperationError("没有 parent，无法计算 scaledDepth");
			}
			return parent.depth * scrollRatio;
		}

		/**
		 * 获取图层相对于所在 SceneRenderer 的位置
		 * @return
		 *
		 */
		[Transient]
		public function get index():int
		{
			if (!parent)
			{
				throw new IllegalOperationError("没有 parent，无法计算 index");
			}
			return parent.layers.indexOf(this);
		}

		/**
		 * 启动物理模拟
		 *
		 */
		public function start():void
		{
			AGE.physicsJuggler.add(this);
		}

		/**
		 * 停止物理模拟
		 *
		 */
		public function stop():void
		{
			AGE.physicsJuggler.remove(this);
		}

		/**
		 * 重力
		 */
		public const g:Vector3D = new Vector3D(0, -980, 0);

		/**
		 * 摩擦力
		 */
		public const friction:Number = 0.5;

		/**
		 * 当速度小于该值时视为静止
		 */
		public const STICKY:Number = 1;

		/**
		 * 一个值为 0 的 Vector3D
		 */
		private static const ZERO_VELOCITY:Vector3D = new Vector3D;

		/**
		 * @inheritDoc
		 * @param time
		 *
		 */
		public function advanceTime(time:Number):void
		{
			var i:int, n:int, o:ObjectInfo;
			const lower:Vector3D = parent.size.lower;
			const upper:Vector3D = parent.size.upper;

			for (i = 0, n = objects.length; i < n; i++)
			{
				o = objects[i];

				// 重力
				if (o.position.y <= lower.y)
				{
					o.acceleration.y = 0;
				}
				else
				{
					o.acceleration.y = g.y * o.mass;
				}
				const lastY:Number = o.position.y;
				o.advanceTime(time);

				// 进入下边界（贴地）
				if (o.position.y <= lower.y)
				{
					// 设置 position 到地面
					o.position.y = lower.y;
					// 应用摩擦力
					o.velocity.x *= friction;
					o.velocity.z *= friction;

					if (Math.abs(o.velocity.x) <= STICKY)
					{
						o.velocity.x = 0;
					}

					if (Math.abs(o.velocity.z) <= STICKY)
					{
						o.velocity.z = 0;
					}

					// 刚刚碰到地面，应用弹力
					if (lastY > lower.y)
					{
						if (o.isElasticityEnabled)
						{
							o.velocity.y *= -o.elasticity;

							if (Math.abs(o.velocity.y) <= Math.abs(g.y * time))
							{
								o.velocity.y = 0;
							}
						}
						else
						{
							o.velocity.y = 0;
						}
					}
				}

				// 进入左边界
				if (o.position.x < lower.x)
				{
					o.position.x = lower.x;
					o.velocity.x = 0;
				}
				// 进入右边界
				else if (o.position.x > upper.x)
				{
					o.position.x = upper.x;
					o.velocity.x = 0;
				}
				// 是否已静止
				o.isSticky = o.velocity.equals(ZERO_VELOCITY);
			}

			// 检查碰撞过程
			// 先遍历 attackObjects，然后逐个与 hitObjects 检查碰撞
			for (i = 0, n = attackObjects.length; i < n; i++)
			{
				// 准备一些变量
				var j:int, m:int, ao:ObjectInfo, ho:ObjectInfo;
				ao = attackObjects[i];

				for (j = 0, m = hitObjects.length; j < m; j++)
				{
					ho = hitObjects[j];

					// 特别情况：跳过自己
					if (ho == ao)
					{
						continue;
					}
					const collide:Box = ao.attackBox.intersection(ho.hitBox);

					// 这里碰撞了
					if (collide)
					{
						trace(collide.x, collide.y, collide.z);
					}
				}
			}
		}
	}
}
