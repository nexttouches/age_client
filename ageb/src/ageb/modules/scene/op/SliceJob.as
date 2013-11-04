package ageb.modules.scene.op
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import age.assets.BGInfo;
	import ageb.modules.job.NativeJob;
	import nt.assets.util.URLUtil;

	/**
	 * 切片任务
	 * @author zhanghaocong
	 *
	 */
	public class SliceJob extends NativeJob
	{
		/**
		 * @private
		 *
		 */
		public var f:File;

		/**
		 * constructor
		 * @param f 目标图片
		 *
		 */
		public function SliceJob(f:File)
		{
			super(name);
			this.f = f;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			// FIXME 事先删除旧切片
			im.execute(new <String> //
					   [ "-verbose", f.nativePath, // 设置 verbose 和输入文件
						 "-crop", format("{0}x{0}", BGInfo.MAX_SIDE_LENGTH), // 设置切片大小
						 "-set", "filename:tile", format("%[fx:page.x/{0}]_%[fx:page.y/{0}]", BGInfo.MAX_SIDE_LENGTH), // 设置输出文件名模式：前缀_x_y 形式
						 "+repage", "+adjoin", // 要求切完全部图片
						 format("{0}\\{1}_%[filename:tile].{2}", f.parent.nativePath, URLUtil.getFilename(f.name), f.extension)]); // 设置输出文件名
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onIMExit(event:NativeProcessExitEvent):void
		{
			onExit.dispatch(this);
		}
	}
}
