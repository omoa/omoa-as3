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

package org.omoa.spacemodel {
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import org.omoa.spacemodel.iterator.SimpleIterator;
	
	import org.omoa.framework.ISpaceModelIterator;
	
	/**
	 * This class implements a factory functionality for all ISpaceModelIterator
	 * allowing descendents of AbstractIterator to be chained by something like:
	 * 
	 * <p><code> followingIterator = anIterator.iterator( "Class Name of following iterator" );
	 * </code></p>
	 * 
	 * @author Sebastian Specht
	 */
	
	public class AbstractIterator implements ISpaceModelIterator {
		
		protected var _entities:Vector.<SpaceModelEntity>;
		
		public function AbstractIterator( entities:Vector.<SpaceModelEntity> = null) {
			_entities = entities;
		}
		
		public function next():SpaceModelEntity {
			throw new Error( "AbstractIterator.next() has no implementation.");
		}
		
		public function count():int {
			throw new Error( "AbstractIterator.count() has no implementation.");
		}
		
		public function reset():void {
			throw new Error( "AbstractIterator.reset() has no implementation.");
		}
		
		public function hasNext():Boolean {
			throw new Error( "AbstractIterator.hasNext() has no implementation.");
		}
		
		public function type():String {
			return getQualifiedClassName( this );
		}
		
		/**
		 * Creates a new ISpaceModelIterator of the given type.
		 * @param	type Type of the iterator (optional). Leave empty for 
		 * 			a SimpleIterator or give the class name for an iterator from this
		 * 			package or give the full (package + classname) name for your own
		 * 			implementation.
		 * @return  An iterator of the given type, a SimpleIterator or a NullIterator.
		 */
		public function iterator(type:String = null):ISpaceModelIterator {
			if (!type) {
				return new SimpleIterator( _entities.slice(0, _entities.length) );
			}
			try {
				var iteratorClass:Class = getDefinitionByName( "org.omoa.spacemodel.iterator." + type ) as Class;				
			} catch (e:ReferenceError) {
				try {
					iteratorClass = getDefinitionByName( type ) as Class;
				} catch (e:ReferenceError) {
					// Nothing we can do
				}
			}
			if (iteratorClass) {
				return new iteratorClass( _entities.slice(0, _entities.length) );
			}
			return new NullIterator();
		}
		
	}

}