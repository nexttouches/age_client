package ageb.modules.document
{
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import age.assets.ActionInfo;
	import age.assets.AvatarInfo;
	import age.assets.FrameInfo;
	import age.assets.FrameLayerInfo;
	import age.assets.FrameLayerType;
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

			for (var i:int = 0; i < info.layers.length; i++)
			{
				const l:FrameLayerInfo = info.layers[i];

				if (l.type == FrameLayerType.ANIMATION || l.type == FrameLayerType.PARTICLE)
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
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function execute():void
		{
			tpParams.generate();
			tp.execute(tpParams.tps);
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
				im.execute(new <String>[ "-verbose", tpParams.textureFileName, "-threshold",
										 "100%%",
										 "-colors", "2", new File(prefix + "_thumb.png").nativePath ]);
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
