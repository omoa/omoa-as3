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
	 * This class holds the constants that describe the nature of the statistical data
	 * the dimension is representing.
	 * 
	 * @author Sebastian Specht
	 */
	
	public final class ModelDimensionType {

		/**
		 * The dimension describes nominal data like labels or names.
		 * Examples for nominal data are:
		 * 
		 * - red, green, blue, yellow
		 * 
		 * - Newton, Heisenberg, Einstein
		 */
		public static const NOMINAL:String = "nominal";

		/**
		 * The dimension describes ordinal data.
		 * Examples for ordinal data are:
		 * 
		 * - S, M, L, XL, XXL
		 * 
		 * - 1st, 2nd, 3rd, 4th
		 */
		public static const ORDINAL:String = "ordinal";

		/**
		 * The dimension describes data with an interval scale. Examples are 
		 * 
		 */
		public static const INTERVAL:String = "interval";

		/**
		 * The dimension describes data with an ratio scale. Examples are 
		 * 
		 */
		public static const RATIO:String = "ratio";

		/**
		 * The dimension describes the codes of geographic entities.
		 * This is a nominal scale, but it is treated specially by the system.
		 * The classification-ID of the ModelDimension should be the same as
		 * of the SpaceModel, the codes are refering to.
		 * 
		 */
		public static const ENTITY_ID:String = "id";

	} // end class
} // end package