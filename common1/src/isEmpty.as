package
{
	/**
	 * 检查对象是否是空的，null 和 undefined 也视作空的
	 */
	public function isEmpty(o:*):Boolean
	{
		return count(o) == 0;
	}
}
