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

package org.omoa.datamodel.iterator {
	import org.omoa.datamodel.AbstractIterator;
	import org.omoa.framework.Datum;
	import org.omoa.framework.Description;
	import org.omoa.framework.ModelDimension;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	public class SimpleIterator extends AbstractIterator 
	{
		private var _iterableDimensions:Vector.<ModelDimension>;
		private var _iterableDimensionOrder:Vector.<int>;
		private var _length:Vector.<int>;
		private var _index:Vector.<int>;
		private var _iterableCount:int;
		
		public function SimpleIterator(description:Description) {
			super(description);
			//_iterableDimensions = new Vector.<ModelDimension>();
			
			_iterableDimensionOrder = new Vector.<int>();
			_length = new Vector.<int>();
			_index = new Vector.<int>();
			
			for (var order:int = 1; order <= description.selectedDimensionCount(); order++) {
				if (description.selectedIndex(order) == Description.WILDCARD_INDEX) {
					//_iterableDimensions.push( description.selectedDimension(order));
					_iterableDimensionOrder.push(order);
					_length.push(description.selectedDimension(order).codeCount);
					_index.push(1);
				}
			}
			_iterableCount = _iterableDimensionOrder.length;
		}
		
		override public function next():Datum {
			for (var i:int = 0; i < _iterableCount; i++ ) {
				if (_index[i] < _length[i]) {
					_datum.description.selectByIndex(_iterableDimensionOrder[i], _index[i]++);
					_dm.updateDatum(_datum);
					return _datum;
				}
			}
			return _datum;
		}
		
		override public function count():int {
			var count:int = 1;
			for each (var length:int in _length) {
				count *= (length-1);
			}
			return count;
		}
		
		override public function reset():void {
			for (var i:int = 0; i < _iterableCount; i++) {
				_index[i] = 1;
			}
		}
		
		override public function hasNext():Boolean {
			for (var i:int = 0; i < _iterableCount; i++ ) {
				if (_index[i] < _length[i]) {
					return true;
				}
			}
			return false;
		}
		
	}

}