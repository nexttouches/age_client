package ageb.modules.job
{
	import ageb.modules.Modules;

	/**
	 * 打包进度面板
	 * @author zhanghaocong
	 *
	 */
	public class JobProgressPanel extends JobProgressPanelTemplate
	{
		/**
		 * 创建一个新的 JobProgressPanel
		 *
		 */
		public function JobProgressPanel()
		{
			super();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			// 绑个数据源
			entries.dataProvider = modules.job.runnings;
		}

		/**
		 * @private
		 * @return
		 *
		 */
		protected function get modules():Modules
		{
			return Modules.getInstance();
		}
	}
}
