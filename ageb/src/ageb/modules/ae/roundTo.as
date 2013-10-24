package ageb.modules.ae
{
	/**
	 * 取整 n 到 snap 的倍数
	 */
	public function roundTo(n:Number, snap:Number):Number
	{
		if (snap == 1)
		{
			return n;
		}
		else
		{
			return Math.round(n / snap) * snap;
		}
	}
}
