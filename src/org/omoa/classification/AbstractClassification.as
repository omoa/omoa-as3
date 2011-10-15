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
	import org.omoa.framework.*;

	/**
	 * Abstract implementation of the classification interface. A classification has
	 * <code>n</code> clasification elements. Specific implementations
	 * need to override the selectElement method and need to set the _selectedElement
	 * property.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class AbstractClassification implements IClassification, ISymbolPropertyManipulator {

		protected var _elements:Vector.<IClassificationElement> = new Vector.<IClassificationElement>();
		protected var _selectedElement:IClassificationElement;
		protected var _description:Description;
		
		protected var _label:String = "AbstractClassification";
		protected var _classificationDescription:String;

		public function AbstractClassification() {
		}

		public function initialize(settings:Object):Boolean {
			return false;
		}

		public function label():String {
			if (_selectedElement) {
				return _selectedElement.label;
			}
			return _label;
		}

		public function description():String {
			return _classificationDescription;
		}

		public function selectElement(value:*):IClassificationElement {
			throw new Error( "Classification.selectElement() "
				+"must be implemented in AbstractClassification Subclass" );
			return null;
		}

		public function currentElement():IClassificationElement {
			return _selectedElement;
		}

		public function count():int {
			return _elements.length;
		}

		public function element(index:int):IClassificationElement {
			if (index < _elements.length) {
				return _elements[index];
			}
			return null;
		}
		
		public function addElement(element:IClassificationElement):void {
			_elements.push( element );
		}

		public function get type():String {
			if (_selectedElement) {
				return _selectedElement.manipulator.type;
			}
			return "";
		}

		public function get isDynamic():Boolean {
			return true;
		}

		public function get value():* {
			if (_selectedElement) {
				return _selectedElement.manipulator.value;
			}
			return null;
		}
		
		public function set value( value:*):void {
			
		}

		public function get style():IStyle {
			if (_selectedElement) {
				return _selectedElement.manipulator.style;
			}
			return null;
		}
		
		public function set style(style:IStyle):void {}

		public function get dataDescription():Description {
			//if (_selectedElement) {
			//	return _selectedElement.manipulator.dataDescription;
			//}
			return _description;
		}

	}
}