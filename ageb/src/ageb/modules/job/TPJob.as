package ageb.modules.job
{
	import flash.events.NativeProcessExitEvent;
	import nt.assets.util.URLUtil;

	/**
	 * 调用 TexturePacker 打包的 Job
	 * @author zhanghaocong
	 *
	 */
	public class TPJob extends NativeJob
	{
		/**
		 * constructor
		 * @param params
		 *
		 */
		public function TPJob(params:TPParams)
		{
			super("打包贴图集: " + URLUtil.getFilename(params.textureFileName));
			this.tpParams = params;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			tp.execute(tpParams.generate());
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onTPExit(event:NativeProcessExitEvent):void
		{
			onExit.dispatch(this);
		}
	}
}
