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

package org.omoa.datamodel {
	import flash.utils.getQualifiedClassName;
	import org.omoa.framework.Datum;
	import org.omoa.framework.Description;
	import org.omoa.framework.IDataModel;
	import org.omoa.framework.IDataModelIterator;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	public class AbstractIterator implements IDataModelIterator 
	{
		protected var _dm:IDataModel;
		protected var _datum:Datum;
		protected var _description:Description;
		
		public function AbstractIterator(description:Description) {
			if (!description.representsSomething) {
				throw new Error("This description does not represent a value or a list of values: " + description.toString() );
			}
			_dm = description.model;
			_datum = _dm.getDatum( _dm.createDescription( description.toString() ) );
			_description = description;
		}
		
		public function next():Datum {
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
		
	}

}