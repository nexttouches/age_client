package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class imgrebuilder extends Sprite
	{
		public function imgrebuilder()
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}

		/**
		 * @private
		 *
		 */
		protected function onInvoke(event:InvokeEvent):void
		{
			if (event.arguments.length == 0)
			{
				NativeApplication.nativeApplication.exit();
				return;
			}
			var from:File = new File(event.arguments[0]);

			if (!from.exists)
			{
				NativeApplication.nativeApplication.exit();
				return;
			}

			if (!from.isDirectory)
			{
				NativeApplication.nativeApplication.exit();
				return;
			}

			for each (var file:File in from.getDirectoryListing())
			{
				if (file.extension == "img")
				{
					exportIMGHeaders(file, from.resolvePath(file.name + ".json"))
				}
			}
		}

		/**
		 * 提取 *.img 中的图片位置信息
		 * @return
		 *
		 */
		public function exportIMGHeaders(from:File, to:File):void
		{
			var rects:Vector.<Rect> = new Vector.<Rect>;
			trace("处理文件 " + from.nativePath + " ...");
			// 文件头标志
			const EXPECT_HEADER:String = "Neople Img File";
			var fs:FileStream = new FileStream();
			fs.endian = Endian.LITTLE_ENDIAN;
			fs.open(from, FileMode.READ);
			const flag:String = fs.readMultiByte(16, "utf-8"); // 文件头

			if (flag == EXPECT_HEADER)
			{
				const indexSize:int = fs.readInt() // 索引表大小
				trace("索引表大小    " + indexSize);
				fs.position += 8; // 跳过 8 个字节（未知字段）
				const numIndexs:int = fs.readInt(); // 索引数
				trace("  索引总数    " + numIndexs);

				for (var i:int = 0; i < numIndexs; i++)
				{
					const type:uint = fs.readUnsignedInt(); // 类型
					const compress:uint = fs.readUnsignedInt(); // 压缩
					var rect:Rect = new Rect();

					if (type == 0x11) // 占位符
					{
						rects.push(rect);
						continue;
					}
					fs.position += 12; // 不需要的字段
					rect.x = fs.readInt();
					rect.y = fs.readInt();
					rect.width = fs.readInt();
					rect.height = fs.readInt();
					rects.push(rect);
				}
			}
			else
			{
				trace("文件格式不正确，跳过");
			}
			fs.close();
			fs.open(to, FileMode.WRITE);
			fs.writeUTFBytes(JSON.stringify(rects));
			fs.close();
			trace("已写入 " + to.nativePath);
			const imgFolder:File = from.parent.resolvePath(from.name.split(".")[0]);

			if (!imgFolder.exists || !imgFolder.isDirectory)
			{
				return;
			}
			alignIMGs(imgFolder, rects);
		}

		private function alignIMGs(imgFolder:File, rects:Vector.<Rect>):void
		{
			trace("发现已有序列帧位于 " + imgFolder.nativePath + "，开始对齐…");
			var imgFiles:Array = imgFolder.getDirectoryListing().sortOn("name", Array.NUMERIC);
			rects = rects.concat();

			if (imgFiles.length != rects.length)
			{
				trace("错误：图片数与数据不一致，已取消对齐操作");
				return;
			}
			function doAlign():void
			{
				if (imgFiles.length > 0)
				{
					const file:File = imgFiles.shift();
					const rect:Rect = rects[int(file.name.split(".")[0])];
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
					{
						var canvas:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
						const source:BitmapData = Bitmap(loader.content).bitmapData;

						// 避免重复执行
						if (source.width != canvas.width || source.height != canvas.height)
						{
							canvas.copyPixels(source, source.rect, new Point(rect.x, rect.y));
							var buffer:ByteArray = new ByteArray();
							canvas.encode(canvas.rect, new PNGEncoderOptions, buffer);
							var fs:FileStream = new FileStream();
							fs.open(file, FileMode.WRITE);
							fs.writeBytes(buffer);
							fs.close();
						}
						doAlign();
					});
					loader.load(new URLRequest(file.url));
					trace("正在对齐 " + file.nativePath + " …");
				}
				else
				{
				}
			}
			doAlign();
		}
	}
}
