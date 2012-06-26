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
	
	/**
	 * Iterates over all possible values of a Description in the style of
	 * "GERMANY.*.POPULATION" (where * repsresents all values from this
	 * dimension, e.g. years of the time dimension.
	 * 
	 * @author Sebastian Specht
	 */
	public class SimpleDatumIterator extends AbstractIterator {
		
		private var _iterableDimensionOrder:Vector.<int>;
		private var _maxIndex:Vector.<int>;
		private var _index:Vector.<int>;
		private var _iterableCount:int;
		private var __index:int;
		private var __length:int;
		
		public function SimpleDatumIterator(description:Description) {
			super(description);
			
			_iterableDimensionOrder = new Vector.<int>();
			_maxIndex = new Vector.<int>();
			_index = new Vector.<int>();
			
			__length = 1;
			
			for (var order:int = 1; order <= description.selectedDimensionCount(); order++) {
				if (description.selectedIndex(order) == Description.WILDCARD_INDEX) {
					_iterableDimensionOrder.push(order);
					_maxIndex.push(description.selectedDimension(order).codeCount-2);
					_index.push(0);
					__length *= description.selectedDimension(order).codeCount - 1;
				}
			}
			
			_iterableCount = _iterableDimensionOrder.length;
			reset();
		}
		
		override public function next():Datum {
			var index:int = 0;
			var order:int = 0;
			var increment:int = 1;
			
			//TODO: Is there a way to optimize this by a "break"
			while (increment && order < _iterableCount) {
				if (_index[order] < _maxIndex[order]) {
					_index[order]++;
					increment = 0;
				} else {
					_index[order] = 0;
				}
				_datum.description.selectByIndex(_iterableDimensionOrder[order], 1+_index[order]);
				order++;
			}
			
			_dm.updateDatum(_datum);
			__index++;
			
			return _datum;
		}
		
		override public function count():int {
			return __length;
		}
		
		override public function reset():void {
			__index = 0;
			for (var i:int = 0; i < _iterableCount; i++ ) {
				_datum.description.selectByIndex(_iterableDimensionOrder[i], 1);
				_index[i] = 0;
			}
			_index[0] = -1;
		}
		
		override public function hasNext():Boolean {
			return __index < __length;
		}
		
	}

}