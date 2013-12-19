package ageb.modules.job
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import ageb.utils.FileUtil;
	import nt.lib.util.assert;

	/**
	 * 调用 TexturePacker 打包时使用的参数
	 * @author zhanghaocong
	 *
	 */
	public class TPParams
	{
		/**
		 * constructor
		 *
		 */
		public function TPParams()
		{
		}

		/**
		 * 当前 Job 对应的 *.tps 文件
		 */
		public var tps:File;

		/**
		 * 贴图路径
		 */
		public var textureFileName:String = "";

		/**
		 * XML 路径
		 */
		public var dataFileName:String = "";

		/**
		 * 图片列表
		 */
		public var fileList:String = "";

		/**
		 * 添加一个图片
		 * @param nativePath 图片完整路径
		 *
		 */
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
