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
	
	import flash.utils.getQualifiedClassName;	
	import org.omoa.framework.ISpaceModelIterator;
	
	/**
	 * A non functional iterator implementation - no idea for what reason
	 * it was created by me.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class NullIterator implements ISpaceModelIterator {
		
		public function NullIterator() {
			
		}
		
		public function next():SpaceModelEntity	{
			return null;
		}
		
		public function count():int {
			return 0;
		}
		
		public function reset():void {
			
		}
		
		public function hasNext():Boolean {
			return false;
		}
		
		public function type():String {
			return getQualifiedClassName( this );
		}
		
		public function iterator(type:String = null):ISpaceModelIterator {
			return null;
		}
		
	}

}