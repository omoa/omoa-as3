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
	
	import org.omoa.framework.IClassificationElement;
	import org.omoa.framework.ISymbolPropertyManipulator;

	/**
	 * This class represents one class in an classification. 
	 * 
	 * @author Sebastian Specht
	 */
	
	public final class ClassificationElement implements IClassificationElement {

		private var _selector:Object;
		
		private var _label:String;
		private var _manipulator:ISymbolPropertyManipulator;

		public function ClassificationElement(label:String, manipulator:ISymbolPropertyManipulator, selectorObject:Object=null) {
			_label = label;
			_manipulator = manipulator;
			if (selectorObject) {
				_selector = selectorObject;
			} else {
				_selector = new Object();
			}
		}
		
		public function initialize(settings:Object):void {
			
		}
		
		public function get selector():Object {
			return _selector;
		}

		public function get label():String {
			return _label;
		}

		public function get manipulator():ISymbolPropertyManipulator {
			return _manipulator;
		}

	} 
} 