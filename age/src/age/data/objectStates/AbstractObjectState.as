package age.data.objectStates
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import age.data.Box;
	import age.data.ObjectInfo;
	import age.renderers.Direction;
	import nt.lib.reflect.Type;

	/**
	 * 对象状态基类，提供了操作对象的一些公用方法
	 * @author zhanghaocong
	 *
	 */
	public class AbstractObjectState
	{
		/**
		 * 当前状态是否可以强制切换到新状态，默认 false
		 */
		public var isForce:Boolean = false;

		/**
		 * 状态名字。该字段将自动通过反射获取并且全小写
		 */
		public var name:String;

		/**
		 * 方向参数。默认值为 0，也就是没有任何方向
		 */
		public var direction:int = 0;

		/**
		 * 当前状态的操作对象
		 */
		protected var info:ObjectInfo;

		/**
		 * 设置或获取攻击间隔（单位秒）。默认为 Infinity，也就是只能攻击一次
		 */
		public var attackInterval:Number = Infinity;

		/**
		 * 记录本次攻击到的对象（键是 ObjectInfo，值是攻击的时间）
		 */
		public var attackedObjects:Dictionary = new Dictionary();

		/**
		 * constructor
		 *
		 */
		public function AbstractObjectState(info:ObjectInfo)
		{
			this.info = info;
			name = getName(this["constructor"]);
		}

		/**
		 * 状态名缓存
		 */
		private static var nameCache:Dictionary = new Dictionary;

		/**
		 * 获得状态名字
		 * @param stateClass
		 * @return
		 *
		 */
		private static function getName(stateClass:Class):String
		{
			return nameCache[stateClass] ||= Type.of(stateClass).shortname.replace(/State/g, "").toLowerCase();
		}

		/**
		 * 应用当前状态
		 */
		public function apply():void
		{
			throw new IllegalOperationError("错误：需子类实现");
		}

		/**
		 * 取消该状态时调用
		 * @param info
		 *
		 */
		public function cancel():void
		{
			emptyAttackedObjects();
		}

		/**
		 * 从当前状态切换到<strong>新状态</strong>时调用<br>
		 * 请注意：抽象类 AbstractObjectState 的该方法之默认实现总是返回 true
		 * @param newState 新状态
		 * @return 如果可以切换就返回 true，否则返回 false
		 *
		 */
		public function canSwitch(newState:AbstractObjectState):Boolean
		{
			return true;
		}

		/**
		 * @private
		 */
		protected var moveSpeed:Number = 150;

		/**
		 * 左移
		 *
		 */
		final protected function moveLeft(isChangeDirection:Boolean):void
		{
			// 先转向后移动
			if (info.direction & Direction.LEFT || !isChangeDirection)
			{
				info.velocity.x = -moveSpeed;
			}
			else
			{
				info.direction = Direction.LEFT;
			}
		}

		/**
		 * 右移
		 *
		 */
		final protected function moveRight(isChangeDirection:Boolean):void
		{
			// 先转向后移动
			if (info.direction & Direction.RIGHT || !isChangeDirection)
			{
				info.velocity.x = moveSpeed;
			}
			else
			{
				info.direction = Direction.RIGHT;
			}
		}

		/**
		 * 下移动
		 *
		 */
		final protected function moveFront():void
		{
			info.velocity.z = -moveSpeed;
		}

		/**
		 * 上移
		 *
		 */
		final protected function moveBack():void
		{
			info.velocity.z = moveSpeed;
		}

		/**
		 * 检查 direction 并移动
		 * @param isChangeDirection 反向移动时是否要换方向
		 */
		final public function move(isChangeDirection:Boolean = true):void
		{
			if (direction & Direction.LEFT)
			{
				moveLeft(isChangeDirection);
			}
			else if (direction & Direction.RIGHT)
			{
				moveRight(isChangeDirection);
			}

			if (direction & Direction.FRONT)
			{
				moveFront();
			}
			else if (direction & Direction.BACK)
			{
				moveBack();
			}
		}

		/**
		 * 水平方向停止移动
		 *
		 */
		[Inline]
		final public function stop():void
		{
			info.velocity.x = 0;
			info.velocity.z = 0;
		}

		/**
		 * 当攻击某对象时，将自动调用该方法
		 * @param object 碰撞的对象
		 * @param intersection 相交的 Box
		 * @return 本次攻击是否有效
		 */
		public function onAttack(target:ObjectInfo, intersection:Box):Boolean
		{
			if (canAttack(target))
			{
				doAttack(target);
				return true;
			}
			return false;
		}

		/**
		 * 被某对象攻击时，将自动调用该方法
		 * @param by
		 * @param intersection
		 *
		 */
		public function onHit(by:ObjectInfo, intersection:Box):void
		{
		}

		/**
		 * 通过检查 attackInterval 确定是否可以攻击
		 * @param target
		 * @return
		 *
		 */
		public function canAttack(target:ObjectInfo):Boolean
		{
			if (target in attackedObjects)
			{
				return attackedObjects[target] + attackInterval <= getTimer();
			}
			return true;
		}

		/**
		 * 攻击指定对象
		 * @param target
		 * @return
		 *
		 */
		public function doAttack(target:ObjectInfo):void
		{
			attackedObjects[target] = getTimer();
		}

		/**
		 * 清空 attackedObjects 列表
		 *
		 */
		final public function emptyAttackedObjects():void
		{
			attackedObjects = new Dictionary();
		}
	}
}
