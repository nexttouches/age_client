package ageb.modules.document
{
	import flash.filesystem.File;
	import age.assets.LayerType;
	import age.assets.SceneInfo;
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.ae.SceneInfoEditable;
	import ageb.modules.job.TPJob;
	import ageb.modules.job.TPParams;
	import ageb.modules.scene.SceneDocumentView;
	import ageb.utils.FlashTip;
	import nt.assets.AssetConfig;

	/**
	 * 场景文档
	 * @author zhanghaocong
	 *
	 */
	public class SceneDocument extends Document
	{
		/**
		 * 关联的 info
		 */
		public var info:SceneInfoEditable;

		/**
		 * 根据参数创建一个新的场景文档
		 * @param file
		 * @param raw
		 *
		 */
		public function SceneDocument(file:File, raw:Object)
		{
			super(file, raw);

			// 根据文件名动态识别 ID，raw 将不储存 ID
			// 这实现了通过改文件名改 ID 的功能
			if (file && !("id" in raw))
			{
				raw.id = file.name.split(".")[0];
			}
			info = new SceneInfoEditable(raw);
			focus.x = info.width / 2;
			focus.y = info.height / 2;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get name():String
		{
			if (isNew)
			{
				return info.id;
			}
			return super.name;
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get rawString():String
		{
			return JSON.stringify(info);
		}

		/**
		 * @inheritDoc
		 * @return
		 *
		 */
		override public function get viewClass():Class
		{
			return SceneDocumentView;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function preview():void
		{
			// 场景根目录
			const folder:File = new File(AssetConfig.getInfo(SceneInfo.folder).url);
			// 场景 ID			
			const id:String = info.id;
			// 临时变量
			var tpp:TPParams, tpps:Object = {};

			// 遍历所有 BGInfo 并创建 TPParams
			for (var i:int = 0; i < info.layers.length; i++)
			{
				const layer:LayerInfoEditable = info.layers[i] as LayerInfoEditable;

				if (layer.type != LayerType.BG)
				{
					continue;
				}

				for (var j:int = 0; j < layer.bgs.length; j++)
				{
					const bg:BGInfoEditable = layer.bgs[j] as BGInfoEditable;
					const atlas:String = bg.atlas;

					if (!tpps[atlas])
					{
						tpp = new TPParams();
						tpp.dataFileName = folder.resolvePath(atlas + ".xml").nativePath;
						tpp.textureFileName = folder.resolvePath(atlas + ".png").nativePath;
						tpp.tps = folder.resolvePath(atlas + ".tps");
						tpps[atlas] = tpp;
					}
					TPParams(tpps[atlas]).addFile(folder.resolvePath(info.id + "/" + bg.srcWithExt).nativePath);
				}
			}

			// 创建对应的 Job
			for each (tpp in tpps)
			{
				modules.job.addJob(new TPJob(tpp));
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function publish():void
		{
			FlashTip.show("没做好");
		}
	}
}
