package ageb.modules.settings
{
	import flash.events.NativeProcessExitEvent;
	import mx.controls.Alert;
	import ageb.modules.job.NativeJob;

	/**
	 * 用于显示 TP 版本的任务
	 * @author zhanghaocong
	 *
	 */
	public class ShowTPVersionJob extends NativeJob
	{
		/**
		 * 创建一个新的 ShowTPVersionJob
		 * @param name
		 *
		 */
		public function ShowTPVersionJob(name:String = "打印 TP 版本")
		{
			super(name);
		}

		/**
		 * @inheritDoc
		 * @param event
		 *
		 */
		override protected function onTPExit(event:NativeProcessExitEvent):void
		{
			try
			{
				const s:String = stdout.join();
				const HEAD:String = "TexturePacker";

				if (s.indexOf(HEAD) == 0)
				{
					Alert.show(s, "TexturePacker 版本");
				}
				else
				{
					throw new Error("");
				}
			}
			catch (error:Error)
			{
				Alert.show(tp.executable + " 不是 TexturePacker 命令行应用程序", "错误");
			}
			exit();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			tp.version();
		}
	}
}
