package ageb.modules.document
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import age.data.ActionInfo;
	import age.data.AvatarInfo;
	import age.data.FrameInfo;
	import age.data.FrameLayerInfo;
	import age.data.FrameLayerType;
	import ageb.modules.job.NativeJob;
	import nt.assets.AssetConfig;

	/**
	 * 发布动作的 Job
	 * @author zhanghaocong
	 *
	 */
	public class PublishActionJob extends NativeJob
	{
		/**
		 * 输出目录
		 */
		public var outputFolder:File;

		/**
		 * 这些文件直接拷贝出去
		 */
		public var pairs:Vector.<Pair> = new Vector.<Pair>;

		/**
		 * 输出动作路径的前缀
		 */
		public var prefix:String;

		/**
		 * 创建一个新的 PublishActionJob
		 * @param info
		 *
		 */
		public function PublishActionJob(info:ActionInfo)
		{
			super("发布动作: " + info.name);
			prefix = new File(AssetConfig.getInfo(AvatarInfo.folder + "/" + info.parent.id + "_" + info.name).url).nativePath;
			tpParams.dataFileName = prefix + ".xml";
			tpParams.textureFileName = prefix + ".png";
			tpParams.tps = new File(prefix + ".tps");
			outputFolder = tpParams.tps.parent;

			for (var i:int = 0; i < info.layers.length; i++)
			{
				const l:FrameLayerInfo = info.layers[i];

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

		/**
		 * 为 TPParams 准备数据
		 * @param l
		 *
		 */
		protected function prepareTPParams(l:FrameLayerInfo):void
		{
			l.fillFramesTexture();

			for (var j:int = 0; j < l.frames.length; j++)
			{
				const frame:FrameInfo = l.frames[j];

				if (frame.isKeyframe && !frame.isEmpty)
				{
					const url:String = AssetConfig.getInfo(AvatarInfo.folder + "/" + frame.texturePath + ".png").url;
					tpParams.addFile(new File(url).nativePath);
				}
			}
		}

		protected function prepareFilesToCopy(l:FrameLayerInfo):void
		{
			for (var j:int = 0; j < l.frames.length; j++)
			{
				const frame:FrameInfo = l.frames[j];

				if (frame.isKeyframe && !frame.isEmpty)
				{
					const url:String = AssetConfig.getInfo(AvatarInfo.folder + "/" + frame.soundPath).url;
					pairs.push(new Pair(new File(url), outputFolder.resolvePath(frame.sound + ".mp3")));
				}
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			if (pairs.length > 0)
			{
				stdout.push(format("拷贝 {length} 个声音文件...", pairs));

				for (var i:int = 0; i < pairs.length; i++)
				{
					pairs[i].from.copyTo(pairs[i].to, true);
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
	}
}
import flash.filesystem.File;

class Pair
{
	function Pair(from:File, to:File)
	{
		this.from = from;
		this.to = to;
	}

	public var from:File;

	public var to:File;
}
