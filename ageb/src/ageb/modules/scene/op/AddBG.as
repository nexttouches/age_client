package ageb.modules.scene.op
{
	import flash.filesystem.File;
	import age.assets.BGInfo;
	import ageb.modules.ae.BGInfoEditable;
	import ageb.modules.ae.ISelectableInfo;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.document.Document;
	import nt.assets.util.URLUtil;

	/**
	 * 添加一个背景图的操作
	 * @author zhanghaocong
	 *
	 */
	public class AddBG extends SceneOPBase
	{
		/**
		 * SLICE_PATTERN 匹配中的前缀部分
		 */
		private static const MATCH_PREFIX:int = 1;

		/**
		 * SLICE_PATTERN 匹配中的 x 部分
		 */
		private static const MATCH_X:int = 2;

		/**
		 * SLICE_PATTERN 匹配中的 y 部分
		 */
		private static const MATCH_Y:int = 3;

		/**
		 * SLICE_PATTERN 匹配中的扩展名部分（不含 "." ）
		 */
		private static const MATCH_EXT:int = 4;

		/**
		 * 用于匹配切片文件名的正则模式
		 */
		private static const SLICE_PATTERN:RegExp = /(.+)_(\d+)_(\d+)\.(\w+)/i;

		/**
		 * 目标图层
		 */
		public var parent:LayerInfoEditable;

		/**
		 * 目标坐标 x
		 */
		public var x:Number;

		/**
		 * 目标坐标 y
		 */
		public var y:Number;

		/**
		 * 本次添加的 BGInfoEditable
		 */
		public var infos:Vector.<BGInfoEditable>;

		/**
		 * OP 执行前的选中（撤销时使用）
		 */
		public var oldSelections:Vector.<ISelectableInfo>;

		/**
		 * 要导入的贴图文件
		 */
		public var f:File;

		/**
		 * constructor
		 * @param doc 目标文档
		 * @param f 要导入的贴图文件，将自动识别 prefix_x_y.png 这样的文件格式并进行批量导入
		 * @param parent 目标图层
		 * @param x 可选，目标场景坐标 x，默认是 0 （左下角）
		 * @param y 可选，目标场景坐标 y，默认是 0 （左下角）
		 *
		 */
		public function AddBG(doc:Document, f:File, parent:LayerInfoEditable, x:Number = NaN, y:Number = NaN)
		{
			super(doc);
			this.f = f;
			this.parent = parent;
			this.x = x;
			this.y = y;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function redo():void
		{
			for each (var info:BGInfoEditable in infos)
			{
				parent.add(info);
			}
			// 主动选中新增的对象
			doc.info.setSelectedObjects(infos);
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function saveOld():void
		{
			oldSelections = doc.info.selectedObjects.concat();
			infos = new Vector.<BGInfoEditable>();
			const m:Array = f.name.match(SLICE_PATTERN);

			// 匹配了 prefix_x_y.png 这样的文件名，执行批量导入
			if (m)
			{
				const folder:File = f.parent;
				const prefix:String = m[MATCH_PREFIX];
				const ext:String = m[MATCH_EXT];
				// 记录每行找到了几个
				var numFound:int = 0;

				for (var y:int = 0; true; y++)
				{
					numFound = 0;

					for (var x:int = 0; true; x++)
					{
						const found:File = folder.resolvePath(prefix + "_" + x + "_" + y + "." + ext);

						if (found.exists)
						{
							numFound++;
							infos.push(createInfo(prefix, URLUtil.getFilename(found.name), x * BGInfo.MAX_SIDE_LENGTH + this.x, y * BGInfo.MAX_SIDE_LENGTH + this.y));
						}
						else
						{
							break;
						}
					}

					// 本行一个都没有，说明是真的都没了…
					if (numFound == 0)
					{
						break;
					}
				}
			}
			else
			{
				infos.push(createInfo(doc.info.id, URLUtil.getFilename(f.name), this.x, this.y));
			}
		}

		/**
		 * 根据参数创建 BGInfoEditable
		 * @param altas
		 * @param src
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		protected function createInfo(altas:String, src:String, x:Number, y:Number):BGInfoEditable
		{
			var result:BGInfoEditable = new BGInfoEditable();
			result.x = x;
			result.y = y;
			result.atlas = altas;
			result.src = src;
			return result;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function undo():void
		{
			doc.info.setSelectedObjects(oldSelections);

			for each (var info:BGInfoEditable in infos)
			{
				parent.remove(info);
			}
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function get name():String
		{
			return format("添加背景于 (图层 {0}, {1}, {2})", parent.index, x, y);
		}
	}
}
