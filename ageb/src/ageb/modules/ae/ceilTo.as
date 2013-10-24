package ageb.modules.ae
{
	public function ceilTo(n:Number, snap:Number):Number
	{
		if (snap == 1)
		{
			return n;
		}
		else
		{
			return Math.ceil(n / snap) * snap;
		}
	}
}
