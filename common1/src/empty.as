package
{
	/**
	 * 清空指定对象的所有属性
	 */
	public function empty(o:*):void
	{
		for (var key:String in o)
		{
			delete o[key];
		}
	}
}
