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
	 * A classification fetches a value from a datamodel and transforms it into a
	 * a symbol property manipulator.
	 * 
	 * @author Sebastian Specht
	 */
	
	public interface IClassification {

		function initialize(settings:Object):Boolean;
		function label():String;
		function description():String;
		function addElement(element:IClassificationElement):void;
		function selectElement(value:*):IClassificationElement;
		function currentElement():IClassificationElement;
		function count():int;
		function element(index:int):IClassificationElement;
		function get dataDescription():Description;

	}
}