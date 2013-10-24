package
{
	/**
	 * 计算对象有几个属性不为 null 和 undefined
	 */
	public function count(o:*):int
	{
		var count:int = 0;
		for (var key:String in o)
		{
			if (o[key] !== undefined && o[key] !== null)
			{
				count++;
			}
		}
		return count;
	}
}
