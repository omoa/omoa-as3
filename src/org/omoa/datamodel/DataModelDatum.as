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

	/**
	 * This class stores the DataModel value that can be found under
	 * a DataDescription; example: DataModelDatum.value = 30145, 
	 * DataModelDatum.description.toString()="GERMANY.FEMALE.1989.GDP".
	 * 
	 * @author Sebastian Specht 2009-2011
	 */

	public class DataModelDatum {

		public var value:* = NaN;
		
		public var array:Object = null;

		public var description:DataDescription = null;

		//public var valueDimension:ModelDimension = null;

		public function DataModelDatum() {
		}
		
		public function toString():String {
			return description.toString() + "=" + value;
		}

	} // end class
} // end package