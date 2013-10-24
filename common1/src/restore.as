package
{

	/**
	 * 如果 from 中有指定 key，则从 from 中恢复数据到 to
	 */
	[Inline]
	public function restore(from:Object, to:Object, key:String):void
	{
		if (key in from)
		{
			to[key] = from[key];
		}
	}
}
