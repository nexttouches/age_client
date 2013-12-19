package ageb.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;

	/**
	 * 图像小工具
	 * @author zhanghaocong
	 *
	 */
	public class ImageUtil
	{
		/**
		 * constructor
		 *
		 */
		public function ImageUtil()
		{
		}

		/**
		 * 假设 f 是 png 文件，这里可以返回 png 的大小
		 * @param f
		 * @return 一个 Point，x 代表宽，y 代表高度。如果 <tt>f</tt> 不是 PNG 文件则返回 null
		 *
		 */
		public static function getImageSize(f:File):Point
		{
			var result:Point;
			// 本次验证 PNG 大小，至少需要读取 24 字节
			// ( 8 字节 PNG 头) + (4 字节 IHDR 长度) + (4 字节 CHUNK 类型) + (4 字节图片宽) + (4 字节图片高)
			const VALID_SIZE:uint = 24;
			// PNG 头
			const PNG_HEADER:Vector.<uint> = new <uint>[ 0x89504E47, 0x0D0A1A0A ];
			// IHDR 的 chunk 类型
			const IHDR_TYPE:uint = 0x49484452;
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);

			if (fs.bytesAvailable >= VALID_SIZE)
			{
				// 验证 PNG 头
				if (fs.readUnsignedInt() == PNG_HEADER[0])
				{
					// 验证 PNG 头
					if (fs.readUnsignedInt() == PNG_HEADER[1])
					{
						// 跳过 IHDR 长度，我们不使用
						fs.position += 4;

						// 验证 IHDR_TYPE
						if (fs.readUnsignedInt() == IHDR_TYPE)
						{
							result = new Point();
							// 宽高
							result.x = fs.readUnsignedInt();
							result.y = fs.readUnsignedInt();
						}
					}
				}
			}
			fs.close();
			return result;
		}
	}
}
