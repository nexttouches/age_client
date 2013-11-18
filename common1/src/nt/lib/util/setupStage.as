package nt.lib.util
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;

	public function setupStage(stage:Stage, frameRate:int = 60, color:uint = 0):void
	{
		stage.color = color;
		stage.tabChildren = false;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.quality = StageQuality.HIGH;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = frameRate;
	}
}
import flash.events.MouseEvent;

function killContextMenu(event:MouseEvent):void
{
}
