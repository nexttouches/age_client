package ageb.modules.ae
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import spark.components.Alert;
	import age.assets.AvatarInfo;
	import age.assets.TextureAtlasConfig;
	import nt.assets.AssetConfig;

	/**
	 * 同步加载配置文件的辅助类
	 * @author kk
	 *
	 */
	public class SyncInfoLoader
	{
		/**
		 * @private
		 *
		 */
		public function SyncInfoLoader()
		{
		}

		/**
		 * 加载贴图集
		 * @param path
		 *
		 */
		public static function loadAtlasConfig(path:String):void
		{
			if (path && !TextureAtlasConfig.getAtlas(path))
			{
				var f:File = new File(AssetConfig.root + "/" + path + ".xml");

				if (f.exists)
				{
					var fs:FileStream = new FileStream();
					fs.open(f, FileMode.READ);

					try
					{
						TextureAtlasConfig.addAtlas(path, XML(fs.readUTFBytes(fs.bytesAvailable)));
						removeError(f.nativePath);
					}
					catch (error:Error)
					{
						addError(f.nativePath, error.message);
					}
					finally
					{
						fs.close();
					}
				}
				else
				{
					addError(f.nativePath, "指定的文件不存在（" + f.nativePath + "）");
				}
			}
		}

		/**
		 * 加载 avatar
		 * @param id
		 *
		 */
		public static function loadAvatar(id:String):void
		{
			if (id && !AvatarInfo.has(id))
			{
				var f:File = new File(AssetConfig.root + "/" + AvatarInfo.folder + "/" + id + ".txt");

				if (f.exists)
				{
					var fs:FileStream = new FileStream();
					fs.open(f, FileMode.READ);

					try
					{
						AvatarInfo.list[id] = JSON.parse(fs.readUTFBytes(fs.bytesAvailable));
						removeError(f.nativePath);
					}
					catch (error:Error)
					{
						addError(f.nativePath, error.message);
					}
					finally
					{
						fs.close();
					}
				}
				else
				{
					addError(f.nativePath, "指定的文件不存在（" + f.nativePath + "）");
				}
			}
		}

		/**
		 * 按路径储存所有没有加载到的文件，避免重复报错
		 */
		private static var errors:Object = {};

		/**
		 * 设置错误
		 * @param id 错误了的 avatar id
		 * @param message 错误消息
		 *
		 */
		public static function addError(path:String, message:String):void
		{
			if (hasError(path))
			{
				errors[path] = true;
				Alert.show(message);
			}
		}

		/**
		 * 删除一个错误
		 * @param path
		 *
		 */
		public static function removeError(path:String):void
		{
			if (hasError(path))
			{
				delete errors[path];
			}
		}

		/**
		 * 检查是否已有错误
		 * @param path
		 * @return
		 *
		 */
		public static function hasError(path:String):Boolean
		{
			return path in errors;
		}
	}
}
