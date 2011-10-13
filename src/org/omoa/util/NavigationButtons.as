/*
This file is part of OMOA.

(C) Leibniz Institute for Regional Geography,
    Leipzig, Germany

OMOA is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OMOA is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with OMOA.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.omoa.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	[Event(name = NavigationButtons.EVENT_PLUS, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_MINUS, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_HOME, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_NORTH, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_EAST, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_SOUTH, type = "flash.events.Event")]
	[Event(name = NavigationButtons.EVENT_WEST, type = "flash.events.Event")]
	
	/**
	 * Displays the navigation buttons. 
	 * If you don't want to see this, set the visibility to false: 
	 * 
	 * <code>mapframe.navigation = false;</code>
	 * 
	 * @author Sebastian Specht
	 */
	
	public class NavigationButtons extends Sprite {
		
		public static const EVENT_PLUS:String = "plus";
		public static const EVENT_MINUS:String = "minus";
		public static const EVENT_HOME:String = "home";
		public static const EVENT_NORTH:String = "north";
		public static const EVENT_EAST:String = "east";
		public static const EVENT_SOUTH:String = "south";
		public static const EVENT_WEST:String = "west";
		
		[Embed(source='../../../../fdproject/button_plus.png')]
		private var plusClass:Class;
		
		[Embed(source='../../../../fdproject/button_minus.png')]
		private var minusClass:Class;
		
		[Embed(source='../../../../fdproject/button_punkt.png')]
		private var punktClass:Class;
		
		[Embed(source='../../../../fdproject/button_up.png')]
		private var pfeilClass:Class;
		
		private var plus:Button;
		private var minus:Button;
		private var punkt:Button;
		
		private var north:Button;
		private var east:Button;
		private var south:Button;
		private var west:Button;
		
		private var hideAfterFrame:int = 50;
		private var hideFrameCount:int = 0;
		private var fadeOutDecrement:Number = 0.03;
		
		public function NavigationButtons() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			plus = new Button(new plusClass());
			minus = new Button(new minusClass());
			punkt = new Button(new punktClass());
			
			north = new Button(new pfeilClass());
			east = new Button(new pfeilClass(),90);
			south = new Button(new pfeilClass(),180);
			west = new Button(new pfeilClass(),-90);
			
			
			addChild( punkt );
			addChild( plus );
			addChild( minus );
			
			addChild( north );
			addChild( east );
			addChild( south );
			addChild( west );
			
			punkt.addEventListener(MouseEvent.CLICK, click);
			plus.addEventListener(MouseEvent.CLICK, click);
			minus.addEventListener(MouseEvent.CLICK, click);
			east.addEventListener(MouseEvent.CLICK, click);
			south.addEventListener(MouseEvent.CLICK, click);
			west.addEventListener(MouseEvent.CLICK, click);
			north.addEventListener(MouseEvent.CLICK, click);
			
			
			addEventListener(MouseEvent.ROLL_OVER, over);
			addEventListener(MouseEvent.ROLL_OUT, out);
			addEventListener(MouseEvent.MOUSE_DOWN, down);
			addEventListener(MouseEvent.MOUSE_UP, up);
			
			alpha = 0.5;
			
			// layout
			
			var col1:Number = plus.width * 0.5;
			var col2:Number = col1 + west.width;
			var col3:Number = col2 + north.width;
			var col4:Number = col3 + east.width;
			
			var row1:Number = plus.width * 0.5;
			var row2:Number = row1 + plus.height;
			var row3:Number = row2 + east.height;
			
			plus.x = col1; plus.y = row1;
			minus.x = col1; minus.y = row3;
			
			punkt.x = col3; punkt.y = row2;
			
			
			north.x = col3; north.y = row1
			south.x = col3; south.y = row3;
			west.x = col2; west.y = row2;
			east.x = col4; east.y = row2;
		}
		
		private function out(e:MouseEvent):void {
			addEventListener(Event.ENTER_FRAME, hide);
			var d:DisplayObject;
			for (var i:int = 0; i < numChildren; i++) {
				d = getChildAt(i);
				d.scaleX = 1;
				d.scaleY = 1;
			}
		}
		
		private function over(e:MouseEvent):void {
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, hide);
			}
			alpha = 1;
		}
		
		private function up(e:MouseEvent):void {
			var d:DisplayObject;
			for (var i:int = 0; i < numChildren; i++) {
				if (getChildAt(i).hitTestPoint(e.stageX, e.stageY)) {
					d = getChildAt(i);
				}
			}
			if (d) {
				d.scaleX = 1;
				d.scaleY = 1;
			}
		}
		
		private function down(e:MouseEvent):void {
			var d:DisplayObject = e.relatedObject as DisplayObject;
			for (var i:int = 0; i < numChildren; i++) {
				if (getChildAt(i).hitTestPoint(e.stageX, e.stageY)) {
					d = getChildAt(i);
				}
			}
			if (d) {
				d.scaleX = 0.9;
				d.scaleY = 0.9;
			}
		}
		
		private function click(e:MouseEvent):void {
			var d:Button = e.currentTarget as Button;
			
			switch (d) {
				case plus: dispatchEvent( new Event( NavigationButtons.EVENT_PLUS ) );
					break;
				case minus: dispatchEvent( new Event( NavigationButtons.EVENT_MINUS ) );
					break;
				case punkt: dispatchEvent( new Event( NavigationButtons.EVENT_HOME ) );
					break;
				case north: dispatchEvent( new Event( NavigationButtons.EVENT_NORTH ) );
					break;
				case south: dispatchEvent( new Event( NavigationButtons.EVENT_SOUTH ) );
					break;
				case east: dispatchEvent( new Event( NavigationButtons.EVENT_EAST ) );
					break;
				case west: dispatchEvent( new Event( NavigationButtons.EVENT_WEST ) );
					break;
			}
			
			
		}
		
		public function hide(e:Event = null):void {
			if (alpha>0.5) {
				alpha -= fadeOutDecrement;
			} else {
				removeEventListener(Event.ENTER_FRAME, hide);
				alpha = 0.5;
			}
		}
		
	}

	
	
}
import flash.display.Bitmap;
import flash.display.Sprite;
class Button extends Sprite {
	public function Button(bitmap:Bitmap,rotation:Number=0) {
		addChild( bitmap );
		this.rotation = rotation;
		bitmap.x = 0 - bitmap.width * 0.5;
		bitmap.y = 0 - bitmap.height * 0.5;
	}
}