package
{

	/**
	 * 如果 key 不为 condition 则从 from 导出 key 到 to
	 */
	[Inline]
	public function export(from:Object, to:Object, key:String, condition:*):void
	{
		if (from[key] != condition)
		{
			to[key] = from[key];
		}
	}
}
