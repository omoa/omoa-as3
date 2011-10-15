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

package org.omoa.classification {
	
	import org.omoa.framework.Description;
	import org.omoa.framework.IStyle;
	import org.omoa.framework.ISymbolPropertyManipulator;
	import org.omoa.framework.SymbolPropertyType;

	/**
	 * A Value is the most simple and basic implementation of an 
	 * ISymbolPropertyManipulator - it simply wraps (and stores) a value of any given
	 * type.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class Value implements ISymbolPropertyManipulator {

		private var _value:*;


		public function Value(value:* = null) {
			_value = value;
		}

		public function get type():String {
			return SymbolPropertyType.VALUE;
		}

		public function get isDynamic():Boolean {
			return false;
		}

		public function get value():* {
			return _value;
		}
		
		public function set value(value:*):void {
			_value = value;
		}

		public function get style():IStyle {
			return null;
		}
		
		public function set style(style:IStyle):void {
		}

		public function get dataDescription():Description {
			return null;
		}

	}
}