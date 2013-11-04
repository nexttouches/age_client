package ageb.modules.job
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import ageb.utils.FileUtil;
	import nt.lib.util.assert;

	public class TPParams
	{
		public function TPParams()
		{
		}

		/**
		 * 当前 Job 对应的 *.tps 文件储存的位置
		 */
		public var tps:File;

		public var textureFileName:String = "";

		public var dataFileName:String = "";

		public var fileList:String = "";

		public function addFile(nativePath:String):void
		{
			fileList += ("\n<filename>" + nativePath + "</filename>");
		}

		/**
		 * 生成 *.tps 文件到指定文件
		 * @param file
		 * @return 生成了的 tps 文件路径
		 *
		 */
		public function generate():File
		{
			assert(!!tps, "tps 不能为 null", ArgumentError);
			var content:String = FileUtil.readString(File.applicationDirectory.resolvePath("data/action.tps"));
			assert(!!content, "模板内容不能为 null", ArgumentError);
			content = format(content, this);
			var fs:FileStream = new FileStream();
			fs.open(tps, FileMode.WRITE);
			fs.writeUTFBytes(content);
			fs.close();
			return tps;
		}
	}
}
