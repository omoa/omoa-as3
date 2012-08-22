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

	/**
	 * This class stores the DataModel value that can be found under
	 * a Description; example: Datum.value = 30145, 
	 * Datum.description.toString()="GERMANY.FEMALE.1989.GDP".
	 * 
	 * @author Sebastian Specht
	 */

	public class Datum {

		public var value:* = NaN;
		
		public var array:Object = null;

		public var description:Description = null;

		//public var valueDimension:ModelDimension = null;

		public function Datum() {
		}
		
		public function toString():String {
			return description.toString() + "=" + value;
		}
		
		/**
		 * Updates the value property with the data from the model.
		 */
		public function update():void {
			if (description) {
				description.model.updateDatum(this);
			}
		}

	}
}