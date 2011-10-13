package org.omoa.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	/**
	 * Displays the omoa logo at the bottom of a map frame.
	 * If you don't want to see this, set the visibility to false: 
	 * 
	 * <code>mapframe.logo = false;</code>
	 * 
	 * It will fade out after a while.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class OmoaLogo extends Sprite {
		
		[Embed(source='../../../../fdproject/logo_43x24_sw.png')]
		private var logoSWClass:Class;
		
		[Embed(source = '../../../../fdproject/logo_43x24.png')]
		private var logoClass:Class;
		private var logoSW:Bitmap;
		private var logo:Bitmap;
		
		private var hideAfterFrame:int = 50;
		private var hideFrameCount:int = 0;
		private var fadeOutDecrement:Number = 0.03;
		
		public function OmoaLogo() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			logoSW = new logoSWClass();
			logo = new logoClass();
			
			logo.visible = false;
			
			addChild( logoSW );
			addChild( logo );
			
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(MouseEvent.ROLL_OVER, over);
			addEventListener(MouseEvent.ROLL_OUT, out);
		}
		
		private function out(e:MouseEvent):void {
			logo.visible = false;
			logoSW.visible = true;
			if (hideFrameCount == 0) {
				visible = false;
			}
		}
		
		private function over(e:MouseEvent):void {
			logo.visible = true;
			logoSW.visible = false;
		}
		
		private function click(e:MouseEvent):void {
			var url:URLRequest = new URLRequest("http://www.omoa-project.org");
			navigateToURL(url, "_blank"); 
			visible = false;
		}
		
		override public function get visible():Boolean { return super.visible; }
		
		override public function set visible(value:Boolean):void {
			if (value) {
				super.visible = visible;
			} else {
				hideFrameCount = 0;
				addEventListener(Event.ENTER_FRAME, hide);
			}
			
		}
		
		public function hide(e:Event = null):void {
			if (hideFrameCount < hideAfterFrame) {
				hideFrameCount++;
			} else {
				if (alpha>0) {
					alpha -= fadeOutDecrement;
				} else {
					removeEventListener(Event.ENTER_FRAME, hide);
					super.visible = false;
					alpha = 1;
				}
			}
		}
		
	}

}