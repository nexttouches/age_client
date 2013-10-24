package age.utils
{

	/**
	 * 将 y 和 z 投影到 2D 的 y 坐标<br>
	 * 这里的 y 和 z 采用笛卡尔坐标系，max 是指最大大小，一般是场景大小
	 * @see ae.assets.Box
	 */
	[Inline]
	public function __projectY(y:Number, z:Number, max:Number = 0):Number
	{
		return max - y - z * 0.5;
	}
}
