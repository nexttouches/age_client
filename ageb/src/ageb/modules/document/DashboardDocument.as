package ageb.modules.document
{

	/**
	 * DashboardDocument 是仪表盘文档<br>
	 * 本身啥都不干，只是个 placeholder
	 * @author zhanghaocong
	 *
	 */
	public class DashboardDocument extends Document
	{
		public function DashboardDocument()
		{
			super(null, null);
			label = name;
		}

		override public function get viewClass():Class
		{
			return DashboardView;
		}

		override public function get name():String
		{
			return "仪表盘";
		}

		override public function preview():void
		{
			// 空实现
		}

		override public function publish():void
		{
			// 空实现
		}
	}
}
