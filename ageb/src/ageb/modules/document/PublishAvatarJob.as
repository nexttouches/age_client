package ageb.modules.document
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import age.data.AvatarInfo;
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import age.data.FrameLayerType;
	import ageb.modules.ae.ActionInfoEditable;
	import ageb.modules.job.NativeJob;
	import nt.assets.AssetConfig;
	import nt.lib.util.assert;

	/**
	 * 发布 Avatar 的 Job
	 * @author zhanghaocong
	 *
	 */
	public class PublishAvatarJob extends NativeJob
	{
		/**
		 * 输出目录
		 */
		public var outputFolder:File;

		/**
		 * 这些文件直接拷贝出去
		 */
		public var copyTasks:Vector.<CopyTask> = new Vector.<CopyTask>;

		/**
		 * 输出动作路径的前缀
		 */
		public var prefix:String;

		/**
		 * 发布时使用的临时文件夹
		 */
		public var tempFolder:File;

		/**
		 * constructor
		 * @param atlas 要发布到该贴图集中
		 * @param actions 要发布的动作
		 *
		 */
		public function PublishAvatarJob(atlas:String, actions:Vector.<ActionInfoEditable>)
		{
			super("发布 Avatar (" + atlas + ")");
			prefix = new File(AssetConfig.getInfo(AvatarInfo.folder + "/" + atlas).url).nativePath;
			tpParams.dataFileName = prefix + ".xml";
			tpParams.textureFileName = prefix + ".png";
			tpParams.tps = new File(prefix + ".tps");
			outputFolder = tpParams.tps.parent;
			tempFolder = File.createTempDirectory();

			for each (var action:ActionInfoEditable in actions)
			{
				for (var i:int = 0; i < action.layers.length; i++)
				{
					const l:FrameLayerInfo = action.layers[i];

					if (l.type == FrameLayerType.ANIMATION || l.type == FrameLayerType.PARTICLE)
					{
						prepareTPParams(l);
					}
					else if (l.type == FrameLayerType.SOUND)
					{
						prepareFilesToCopy(l);
					}
				}
			}
		}

		/**
		 * 为 TPParams 准备数据
		 * @param l
		 *
		 */
		protected function prepareTPParams(l:FrameLayerInfo):void
		{
			for (var j:int = 0; j < l.frames.length; j++)
			{
				const frame:FrameInfo = l.frames[j];

				if (frame.isKeyframe && !frame.isEmpty)
				{
					// 粒子图层帧的 texturePath 可能会为 null
					if (!frame.texturePath)
					{
						continue;
					}
					const url:String = AssetConfig.getInfo(AvatarInfo.folder + "/" + frame.texturePath + ".png").url;
					// 拷进临时文件夹
					const source:File = new File(url);
					const dest:File = tempFolder.resolvePath(source.parent.parent.name + "_" + source.parent.name + "_" + source.name);
					source.copyTo(dest, true);
					tpParams.addFile(dest.nativePath);
				}
			}
		}

		/**
		 * @private
		 *
		 */
		protected function prepareFilesToCopy(l:FrameLayerInfo):void
		{
			for (var j:int = 0; j < l.frames.length; j++)
			{
				const frame:FrameInfo = l.frames[j];

				if (frame.isKeyframe && !frame.isEmpty)
				{
					const url:String = AssetConfig.getInfo(AvatarInfo.folder + "/" + frame.soundPath).url;
					copyTasks.push(new CopyTask(new File(url), outputFolder.resolvePath(frame.sound + ".mp3")));
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			if (copyTasks.length > 0)
			{
				stdout.push(format("拷贝 {length} 个声音文件...", copyTasks));

				for (var i:int = 0; i < copyTasks.length; i++)
				{
					copyTasks[i].execute();
				}
			}
			tp.execute(tpParams.generate());
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onTPExit(event:NativeProcessExitEvent):void
		{
			const NOT_CHANGED:String = "Nothing to do - sprite sheet not changed";
			const stdout:String = this.stdout.join();

			// 检查 stdout 最后一段是否是 Nothing to …… 之后才进行黑白处理
			if (stdout.lastIndexOf(NOT_CHANGED) != stdout.length - NOT_CHANGED.length - 1)
			{
				// 以下指令将利用 ImageMagick 处理成黑白图
				im.execute(new <String>[ //
						   "-verbose", tpParams.textureFileName, // 输入路径
						   "-threshold", "100%%", // 设置 threshold
						   "-colors", "2", // 只保留 2 个颜色
						   new File(prefix + "_thumb.png").nativePath // 输出路径
						   ]);
			}
			else
			{
				exit();
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onIMExit(event:NativeProcessExitEvent):void
		{
			exit();
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function exit():void
		{
			super.exit();
			tempFolder.deleteDirectory(true);
		}
	}
}
import flash.filesystem.File;

class CopyTask
{
	/**
	 * constructor
	 * @param from
	 * @param to
	 *
	 */
	public function CopyTask(from:File, to:File)
	{
		this.from = from;
		this.to = to;
	}

	public var from:File;

	public var to:File;

	/**
	 * 执行拷贝操作
	 *
	 */
	public function execute():void
	{
		from.copyTo(to, true);
	}
}
