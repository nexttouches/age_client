package ageb.modules.avatar.timelineClasses
{
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.managers.IToolTipManagerClient;
	import spark.components.Grid;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.IGridItemRenderer;
	import spark.components.supportClasses.TextBase;
	import ageb.modules.ae.FrameInfoEditable;
	import ageb.modules.ae.FrameLayerInfoEditable;
	use namespace mx_internal;

	/**
	 * 帧网格每个格子的渲染器
	 * @author zhanghaocong
	 *
	 */
	public class FrameCell extends UIComponent implements IGridItemRenderer
	{
		/**
		 * constructor
		 *
		 */
		public function FrameCell()
		{
			super();
			minWidth = 0;
			minHeight = 0;
			width = 10;
			height = 21;
			setCurrentStateNeeded = true;
			accessibilityEnabled = false;
		}

		/**
		 * If the effective value of showDataTips has changed for this column, then
		 * set the renderer's toolTip property to a placeholder.  The real tooltip
		 * text is computed in the TOOL_TIP_SHOW handler below.
		 */
		static mx_internal function initializeRendererToolTip(renderer:IGridItemRenderer):void
		{
			const toolTipClient:IToolTipManagerClient = renderer as IToolTipManagerClient;

			if (!toolTipClient)
				return;
			const showDataTips:Boolean = (renderer.rowIndex != -1) && renderer.column && renderer.column.getShowDataTips();
			const dataTip:String = toolTipClient.toolTip;

			if (!dataTip && showDataTips)
				toolTipClient.toolTip = "<dataTip>";
			else if (dataTip && !showDataTips)
				toolTipClient.toolTip = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 *  True if the renderer has been created and commitProperties hasn't
		 *  run yet. See commitProperties.
		 */
		private var setCurrentStateNeeded:Boolean = false;

		/**
		 *  @private
		 *  A flag determining if this renderer should play any
		 *  associated transitions when a state change occurs.
		 */
		mx_internal var playTransitions:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 */
		private function dispatchChangeEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new Event(type));
		}

		//----------------------------------
		//  baselinePosition override
		//----------------------------------
		/**
		 *  @private
		 */
		override public function get baselinePosition():Number
		{
			if (!validateBaselinePosition() || !labelDisplay)
				return super.baselinePosition;
			const labelPosition:Point = globalToLocal(labelDisplay.parent.localToGlobal(new Point(labelDisplay.x, labelDisplay.y)));
			return labelPosition.y + labelDisplay.baselinePosition;
		}

		//----------------------------------
		//  column
		//----------------------------------
		private var _column:GridColumn = null;

		[Bindable("columnChanged")]
		/**
		 *  @inheritDoc
		 *
		 *  <p>The Grid's <code>updateDisplayList()</code> method sets this property
		 *  before calling <code>preprare()</code></p>.
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get column():GridColumn
		{
			return _column;
		}

		/**
		 *  @private
		 */
		public function set column(value:GridColumn):void
		{
			if (_column == value)
				return;
			_column = value;
			dispatchChangeEvent("columnChanged");
		}

		//----------------------------------
		//  columnIndex
		//----------------------------------
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get columnIndex():int
		{
			return (column) ? column.columnIndex : -1;
		}

		//----------------------------------
		//  data
		//----------------------------------
		private var _data:Object = null;

		[Bindable("dataChange")] // compatible with FlexEvent.DATA_CHANGE
		/**
		 *  The value of the data provider item for the grid row
		 *  corresponding to the item renderer.
		 *  This value corresponds to the object returned by a call to the
		 *  <code>dataProvider.getItemAt(rowIndex)</code> method.
		 *
		 *  <p>Item renderers can override this property definition to access
		 *  the data for the entire row of the grid. </p>
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get data():Object
		{
			return _data;
		}

		/**
		 *  @private
		 */
		public function set data(value:Object):void
		{
			if (_data == value)
				return;
			_data = value;
			const eventType:String = "dataChange";

			if (hasEventListener(eventType))
				dispatchEvent(new FlexEvent(eventType));
		}

		/**
		 * 获得当前渲染的 FrameLayerInfoEditable<br>
		 * 按照约定，_data 是 FrameLayerInfoEditable
		 * @return
		 *
		 */
		protected function get layerInfo():FrameLayerInfoEditable
		{
			return _data as FrameLayerInfoEditable;
		}

		//----------------------------------
		//  down
		//----------------------------------
		/**
		 *  @private
		 *  storage for the down property
		 */
		private var _down:Boolean = false;

		/**
		 *  @inheritDoc
		 *
		 *  @default false
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get down():Boolean
		{
			return _down;
		}

		/**
		 *  @private
		 */
		public function set down(value:Boolean):void
		{
			if (value == _down)
				return;
			_down = value;
			setCurrentState(getCurrentRendererState(), playTransitions);
		}

		//----------------------------------
		//  grid
		//----------------------------------
		/**
		 *  Returns the Grid associated with this item renderer.
		 *  This is the same value as <code>column.grid</code>.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get grid():Grid
		{
			return (column) ? column.grid : null;
		}

		//----------------------------------
		//  hovered
		//----------------------------------
		private var _hovered:Boolean = false;

		/**
		 *  @inheritDoc
		 *
		 *  @default false
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get hovered():Boolean
		{
			return _hovered;
		}

		/**
		 *  @private
		 */
		public function set hovered(value:Boolean):void
		{
			if (value == _hovered)
				return;
			_hovered = value;
			setCurrentState(getCurrentRendererState(), playTransitions);
		}

		//----------------------------------
		//  rowIndex
		//----------------------------------
		private var _rowIndex:int = -1;

		[Bindable("rowIndexChanged")]
		/**
		 *  @inheritDoc
		 *
		 *  <p>The Grid's <code>updateDisplayList()</code> method sets this property
		 *  before calling <code>prepare()</code></p>.
		 *
		 *  @default -1
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get rowIndex():int
		{
			return _rowIndex;
		}

		/**
		 *  @private
		 */
		public function set rowIndex(value:int):void
		{
			if (_rowIndex == value)
				return;
			_rowIndex = value;
			dispatchChangeEvent("rowIndexChanged");
		}

		//----------------------------------
		//  showsCaret
		//----------------------------------
		private var _showsCaret:Boolean = false;

		[Bindable("showsCaretChanged")]
		/**
		 *  @inheritDoc
		 *
		 *  <p>The Grid's <code>updateDisplayList()</code> method sets this property
		 *  before calling <code>preprare()</code></p>.
		 *
		 *  @default false
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}

		/**
		 *  @private
		 */
		public function set showsCaret(value:Boolean):void
		{
			if (_showsCaret == value)
				return;
			_showsCaret = value;
			setCurrentState(getCurrentRendererState(), playTransitions);
			dispatchChangeEvent("labelDisplayChanged");
		}

		//----------------------------------
		//  selected
		//----------------------------------
		private var _selected:Boolean = false;

		[Bindable("selectedChanged")]
		/**
		 *  @inheritDoc
		 *
		 *  <p>The Grid's <code>updateDisplayList()</code> method sets this property
		 *  before calling <code>preprare()</code></p>.
		 *
		 *  @default false
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get selected():Boolean
		{
			return _selected;
		}

		/**
		 *  @private
		 */
		public function set selected(value:Boolean):void
		{
			if (_selected == value)
				return;
			_selected = value;
			setCurrentState(getCurrentRendererState(), playTransitions);
			dispatchChangeEvent("selectedChanged");
		}

		//----------------------------------
		//  dragging
		//----------------------------------
		private var _dragging:Boolean = false;

		[Bindable("draggingChanged")]
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get dragging():Boolean
		{
			return _dragging;
		}

		/**
		 *  @private
		 */
		public function set dragging(value:Boolean):void
		{
			if (_dragging == value)
				return;
			_dragging = value;
			setCurrentState(getCurrentRendererState(), playTransitions);
			dispatchChangeEvent("draggingChanged");
		}

		//----------------------------------
		//  label
		//----------------------------------
		private var _label:String = "";

		[Bindable("labelChanged")]
		/**
		 *  @copy IGridItemRenderer#label
		 *
		 *  @default ""
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get label():String
		{
			return _label;
		}

		/**
		 *  @private
		 */
		public function set label(value:String):void
		{
			if (_label == value)
				return;
			_label = value;

			if (labelDisplay)
				labelDisplay.text = _label;
			dispatchChangeEvent("labelChanged");
		}

		//----------------------------------
		//  labelDisplay
		//----------------------------------
		private var _labelDisplay:TextBase = null;

		[Bindable("labelDisplayChanged")]
		/**
		 *  An optional visual component in the item renderer
		 *  for displaying the <code>label</code> property.
		 *  If you use this property to specify a visual component,
		 *  the component's <code>text</code> property is kept synchronized
		 *  with the item renderer's <code>label</code> property.
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get labelDisplay():TextBase
		{
			return _labelDisplay
		}

		/**
		 *  @private
		 */
		public function set labelDisplay(value:TextBase):void
		{
			if (_labelDisplay == value)
				return;
			_labelDisplay = value;
			dispatchChangeEvent("labelDisplayChanged");
		}

		//--------------------------------------------------------------------------
		//
		//  Methods - ItemRenderer State Support 
		//
		//--------------------------------------------------------------------------
		/**
		 *  Returns the name of the state to be applied to the renderer.
		 *  For example, a basic item renderer returns the String "normal", "hovered",
		 *  or "selected" to specify the renderer's state.
		 *  If dealing with touch interactions (or mouse interactions where selection
		 *  is ignored), "down" and "downAndSelected" can also be returned.
		 *
		 *  <p>A subclass of GridItemRenderer must override this method to return a value
		 *  if the behavior desired differs from the default behavior.</p>
		 *
		 *  <p>In Flex 4.0, the 3 main states were "normal", "hovered", and "selected".
		 *  In Flex 4.5, "down" and "downAndSelected" have been added.</p>
		 *
		 *  <p>The full set of states supported (in order of precedence) are:
		 *    <ul>
		 *      <li>dragging</li>
		 *      <li>downAndSelected</li>
		 *      <li>selectedAndShowsCaret</li>
		 *      <li>hoveredAndShowsCaret</li>
		 *      <li>normalAndShowsCaret</li>
		 *      <li>down</li>
		 *      <li>selected</li>
		 *      <li>hovered</li>
		 *      <li>normal</li>
		 *    </ul>
		 *  </p>
		 *
		 *  @return A String specifying the name of the state to apply to the renderer.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected function getCurrentRendererState():String
		{
			// this code is pretty confusing without multi-dimensional states, but it's
			// defined in order of precedence.
			if (dragging && hasState("dragging"))
				return "dragging";

			if (selected && down && hasState("downAndSelected"))
				return "downAndSelected";

			if (selected && showsCaret && hasState("selectedAndShowsCaret"))
				return "selectedAndShowsCaret";

			if (hovered && showsCaret && hasState("hoveredAndShowsCaret"))
				return "hoveredAndShowsCaret";

			if (showsCaret && hasState("normalAndShowsCaret"))
				return "normalAndShowsCaret";

			if (down && hasState("down"))
				return "down";

			if (selected && hasState("selected"))
				return "selected";

			if (hovered && hasState("hovered"))
				return "hovered";

			if (hasState("normal"))
				return "normal";
			// If none of the above states are defined in the item renderer,
			// we return null. This means the user-defined renderer
			// will display but essentially be non-interactive visually. 
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (setCurrentStateNeeded)
			{
				setCurrentState(getCurrentRendererState(), playTransitions);
				setCurrentStateNeeded = false;
			}
		}

		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(width, height);
			initializeRendererToolTip(this);
		}

		private var _isCurrentFrame:Boolean;

		/**
		 * 设置或获取当前 FrameCell 是否要标记为当前帧
		 */
		public function get isCurrentFrame():Boolean
		{
			return _isCurrentFrame;
		}

		/**
		 * @private
		 */
		public function set isCurrentFrame(value:Boolean):void
		{
			if (value != _isCurrentFrame)
			{
				_isCurrentFrame = value;
				invalidateDisplayList();
			}
		}

		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function prepare(hasBeenRecycled:Boolean):void
		{
			if (layerInfo)
			{
				info = layerInfo.getFrameInfoAt(columnIndex);
				return;
			}
			info = null;
		}

		private var _info:FrameInfoEditable;

		/**
		 * 设置或获取当前渲染的 FrameInfoEditable
		 * @return
		 *
		 */
		public function get info():FrameInfoEditable
		{
			return _info;
		}

		public function set info(value:FrameInfoEditable):void
		{
			if (_info)
			{
				_info.onIsKeyframeChange.remove(render);
				_info.onTextureChange.remove(render);
				_info.onBoxChange.remove(render);
				_info.onParticleConfigChange.remove(render);
			}
			_info = value;

			if (_info)
			{
				_info.onIsKeyframeChange.add(render);
				_info.onTextureChange.add(render);
				_info.onBoxChange.add(render);
				_info.onParticleConfigChange.add(render);
			}
			render();
		}

		/**
		 * 重绘 FrameInfo
		 *
		 */
		public function render():void
		{
			graphics.clear();
			var fillColor:uint = 0;
			const columnIndex:int = this.columnIndex;

			if (_info)
			{
				if (_info.keyframe.isEmpty)
				{
					fillColor = 0xcccccc;
				}
				else
				{
					fillColor = 0x999999;
				}
			}

			if (selected)
			{
				fillColor = 0x3399ff;
			}
			graphics.beginFill(fillColor, 1);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			drawBorders();

			if (_info)
			{
				if (_info.isKeyframe)
				{
					drawKeyframe(_info.isEmpty);
				}
				else if (_info && (_info.isTail || _info.next.isKeyframe)) // 是延长帧的最后一帧
				{
					drawEndframe();
				}
			}
		}

		/**
		 * 绘制延长帧最后一帧的小方块
		 *
		 */
		private function drawEndframe():void
		{
			const w:Number = 4;
			const h:Number = 8;
			graphics.lineStyle(1, 0, 1);
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect((width - w) / 2, height - h - 3, w, h);
			graphics.endFill();
		}

		/**
		 * 绘制关键帧小圆点
		 * @param isEmpty 是否是空关键帧
		 *
		 */
		protected function drawKeyframe(isEmpty:Boolean = false):void
		{
			const w:Number = width + 1;
			const h:Number = height;
			graphics.lineStyle(1, 0, 1);

			if (!isEmpty)
			{
				graphics.beginFill(0);
				graphics.drawCircle(w / 2, h - 2.25 - 3, 2.25);
			}
			else
			{
				graphics.drawCircle(w / 2, h - 2.5 - 3, 2.5);
			}
			graphics.endFill();
		}

		/**
		 * 绘制边线
		 *
		 */
		protected function drawBorders():void
		{
			if (_info)
			{
				// 是关键帧：绘制完整竖线
				if (_info.isKeyframe)
				{
					graphics.lineStyle(1, 0x333333, 1, true, LineScaleMode.NONE);
					graphics.moveTo(0, 0);
					graphics.lineTo(0, height);
				}
				else
				{
					// 不是关键帧：绘制中间断开的竖线
					const h:int = 2;
					graphics.lineStyle(1, _info.keyframe.isEmpty ? 0xeeeeee : 0xaaaaaa, 1, true, LineScaleMode.NONE);
					graphics.moveTo(0, 0);
					graphics.lineTo(0, h);
					graphics.moveTo(0, height - h);
					graphics.lineTo(0, height);
				}
			}
		}

		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function discard(willBeRecycled:Boolean):void
		{
			info = null;
		}
	}
}
