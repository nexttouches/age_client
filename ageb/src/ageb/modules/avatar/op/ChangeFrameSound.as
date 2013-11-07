package ageb.modules.avatar.op
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;
	import nt.assets.util.URLUtil;

	/**
	 * 修改帧声音操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameSound extends FrameOpBase
	{
		/**
		 * 贴图应该储存在该目录下
		 */
		private var folder:File;

		/**
		 * 要替换的贴图源文件列表 （将拷贝进 <code>folder</code> 如不在 folder 下）
		 */
		private var sources:Vector.<File>;

		/**
		 * 新的声音（字符串），以 FrameInfoEditable 为 key
		 */
		private var sounds:Dictionary = new Dictionary;

		/**
		 * 旧贴图属性（字符串），以 FrameInfoEditable 为 key
		 */
		private var oldSounds:Dictionary = new Dictionary;

		/**
		 * constructor
		 * @param doc 目标文档
		 * @param keyframes 目标关键帧
		 * @param folder 声音应存到该目录下
		 * @param source 要替换的声音源文件（将拷贝进 <code>folder</code> 如不在 folder 下）
		 *
		 */
		public function ChangeFrameSound(doc:Document, keyframes:Vector.<FrameInfoEditable>, folder:File, source:File)
		{
			super(doc, keyframes);
			this.folder = folder;
			sources = new <File>[ source ];
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function redo():void
		{
			var i:int, n:int, info:FrameInfoEditable;

			// 检查 sources 是否需要复制到 folder 里
			for (i = 0, n = sources.length; i < n; i++)
			{
				const source:File = sources[i];

				// 检查所在文件夹
				if (source.parent.nativePath != folder.nativePath)
				{
					source.copyTo(folder.resolvePath(source.name));
				}
			}

			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i];
				info.sound = sounds[info];
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function undo():void
		{
			var i:int, n:int, info:FrameInfoEditable;

			// 检查 sources 是否需要从 folder 删除
			for (i = 0, n = sources.length; i < n; i++)
			{
				const source:File = sources[i];

				// 检查所在文件夹
				if (source.parent.nativePath != folder.nativePath)
				{
					folder.resolvePath(source.name).deleteFile();
				}
			}

			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i];
				info.sound = oldSounds[info];
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override protected function saveOld():void
		{
			var i:int, n:int, info:FrameInfoEditable;

			// 遍历储存旧值
			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i];
				oldSounds[info] = info.sound;
			}

			// 遍历创建新值
			for (i = 0, n = frames.length; i < n; i++)
			{
				info = frames[i];

				if (sources.length > 0)
				{
					const avatarID:String = info.parent.parent.parent.id;
					const actionName:String = info.parent.parent.name;
					const source:File = sources.length > i ? sources[i] : sources[sources.length - 1];
					const soundPath:String = avatarID + "_" + actionName + "_" + URLUtil.getFilename(source.name);
					sounds[info] = soundPath;
				}
				else
				{
					sounds[info] = null;
				}
			}
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			return "修改声音";
		}
	}
}
