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

package org.omoa.spacemodel.iterator {
	import org.omoa.spacemodel.*;
	
	/**
	 * Compares an attribute of a SpaceModelEntity against a fixed value and
	 * iterates only over the entities where the compare evaluates to "true".
	 * 
	 * @see org.omoa.spacemodel.AttributeCompareIterator AttributeCompareIterator
	 * 
	 * @author Sebastian Specht
	 */
	
	public class AttributeFilterIterator extends AbstractIterator {
		
		public const EQUALS:int = 0;
		public const GREATER:int = 1;
		public const SMALLER:int = 2;
		
		private var originalEntities:Vector.<SpaceModelEntity>;
		private var _index:uint;
		private var _length:uint;
		
		public function AttributeFilterIterator( entities:Vector.<SpaceModelEntity> ) {
			super(entities);
			originalEntities = entities.slice( 0, entities.length);
			reset();
		}
		
		public function init( filterFunction:int, attributeKey:String, filterValue:* ):void {
			var sme:SpaceModelEntity;
			var filterValueFloat:Number;
			
			_entities.splice(0, _entities.length);
			
			if (filterFunction > EQUALS) {
				filterValueFloat = parseFloat( filterValue );
				for each (sme in originalEntities) {
					switch (filterFunction) {
						case GREATER:
							if (parseFloat(sme.attributes[attributeKey]) > filterValue) {
								_entities.push( sme );
							}
							break;
						case SMALLER:
							if (parseFloat(sme.attributes[attributeKey]) < filterValue) {
								_entities.push( sme );
							}
							break;
					}
				}
			} else {
				for each (sme in originalEntities) {
					if (sme.attributes[attributeKey] == filterValue) {
						_entities.push( sme );
					}
				}
			}
			
			reset();
		}
		
		override public function next():SpaceModelEntity {
			return _entities[ _index++ ];
		}
		
		override public function count():int {
			return _length;
		}
		
		override public function reset():void {
			_index = 0;
			_length = _entities.length;
		}
		
		override public function hasNext():Boolean {
			return _index < _length;
		}
		
	}

}