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

package org.omoa.projection {
	
	import org.omoa.framework.IProjection;
	
	/**
	 * This class is a placeholder for a map projection system inside omoa; the projection system
	 * is not implemented yet, all SpaceModels of a map need to use the same projection.
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class AbstractProjection implements IProjection {

		public function AbstractProjection() {
		}

		public function getID():String {
			return "AbstractProjection";
		}

		public function getAlternativeIDs():Array {
			return null;
		}

		public function getParameters():Object {
			return null;
		}

		public function isIdentical(anotherProjection:IProjection):Boolean {
			return true;
		}

		public function isDynamic():Boolean {
			return false;
		}

	}
}