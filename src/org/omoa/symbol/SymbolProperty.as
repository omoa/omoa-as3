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

package org.omoa.symbol {
	
	import org.omoa.datamodel.DataModelDatum;
	import org.omoa.framework.ISymbolPropertyManipulator;

	/**
	* @author Sebastian Specht
	*/
	
	public final class SymbolProperty {

		public var name:String;
		public var description:String;
		public var type:String;
		public var manipulator:ISymbolPropertyManipulator;
		public var datum:DataModelDatum;

		public function SymbolProperty() {
		}

	}
}