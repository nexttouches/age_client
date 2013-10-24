package ageb.modules.job
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import ageb.modules.Modules;

	/**
	 * 方便调用 ImageMagick 的实例
	 * @author zhanghaocong
	 *
	 */
	public class ImageMagick extends NativeProcess
	{
		public function get executable():String
		{
			return Modules.getInstance().settings.getData().imPath;
		}

		/**
		 * 创建一个新的 ImageMagick
		 * @param executable
		 *
		 */
		public function ImageMagick()
		{
		}

		/**
		 * 使用指定的参数执行
		 * @param args
		 *
		 */
		public function execute(args:Vector.<String>):void
		{
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(executable);
			npsi.arguments = args;
			start(npsi);
		}

		/**
		 * 版本信息
		 *
		 */
		public function version():void
		{
			execute(new <String>[ "--version" ]);
		}
	}
}
