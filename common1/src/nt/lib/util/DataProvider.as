package nt.lib.util
{
	import flash.events.Event;
	import flash.system.Capabilities;

	import avmplus.getQualifiedSuperclassName;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class DataProvider
	{
		public function DataProvider(source:*, pageSize:int = -1)
		{
			this.source = source;
			this.pageSize = pageSize;
		}

		private var _onCurrentPageChange:ISignal;

		public function get onCurrentPageChange():ISignal
		{
			return _onCurrentPageChange ||= new Signal(int);
		}

		private var _onAdd:ISignal;

		public function get onAdd():ISignal
		{
			return _onAdd ||= new Signal(int);
		}

		private var _onRemove:ISignal;

		public function get onRemove():ISignal
		{
			return _onRemove ||= new Signal(int);
		}

		private var _currentPage:int;

		public function get currentPage():int
		{
			return _currentPage;
		}

		public function set currentPage(value:int):void
		{
			if (value > totalPages)
			{
				value = totalPages - 1;
			}
			else if (value < 0)
			{
				value = 0;
			}
			_currentPage = value;
			_currentPageContent = null;

			if (_onCurrentPageChange != null)
			{
				_onCurrentPageChange.dispatch(value);
			}
		}

		public function get totalPages():int
		{
			if (_pageSize == 0)
			{
				return 1;
			}
			return Math.ceil(source.length / _pageSize);
		}

		private var _pageSize:int;

		public function get pageSize():int
		{
			return _pageSize;
		}

		public function set pageSize(value:int):void
		{
			_pageSize = value;
			currentPage = 0;
		}

		protected var _currentPageContent:*;

		public function get currentPageContent():*
		{
			var s:*;

			if (_filterFunction == null)
			{
				s = source;
			}
			else
			{
				s = source.filter(_filterFunction);
			}

			if (!_currentPageContent)
			{
				if (_pageSize == -1)
				{
					return s.slice();
				}
				else
				{
					_currentPageContent = s.slice(_currentPage * _pageSize, (_currentPage + 1) * _pageSize);
				}
			}
			return _currentPageContent;
		}

		private var _source:*;

		public function get source():*
		{
			return _source;
		}

		public function set source(value:*):void
		{
			_source = value;
			_currentPageContent = null;
			invalidate();
		}

		private var _filterFunction:Function;

		public function get filterFunction():Function
		{
			return _filterFunction;
		}

		public function set filterFunction(value:Function):void
		{
			_filterFunction = value;
			invalidate();
		}

		public function notifyAdd(index:int):void
		{
			_currentPageContent = null;

			if (_onAdd)
			{
				_onAdd.dispatch(index);
			}
		}

		public function notifyRemove(index:int):void
		{
			_currentPageContent = null;

			if (_onRemove)
			{
				_onRemove.dispatch(index);
			}
		}

		public function currentPageReadable():String
		{
			return String(currentPage + 1);
		}

		public function totalPagesReadable():String
		{
			return String(totalPages);
		}

		public function invalidate(event:Event = null):void
		{
			currentPage = currentPage;
		}

		public function get isEmpty():Boolean
		{
			return source.length == 0;
		}

		/**
		 *
		 * @return {"page","index"}
		 *
		 */
		public function getPageIndex(sourceItem:*):Object
		{
			var s:*;

			if (_filterFunction == null)
			{
				s = source;
			}
			else
			{
				s = source.filter(_filterFunction);
			}
			var index:int = s.indexOf(sourceItem);

			if (index != -1)
			{
				var page:int = Math.floor(index / _pageSize);
				var indexOfPage:int = index % _pageSize;
				return { "page": page, "index": indexOfPage };
			}
			else
			{
				return null;
			}
		}
	}
}
