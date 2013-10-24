package ageb.modules.job
{

	public class JobProgressItemRenderer extends JobProgressItemRendererTemplate
	{
		public function JobProgressItemRenderer()
		{
		}

		public function get job():NativeJob
		{
			return data as NativeJob;
		}

		override public function set data(value:Object):void
		{
			if (job)
			{
				job.onSTDOut.remove(onSTDOut);
				job.onSTDErr.remove(onSTDErr);
				titleField.text = "";
				logField.text = "";
			}
			super.data = value;

			if (job)
			{
				job.onSTDOut.add(onSTDOut);
				job.onSTDErr.add(onSTDErr);
				titleField.text = job.name;
				onSTDOut(job.stdout.join());
				onSTDErr(job.stderr.join());
			}
		}

		private function onSTDErr(s:String):void
		{
			logField.appendText(s);
		}

		private function onSTDOut(s:String):void
		{
			logField.appendText(s);
		}
	}
}
