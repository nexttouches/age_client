package nt.ui.components
{
	import nt.ui.util.ISelectable;

	public interface IDataRenderer extends ISelectable
	{
		function get data():*;
		function set data(value:*):void;
	}
}
