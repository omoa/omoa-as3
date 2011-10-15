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
	 * Implementations of this interface are able to change
	 * the properties of a symbol and store a value or a style; value or style may
	 * be static or may change dynamically.
	 * 
	 * @author Sebastian Specht
	 */

	public interface ISymbolPropertyManipulator {

		function get type():String;
		function get isDynamic():Boolean;
		
		function get value():*;
		function set value(value:*):void;
		
		function get style():IStyle;
		function set style(style:IStyle):void;
		
		function get dataDescription():Description;

	}
}