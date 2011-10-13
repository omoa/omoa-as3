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
	 * Iterates over all entities of the SpaceModel.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class SimpleIterator extends AbstractIterator {
		
		protected var _index:uint;
		protected var _length:uint;
		
		public function SimpleIterator( entities:Vector.<SpaceModelEntity> ) {
			super( entities );
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