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
		 * @return
		 *
		 */
		public function generate():void
		{
			var content:String = FileUtil.readString(File.applicationDirectory.resolvePath("data/action.tps"));
			assert(!!content);
			content = format(content, this);
			var fs:FileStream = new FileStream();
			fs.open(tps, FileMode.WRITE);
			fs.writeUTFBytes(content);
			fs.close();
		}
	}
}
