package nt.lib.util
{
	import org.osflash.signals.ISignal;

	/**
	 * 指示该类的实例是可被回收资源的，原则上所有的类都要实现该接口
	 * @author zhanghaocong
	 *
	 */
	public interface IDisposable
	{
		/**
		 * 调用 dispose 时发出的 signal
		 * @return
		 *
		 */
		function get onDispose():ISignal;
		/**
		 * 回收实例占用的资源
		 * @return true 成功 false 失败
		 *
		 */
		function dispose():Boolean;
		/**
		 * 检查当前实例是否已被回收
		 * @return
		 *
		 */
		function get isDisposed():Boolean;
	}
}
