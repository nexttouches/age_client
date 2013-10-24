package nt.ui.util
{

	/**
	 * 支持 popup 的 client
	 * @author zhanghaocong
	 *
	 */
	public interface IPopUpClient
	{
		/**
		 * 指示是否启用安静模式<br/>
		 * 如果为 true，对象被打开的时将不会触发 PopUpManager.onAdd 等事件
		 * @return
		 *
		 */
		function get isSlient():Boolean;
		/**
		 * 打开
		 * @param isCenter
		 * @param layer
		 * @param isModal
		 *
		 */
		function popUp(isCenter:Boolean = true, layer:uint = 0, isModal:Boolean = false):void;
		/**
		 * 关闭
		 *
		 */
		function close():void;
	}
}
