package ageb.modules.avatar.op
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import age.assets.Box;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.document.Document;
	import ageb.utils.FileUtil;
	import nt.assets.util.URLUtil;

	/**
	 * 修改帧贴图操作
	 * @author zhanghaocong
	 *
	 */
	public class ChangeFrameTexture extends FrameOpBase
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
		 * 新的贴图属性（字符串），以 FrameInfoEditable 为 key
		 */
		private var textures:Dictionary = new Dictionary;

		/**
		 * 旧贴图属性（字符串），以 FrameInfoEditable 为 key
		 */
		private var oldTextures:Dictionary = new Dictionary;

		/**
		 * 旧 box，以 FrameInfoEditable 为 key
		 */
		private var oldBoxes:Dictionary = new Dictionary();

		/**
		 * 创建一个新的 ChangeFrameTexture
		 * @param doc 目标文档
		 * @param keyframes 要修改的关键帧列表
		 * @param folder 贴图应该储存在该目录下
		 * @param sources 要替换的贴图源文件列表（将拷贝进 <code>folder</code> 如不在 folder 下）
		 *
		 */
		public function ChangeFrameTexture(doc:Document, keyframes:Vector.<FrameInfoEditable>, folder:File, sources:Vector.<File>)
		{
			super(doc, keyframes);
			this.folder = folder;
			this.sources = sources.sort(FileUtil.sortByNumber);
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
				info.texture = textures[info];

				// 也需要初始化 box
				if (!info.box)
				{
					info.setBox(new Box);
				}
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
				info.texture = oldTextures[info];
				info.setBox(oldBoxes[info]);
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
				oldTextures[info] = info.texture;
				oldBoxes[info] = info.box;
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
					const texture:String = avatarID + "_" + actionName + "#" + URLUtil.getFilename(source.name);
					textures[info] = texture;
				}
				else
				{
					textures[info] = null;
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
			return "修改贴图";
		}
	}
}
