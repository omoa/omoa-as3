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
	 * The types of geometry that exist inside omoa.
	 * 
	 * @author Sebastian Specht
	 */

	public final class GeometryType {

		public static const GEOMETRY_NONE:String = "none";

		public static const GEOMETRY_BOUNDS:String = "bounds";

		public static const GEOMETRY_POINT:String = "point";

		public static const GEOMETRY_LINE:String = "line";

		public static const GEOMETRY_AREA:String = "area";

	}
}