package age.assets
{
	import flash.system.Capabilities;

	/**
	 * AvatarInfo 储存了一套角色的所有动作、大小等基本信息
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
		 * ID
		 */
		public var id:String;

		/**
		 * Avatar 的大小
		 */
		public var size:Box;

		/**
		 * 获得实际用于创建 AvatarInfo 的 Class
		 * @return
		 *
		 */
		protected function get actionInfoClass():Class
		{
			return ActionInfo;
		}

		/**
		 * constructor
		 * @param raw
		 *
		 */
		public function AvatarInfo(raw:Object = null)
		{
			fromJSON(raw);
		}

		/**
		 * 从 JSON 导入
		 * @param raw
		 *
		 */
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

			// 添加动作
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
			if (Capabilities.isDebugger)
			{
				if (!hasAction(name))
				{
					trace("动作 " + id + "/" + name + " 不存在");
				}
			}
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
			// 如尚未初始化，就报错
			if (!_list)
			{
				throw new Error("尚未初始化");
			}

			// id 不在 _list 中，这将返回 null
			if (!(id in _list))
			{
				trace("[AvatarInfo.get]" + id + " 不存在");
				return null;
			}

			// 获取时动态转换成 JSON
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
			if (list)
			{
				throw new Error("不能重复初始化");
			}
			_list = {};
			// AvatarInfo 文件的版本
			// 现在没用到
			// 迟早会用到 :D
			const version:int = o.version;

			for (var key:String in o.list)
			{
				var raw:Object = o.list[key];
				raw.id = key;
				var info:AvatarInfo = new AvatarInfo(raw);
				list[info.id] = info;
			}
			AvatarInfo.folder = folder;
		}

		/**
		 * 位于资源目录下的 avatar 子目录
		 */
		public static var folder:String;

		/**
		 * 按 ID 储存所有的 AvatarInfo
		 */
		protected static var _list:Object;
	}
}
