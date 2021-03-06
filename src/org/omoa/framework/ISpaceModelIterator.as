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
	
	import org.omoa.spacemodel.SpaceModelEntity;

	/**
	 * Implementations of this class iterate over the entities (or a subset of
	 * entities) of a ISpaceModel.
	 * 
	 * @see org.omoa.framework.ISpaceModel.
	 * 
	 * @author Sebastian Specht
	 */
	
	public interface ISpaceModelIterator {

		function next():SpaceModelEntity;
		function count():int;
		function reset():void;
		function hasNext():Boolean;
		function type():String;
		function iterator(type:String = null):ISpaceModelIterator;

	}
}