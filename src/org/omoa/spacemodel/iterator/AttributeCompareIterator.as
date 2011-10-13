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
	 * Compares two attributes (from the attributes array) of a SpaceModelEntity and
	 * iterates only over the entities where the attributes match the comparison 
	 * (compare evaluates to "true").
	 * 
	 * If you want to compare an attribute against a fixed value use the AttributeFilterIterator.
	 * 
	 * @see org.omoa.spacemodel.AttributeFilterIterator AttributeFilterIterator
	 * 
	 * @author Sebastian Specht
	 */
	
	public class AttributeCompareIterator extends AbstractIterator {
		
		public const EQUALS:int = 0;
		public const GREATER:int = 1;
		public const SMALLER:int = 2;
		
		private var originalEntities:Vector.<SpaceModelEntity>;
		private var _index:uint;
		private var _length:uint;
		
		public function AttributeCompareIterator( entities:Vector.<SpaceModelEntity> ) {
			super(entities);
			originalEntities = entities.slice( 0, entities.length);
			reset();
		}
		
		/**
		 * Compares the value of firstAttributeKey against the value of secondAttributeKey using
		 * the compareFunction.
		 * 
		 * @param	firstAttributeKey	The attribute name of the first attribute.
		 * @param	compareFunction		The compare operator EQUALS, GREATER or SMALLER.
		 * @param	secondAttributeKey	The attribute name of the second attribute.
		 */
		public function init( firstAttributeKey:String, compareFunction:int, secondAttributeKey:String ):void {
			var sme:SpaceModelEntity;
			var firstValueFloat:Number;
			var secondValueFloat:Number;
			
			_entities.splice(0, _entities.length);
			
			for each (sme in originalEntities) {
				switch (compareFunction) {
					case GREATER:
						firstValueFloat = sme.attributes[firstAttributeKey];
						secondValueFloat = sme.attributes[secondAttributeKey];
						if (firstValueFloat>secondValueFloat) {
							_entities.push( sme );
						}
						break;
					case SMALLER:
						firstValueFloat = sme.attributes[firstAttributeKey];
						secondValueFloat = sme.attributes[secondAttributeKey];
						if (firstValueFloat<secondValueFloat) {
							_entities.push( sme );
						}
						break;
					case EQUALS:
						if (sme.attributes[firstAttributeKey] == sme.attributes[secondAttributeKey]) {
							_entities.push( sme );
						}
						break;
				}
			}
			
			reset();
		}
		
		override public function next():SpaceModelEntity {
			return _entities[ _index++ ];
		}
		
		override public function count():int	{
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