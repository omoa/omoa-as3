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

package org.omoa.event {

	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * A SymbolEvent is emitted by a SymbolLayer (?) when an interactive map object
	 * is clicked.
	 * 
	 * @author Sebastian Specht
	 * 
	 */
	
	public class SymbolEvent extends MouseEvent {
		
		public static const CLICK:String = "symbol_click";
		public static const POINT:String = "symbol_point";
		
		/**
		 * The related spatial entity of the Event.
		 */
		public var entity:SpaceModelEntity;
		
		public function SymbolEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = 0, localY:Number = 0, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0) {
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
		}
		
		override public function clone():Event{
            var c:SymbolEvent = new SymbolEvent(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
            c.entity = this.entity;
            return c;
        }
		
		override public function toString():String {
			var s:String = '[SymbolEvent ';
			if (entity) {
				s += 'entity="' + entity.name +" ("+entity.id+')" ';
			}
			return   s + super.toString() + ']';
		}
		
	}

}