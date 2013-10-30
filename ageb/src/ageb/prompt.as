package ageb
{
	import ageb.utils.Prompt;

	/**
	 * prompt
	 */
	public function prompt(onOK:Function, title:String = null, label:String = null, value:String = null):void
	{
		if (!p)
		{
			p = new Prompt();
		}
		else if (p.isPopUp)
		{
			// 不可重复打开
			return;
		}
		p.title = title;
		p.label = label;
		p.value = value;
		p.onOK.addOnce(onOK);
		p.show();
	}
}
import ageb.utils.Prompt;

var p:Prompt;
