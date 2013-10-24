package ageb.modules.job
{
	import flash.desktop.NativeProcess;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.utils.IDataInput;
	import ageb.modules.Modules;
	import org.osflash.signals.OnceSignal;
	import org.osflash.signals.Signal;

	/**
	 * 包含各类需要的本地调用
	 * @author zhanghaocong
	 *
	 */
	public class NativeJob
	{
		/**
		 * TPParams
		 */
		public var tpParams:TPParams = new TPParams();

		/**
		 * 当前任务关联的 tp
		 */
		protected var tp:TexturePacker;

		/**
		 * 当前任务关联的 im
		 */
		protected var im:ImageMagick;

		/**
		 * 任务名称
		 */
		public var name:String;

		/**
		 * 任务完成时调用<br>
		 * 正确的签名是<br>
		 * function (target:NativeJob):void;
		 */
		public var onExit:OnceSignal = new OnceSignal(NativeJob);

		/**
		 * stderr 时触发
		 */
		public var onSTDErr:Signal = new Signal(String);

		/**
		 * stdout 时触发
		 */
		public var onSTDOut:Signal = new Signal(String);

		/**
		 * constructor
		 * @param name
		 *
		 */
		public function NativeJob(name:String)
		{
			this.name = name;
			tp = new TexturePacker();
			tp.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, collectSTDOut);
			tp.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, collectSTDErr);
			tp.addEventListener(NativeProcessExitEvent.EXIT, onTPExit);
			im = new ImageMagick();
			im.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, collectSTDOut);
			im.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, collectSTDErr);
			im.addEventListener(NativeProcessExitEvent.EXIT, onIMExit);
		}

		/**
		 * @priate
		 * @param event
		 *
		 */
		protected function onIMExit(event:NativeProcessExitEvent):void
		{
			// 由子类覆盖处理逻辑
		}

		/**
		 * @private
		 *
		 */
		protected function onTPExit(event:NativeProcessExitEvent):void
		{
			// 由子类覆盖处理逻辑
		}

		/**
		 * 删除所有 im 的侦听
		 *
		 */
		protected function removeIMListeners():void
		{
			im.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, collectSTDOut);
			im.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, collectSTDErr);
			im.removeEventListener(NativeProcessExitEvent.EXIT, onIMExit);
		}

		/**
		 * 删除所有 tp 的侦听
		 *
		 */
		protected function removeTPListeners():void
		{
			tp.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, collectSTDOut);
			tp.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, collectSTDErr);
			tp.removeEventListener(NativeProcessExitEvent.EXIT, onTPExit);
		}

		/**
		 * 退出代码
		 *
		 */
		public function exit():void
		{
			removeIMListeners();
			removeTPListeners();
			onExit.dispatch(this);
			onExit.removeAll();
			onSTDErr.removeAll();
			onSTDOut.removeAll();
		}

		/**
		 * @private
		 *
		 */
		protected function collectSTDErr(event:ProgressEvent):void
		{
			const s:String = getOutput(NativeProcess(event.currentTarget).standardError);
			stderr.push(s);
			onSTDErr.dispatch(s);
		}

		/**
		 * @private
		 *
		 */
		protected function collectSTDOut(event:ProgressEvent):void
		{
			const s:String = getOutput(NativeProcess(event.currentTarget).standardOutput);
			stdout.push(s);
			onSTDOut.dispatch(s);
		}

		/**
		 * 执行当前 job
		 *
		 */
		public function execute():void
		{
			throw new Error("需子类实现");
		}

		/**
		 * stdout
		 */
		public var stdout:Vector.<String> = new Vector.<String>;

		/**
		 * stderr
		 */
		public var stderr:Vector.<String> = new Vector.<String>;

		/**
		 * 获得指定 source 的输出
		 * @return
		 *
		 */
		protected function getOutput(source:IDataInput):String
		{
			return source.readUTFBytes(source.bytesAvailable).replace(/\r\n/g, "\r");
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
