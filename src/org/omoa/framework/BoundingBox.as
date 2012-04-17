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

package org.omoa.framework {

	import flash.geom.Rectangle;
	
	/**
	 * This class is an extension of flash.geom.Rectangle and provides a
	 * min and max values for an rectangle [still thinking about turning back
	 * to the Rectangle class for the sake of memory].
	 * 
	 * @see flash.geom.Rectangle
	 * 
	 * @author Sebastian Specht
	 */

	public class BoundingBox extends Rectangle {

		private var _minx:Number;
		private var _maxx:Number;
		private var _miny:Number;
		private var _maxy:Number;


		public function BoundingBox(x1:Number, y1:Number, x2:Number, y2:Number) {
			_minx = Math.min( x1, x2 );
			_miny = Math.min( y1, y2 );
			_maxx = Math.max( x1, x2 );
			_maxy = Math.max( y1, y2 );
			super( _minx, _miny, _maxx - _minx, _maxy - _miny );
		}
		
		public function get minx():Number { return _minx; }
		
		public function get maxx():Number { return _maxx; }
		
		public function get miny():Number { return _miny; }
		
		public function get maxy():Number { return _maxy; }
		
		public function set minx(value:Number):void {
			x = _minx = value;
		}
		
		public function set miny(value:Number):void {
			y = _miny = value;
		}
		
		public function set maxx(value:Number):void {
			_maxx = value;
			width = _maxx - _minx;
		}
		
		public function set maxy(value:Number):void {
			_maxy = value;
			height = _maxy - _miny;
		}
		
		public function fromRectangle( rect:Rectangle ):void {
			x = _minx = rect.left;
			y = _miny = rect.top;
			height = rect.height;
			width = rect.width;
			_maxx = rect.right;
			_maxy = rect.bottom;
		}
		
		override public function toString():String {
			return "(x1=" + _minx + ", y1=" + _miny + ", x2=" + _maxx + ", y2=" + _maxy + ")";
		}

	}
}