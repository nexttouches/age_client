package nt.assets
{
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	/**
	 * AbstractAsset 提供了诸如用户管理之类的基本功能
	 * @author zhanghaocong
	 *
	 */
	public class AbstractAsset implements IAsset
	{
		public function AbstractAsset()
		{
		}

		public function load(queue:AssetLoadQueue = null):void
		{
		}

		public function dispose():void
		{
			for (var key:Object in _users)
			{
				removeUser(key as IAssetUser);
			}
		}

		protected var _bytesLoaded:uint;

		public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}

		protected var _bytesTotal:uint;

		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}

		protected var _state:int;

		public function get state():int
		{
			return _state;
		}

		public function get isComplete():Boolean
		{
			return _state == AssetState.LOADED;
		}

		public function get isLoading():Boolean
		{
			return _state == AssetState.LOADING;
		}

		public function addUser(user:IAssetUser):void
		{
			if (!_users)
			{
				_users = new Dictionary;
			}

			if (_users[user])
			{
				throw new Error("添加失败，不能重复添加 IAssetUser");
				return;
			}
			_users[user] = user;
			_numUsers++;
		}

		public function removeUser(user:IAssetUser):void
		{
			if (!_users[user])
			{
				throw new Error("删除失败，找不到指定的 IAssetUser");
				return;
			}
			delete _users[user];
			_numUsers--;
		}

		public function hasUser(user:IAssetUser):Boolean
		{
			return user in _users;
		}

		protected var _numUsers:uint;

		final public function get numUsers():uint
		{
			return _numUsers;
		}

		protected var _users:Dictionary;

		public function get users():Dictionary
		{
			return _users ||= new Dictionary;
		}

		public function get isDisposable():Boolean
		{
			return false;
		}

		/**
		 * 当前资源是否已被释放
		 * @return
		 *
		 */
		public function get isDisposed():Boolean
		{
			return _state == AssetState.DISPOSED;
		}

		public function printDebugInfo(header:String = null, path:String = ""):void
		{
			trace((header ? header : "") + "当前资源 (" + path + ") 有 " + numUsers + " 个用户正在使用");
			var i:int = 0;

			for (var user:* in users)
			{
				i++;
				trace(i + ".", user);
			}
			trace("状态是 [", AssetState.NAMES[_state] + "(" + _state + ") ]");
		}

		/**
		 * 检查是否是 Flash Player Debugger
		 */
		public static const isDebugger:Boolean = Capabilities.isDebugger;

		public function get isSuccess():Boolean
		{
			throw new Error("尚未实现");
		}

		public function get isNotLoaded():Boolean
		{
			return state == AssetState.NOT_LOADED;
		}
	}
}
