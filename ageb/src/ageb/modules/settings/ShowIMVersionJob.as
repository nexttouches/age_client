package ageb.modules.settings
{
	import flash.events.NativeProcessExitEvent;
	import mx.controls.Alert;
	import ageb.modules.job.NativeJob;

	/**
	 * 用于显示 ImageMagick 版本
	 * @author zhanghaocong
	 *
	 */
	public class ShowIMVersionJob extends NativeJob
	{
		/**
		 * 创建一个新的 ShowIMVersionJob
		 * @param name
		 *
		 */
		public function ShowIMVersionJob(name:String = "打印 IM 版本")
		{
			super(name);
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onIMExit(event:NativeProcessExitEvent):void
		{
			try
			{
				const s:String = stdout.join();
				const HEAD:String = "Version: ImageMagick";

				if (s.indexOf(HEAD) == 0)
				{
					Alert.show(s, "ImageMagick 版本");
				}
				else
				{
					throw new Error("");
				}
			}
			catch (error:Error)
			{
				Alert.show(tp.executable + " 不是 ImageMagick 命令行应用程序", "错误");
			}
			exit();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			im.version();
		}
	}
}
