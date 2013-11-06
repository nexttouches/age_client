package age.data
{

	/**
	 * TextureAtlasConfig 按 path 储存了所有的 TextureAtlas 信息
	 * @author zhanghaocong
	 *
	 */
	public class TextureAtlasConfig
	{
		/**
		 * 没用的构造函数
		 *
		 */
		public function TextureAtlasConfig()
		{
		}

		private static var _list:Object = {};

		private static var _folder:String;

		public static function get folder():String
		{
			return _folder;
		}

		/**
		 * 获得列表对象<br/>
		 * 在编辑器中把它输出成 JSON，以便客户端加载使用
		 * @return
		 *
		 */
		public static function get list():Object
		{
			return _list;
		}

		/**
		 * 根据路径获得一个 TextureAtlas 的 XML<br/>
		 * 返回的 XML 可以被 Starling 使用
		 * @param path
		 * @return
		 *
		 */
		public static function getAtlas(path:String):XML
		{
			if (_list[path])
			{
				if (!(_list[path] is XML))
				{
					_list[path] = XML(_list[path]);
				}
				return _list[path];
			}
			return null;
		}

		/**
		 * 追加一个 TextureAtlas 的 XML<br/>
		 * 一般在编辑器中使用
		 * @param path
		 * @param data
		 *
		 */
		public static function addAtlas(path:String, atlas:XML):void
		{
			_list[path] = atlas;
		}

		/**
		 * 从 JSON 数据初始化
		 * @param json 编辑器中输出的 TextureAtlasInfo.list 的 JSON 化数据
		 * @param folder 贴图目录，一般是位于资源目录下的子目录，如 textures
		 *
		 */
		public static function init(o:Object, folder:String):void
		{
			_list = o.list;
			_folder = folder;
		}
	}
}
