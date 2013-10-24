package age.assets
{
	import nt.lib.util.assert;

	/**
	 * AvatarInfo 储存了一套角色的所有动作，大小等基本信息
	 * @author zhanghaocong
	 *
	 */
	public class AvatarInfo
	{
		/**
		 * 按动作名称储存所有动作
		 */
		public var actions:Object = {};

		/**
		 *  ID
		 */
		public var id:String;

		/**
		 * Avatar 的大小
		 */
		public var size:Box;

		/**
		 * 获得用于创建 AvatarInfo 具体的 Class
		 * @return
		 *
		 */
		protected function get actionInfoClass():Class
		{
			return ActionInfo;
		}

		public function AvatarInfo(raw:Object = null)
		{
			fromJSON(raw);
		}

		private function fromJSON(raw:Object):void
		{
			if (!raw)
			{
				return;
			}
			id = raw.id;

			if (raw.size is Array)
			{
				size = new Box();
				size.fromJSON(raw.size);
			}
			else
			{
				// 默认值
				size = new Box(0, 0, 0, 100, 174, 100, 0.5, 0, 0.5);
			}

			for (var actionName:String in raw.actions)
			{
				var info:ActionInfo = new actionInfoClass(raw.actions[actionName]);
				info.parent = this;
				actions[info.name] = info;
			}
		}

		/**
		 * 获得动作数目
		 * @return
		 *
		 */
		public function get numActions():int
		{
			return count(actions);
		}

		/**
		 * 根据名称获得动作
		 * @param name
		 * @return
		 *
		 */
		public function getAction(name:String):ActionInfo
		{
			assert(hasAction(name), "动作 " + id + "/" + name + " 不存在");
			return actions[name];
		}

		/**
		 * 检查是否有指定的动作
		 * @param name
		 * @return
		 *
		 */
		public function hasAction(name:String):Boolean
		{
			return actions && name in actions;
		}

		/**
		 * 获得第一个可用的动作<br>
		 * 如果动作列表是空的，返回 null
		 * @return
		 *
		 */
		public function get firstAction():ActionInfo
		{
			for each (var a:ActionInfo in actions)
			{
				return a;
			}
			return null;
		}

		/**
		 * 所有 Avatar 列表
		 * @return
		 *
		 */
		public static function get list():Object
		{
			return _list;
		}

		/**
		 * 根据 ID 获得 AvatarInfo
		 * @param id
		 * @return
		 *
		 */
		public static function get(id:String):AvatarInfo
		{
			if (!id)
			{
				throw new Error("id 不能是 null");
			}

			if (!_list)
			{
				throw new Error("尚未初始化");
			}

			if (!(id in _list))
			{
				throw new Error(id + " 不存在");
			}

			if (!(_list[id] is AvatarInfo))
			{
				_list[id].id = id;
				_list[id] = new AvatarInfo(_list[id]);
			}
			return _list[id];
		}

		/**
		 * 检查是否有指定 ID 的 Avatar
		 * @param id
		 * @return
		 *
		 */
		public static function has(id:String):Boolean
		{
			return id in _list;
		}

		/**
		 * 初始化 AvatarInfo
		 * @param o 无类型的所有 Avatar 的数据
		 * @param folder 位于资源目录下的 avatar 子目录
		 *
		 */
		public static function init(o:Object, folder:String = ""):void
		{
			if (_list)
			{
				throw new Error("不能重复初始化");
			}
			_list = {};
			const version:int = o.version; // AvatarInfo 文件的版本
			var parse:Function = function():void
			{
				for (var key:String in o.list)
				{
					var raw:Object = o.list[key];
					raw.id = key;
					var info:AvatarInfo = new AvatarInfo(raw);
					_list[info.id] = info;
				}
			}
			parse();
			AvatarInfo.folder = folder;
		}

		/**
		 * 清空所有 AvatarInfos
		 *
		 */
		public static function dispose():void
		{
			_list = null;
			folder = null;
		}

		/**
		 * 位于资源目录下的 avatar 子目录
		 */
		public static var folder:String;
	}
}

var _list:Object;
