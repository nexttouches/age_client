package age.utils
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import starling.textures.Texture;

	/**
	 * 为 starlingTexture 更新 nativeTexture
	 */
	[Inline]
	public function updateNativeTexture(starlingTexture:starling.textures.Texture, bitmapData:BitmapData):void
	{
		flash.display3D.textures.Texture(starlingTexture.base).uploadFromBitmapData(bitmapData);
	}
}
