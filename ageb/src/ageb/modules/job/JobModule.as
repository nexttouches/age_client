package ageb.modules.job
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.managers.PopUpManager;
	import age.data.SceneInfo;
	import ageb.modules.ModuleBase;
	import ageb.utils.FlashTip;
	import nt.lib.util.assert;
	import nt.lib.util.callLater;
	import org.apache.flex.collections.VectorList;

	/**
	 * Job 模块用于处理外部程序调用
	 * @author zhanghaocong
	 *
	 */
	public class JobModule extends ModuleBase
	{
		/**
		 * 并发数
		 */
		public static const MAX_THREADS:int = 3;

		/**
		 * 所有等待中的任务
		 */
		public var peddings:VectorList = new VectorList(new Vector.<NativeJob>());

		/**
		 * 所有执行中的任务
		 */
		public var runnings:VectorList = new VectorList(new Vector.<NativeJob>());

		/**
		 * 进度面板
		 */
		public var progressPanel:JobProgressPanel = new JobProgressPanel();

		/**
		 * 全部任务完成后，是否自动关闭面板
		 */
		// TODO 放到 settings 中
		public var isAutoClosePanel:Boolean = true;

		/**
		 * 创建一个新的 TPModule
		 *
		 */
		public function JobModule()
		{
		}

		/**
		 * 初始化 JobModule
		 *
		 */
		public function init():void
		{
			peddings.addEventListener(CollectionEvent.COLLECTION_CHANGE, peddings_onChange);
			runnings.addEventListener(CollectionEvent.COLLECTION_CHANGE, runnings_onChange);
			NativeApplication.nativeApplication.openedWindows[0].addEventListener(Event.CLOSING, onClosing);
		}

		/**
		 * 关闭程序时检查是否有任务进行中
		 * @param event
		 *
		 */
		protected function onClosing(event:Event):void
		{
			if (isRunning)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				event.stopPropagation();
				Alert.show("请等待任务全部执行完毕", "提示");
			}
		}

		/**
		 * runnings 变化时调用
		 * @param event
		 *
		 */
		protected function runnings_onChange(event:CollectionEvent):void
		{
			var job:NativeJob;

			// 有任务进来了
			if (event.kind == CollectionEventKind.ADD)
			{
				// 执行刚刚添加到 runnings 中的队列
				for each (job in event.items)
				{
					job.onExit.addOnce(runnings.removeItem);

					try
					{
						job.execute();
						threadsRunning++;
					}
					catch (error:Error)
					{
						FlashTip.show(error.message);
						job.exit();
					}
				}
			}
			// 有任务被删除了（完成或取消）
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				// 检查是否要关闭进度面板
				if (isAutoClosePanel)
				{
					if (progressPanel.parent)
					{
						if (peddings.length == 0 && runnings.length == 0)
						{
							// 没有剩余任务
							PopUpManager.removePopUp(progressPanel);
						}
					}
				}
				// 不应该出现同时删除多个的情况
				assert(event.items.length == 1);
				FlashTip.show("已完成（" + event.items[0].name + "）");
				threadsRunning -= event.items.length;
				// 必须调用 callLater，否则不会正确刷新
				callLater(executeNext);
			}
			else
			{
				throw new Error("不支持的 kind: " + event.kind);
			}

			// 有任何运行中的任务进就打开面板
			if (threadsRunning > 0 && progressPanel.parent == null)
			{
				PopUpManager.addPopUp(progressPanel, modules.root, true);
				PopUpManager.centerPopUp(progressPanel);
			}
			progressPanel.title = jobStats;
		}

		protected function peddings_onChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD)
			{
				progressPanel.title = jobStats;
			}
		}

		/**
		* 空闲中的线程数
		* @return
		*
		*/
		public function get threadsIdle():int
		{
			return threadsMax - threadsRunning;
		}

		/**
		* 运行中的线程数
		*/
		public var threadsRunning:int = 0;

		/**
		 * 同时加载的线程数
		 */
		public var threadsMax:int = MAX_THREADS;

		private var isAlertOpen:Boolean = false;

		/**
		 * TPModule 是否正在执行队列
		 * @return
		 *
		 */
		public function get isRunning():Boolean
		{
			return peddings.length > 0 || runnings.length > 0;
		}

		/**
		 * 执行下一个任务<br>
		 * 受 threadMax 限制，连续调用也不会出错，可以随时调用
		 *
		 */
		public function executeNext():void
		{
			if (isAlertOpen)
			{
				return;
			}
			const tpPath:String = settings.getData().tpPath;
			const imPath:String = settings.getData().imPath;

			if (!tpPath || !imPath)
			{
				isAlertOpen = true;
				Alert.show("请先设置 TP 和 IM 的路径", "提示", Alert.YES, null, openSettingsPanel);
				return;
			}

			while (threadsIdle > 0)
			{
				if (peddings.length > 0)
				{
					runnings.addItem(peddings.removeItemAt(0));
				}
				else
				{
					break;
				}
			}
		}

		private function openSettingsPanel(... ignored):void
		{
			settings.open();
			isAlertOpen = false;
		}

		/**
		 * 添加一个任务
		 * @param job
		 *
		 */
		public function addJob(job:NativeJob):void
		{
			job.onExit.addOnce(runnings.removeItem);
			peddings.addItem(job);
			executeNext();
		}

		/**
		 * 任务状态
		 * @return
		 *
		 */
		protected function get jobStats():String
		{
			return format("[任务]运行/等待：{0}/{1} [线程]运行/最大（空闲）：{2}/{3}({4})", runnings.length, peddings.length, threadsRunning, threadsMax, threadsIdle);
		}
	}
}
