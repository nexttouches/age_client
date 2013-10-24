package nt.ui.tooltips
{
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import nt.ui.core.IToolTipClient;

	public class ToolTipManager
	{
		private static var _container:DisplayObjectContainer;

		public static function get container():DisplayObjectContainer
		{
			return helper.container;
		}

		public static function set container(value:DisplayObjectContainer):void
		{
			helper.container = value;
		}

		private static var clients:Dictionary = new Dictionary();

		private static var helper:ToolTipShowHideHelper = new ToolTipShowHideHelper();

		public static function register(client:IToolTipClient):void
		{
			if (!container)
			{
				throw new IllegalOperationError("container 没有设置");
			}
			clients[client] = client;
			client.onAdd.add(helper.checkAndShow);
			client.onRemove.add(helper.hide);
			client.onRollOut.add(helper.hide);
			client.onRollOver.add(helper.show);
			client.onVisibleChange.add(helper.client_onVisibleChange);
		}

		public static function unregister(client:IToolTipClient):void
		{
			client.onAdd.remove(helper.checkAndShow);
			client.onRemove.remove(helper.hide);
			client.onRollOut.remove(helper.hide);
			client.onRollOver.remove(helper.show);
			client.onVisibleChange.remove(helper.client_onVisibleChange);
			delete clients[client];
		}
	}
}
