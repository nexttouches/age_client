package ageb.modules.job
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import ageb.modules.Modules;

	/**
	 * 方便调用 TexturePacker 命令行的工具类
	 * @author zhanghaocong
	 *
	 */
	public class TexturePacker extends NativeProcess
	{
		/**
		 * 退出代码
		 */
		public var exitCode:Number = NaN;

		public function get executable():String
		{
			return Modules.getInstance().settings.getData().tpPath;
		}

		/**
		 * 创建一个新的 TexturePacker
		 * @param executable
		 *
		 */
		public function TexturePacker()
		{
			addEventListener(NativeProcessExitEvent.EXIT, onExit);
		}

		/**
		 * @private
		 *
		 */
		protected function onExit(event:NativeProcessExitEvent):void
		{
			exitCode = event.exitCode;
		}

		/**
		 * 使用指定的 tps 打包
		 * @param tps
		 *
		 */
		public function execute(tps:File):void
		{
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(executable);
			npsi.arguments = new <String>[ tps.nativePath ];
			start(npsi);
		}

		/**
		 * 版本信息
		 *
		 */
		public function version():void
		{
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(executable);
			npsi.arguments = new <String>[ "--version" ];
			start(npsi);
		}
	}
}
