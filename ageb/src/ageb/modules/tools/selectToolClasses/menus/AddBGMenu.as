package ageb.modules.tools.selectToolClasses.menus
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import age.AGE;
	import age.assets.BGInfo;
	import age.assets.LayerType;
	import ageb.modules.ae.LayerInfoEditable;
	import ageb.modules.scene.op.AddBG;
	import ageb.utils.FileUtil;
	import ageb.utils.FlashTip;
	import ageb.utils.ImageUtil;

	/**
	 * 添加背景菜单
	 * @author zhanghaocong
	 *
	 */
	public class AddBGMenu extends SelectToolMenuItem
	{
		/**
		 * 本次操作将要添加对象到该图层
		 */
		private var info:LayerInfoEditable;

		/**
		 * 本次添加到的 x
		 */
		private var x:Number;

		/**
		 * 本次添加到的 y
		 */
		private var y:Number;

		/**
		 * constructor
		 *
		 */
		public function AddBGMenu()
		{
			super();
			contextMenuItem.caption = "添加背景";
		}

		/**
		 * @inheritDoc
		 *
		 */
		override protected function onSelect(event:Event):void
		{
			// 浏览图片
			FileUtil.browseFile(sceneInfo.expectFolder.nativePath, [ new FileFilter("PNG File", "*.png")], onComplete, null, onCancel);
		}

		/**
		 * @private
		 *
		 */
		private function onCancel():void
		{
			// 处理完毕后解引用
			info = null;
		}

		/**
		 * 选中文件后调用
		 * @param f
		 *
		 */
		private function onComplete(f:File):void
		{
			// 获得图片大小
			try
			{
				const imageSize:Point = ImageUtil.getImageSize(f);
			}
			catch (error:Error)
			{
			}

			if (!imageSize)
			{
				Alert.show("PNG 图片格式不正确", "错误");
				return;
			}

			// 如果任意边长超出，提示用户必须切片
			if (imageSize.x > BGInfo.MAX_SIDE_LENGTH || imageSize.y > BGInfo.MAX_SIDE_LENGTH)
			{
				const text:String = format("选择的图片 ({0}×{1})，边长超过 {2} 像素，必须切片后才可导入，要继续吗？", imageSize.x, imageSize.y, BGInfo.MAX_SIDE_LENGTH);
				Alert.show(text, "提示", Alert.YES | Alert.CANCEL, null, function(event:CloseEvent):void
				{
					if (event.detail != Alert.YES)
					{
						FlashTip.show("已取消");
						return;
					}
					doImport(f);
				})
			}
			else
			{
				doImport(f);
			}
		}

		/**
		 * 执行导入操作
		 * @param event 允许接受一个 CloseEvent，并且当 event.detail 不为 Alert.YES 时取消操作
		 */
		private function doImport(f:File):void
		{
			new AddBG(doc, f, info, x, y).execute();
			// 处理完毕后解引用
			info = null;
		}

		/**
		 * @inheritDoc
		 *
		 */
		override public function onShow():void
		{
			info = lr.info as LayerInfoEditable;
			x = mouseX - AGE.paddingLeft;
			y = info.parent.uiToY(mouseY - AGE.paddingTop)
			contextMenuItem.enabled = info.type == LayerType.BG;
		}
	}
}
