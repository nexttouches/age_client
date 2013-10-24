package nt.lib.util
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * 就是 getURL
	 */
	public function getURL(url:String, target:String = "_blank"):void
	{
		// 使用唯一的 request 避免重复创建 URLRequest
		if (!request)
		{
			request = new URLRequest();
		}
		request.url = url;
		navigateToURL(request, target);
	}
}
import flash.net.URLRequest;

var request:URLRequest;
