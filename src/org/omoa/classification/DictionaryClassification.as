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
	import org.omoa.framework.IClassificationElement;
	import org.omoa.framework.IStyle;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * This Classification ...
	 * 
	 * @author Sebastian Specht
	 */
	
	public class DictionaryClassification {
		
		private var _elements:Vector.<IClassificationElement> = new Vector.<IClassificationElement>();
		private var _selectedElement:IClassificationElement;
		private var _selectedElementBuffer:ClassificationElement;
		
		private var _label:String = "DictionaryClassification";
		private var _classificationDescription:String;
		
		private var _dict:Object;
		
		/**
		 * This Classification ....
		 * @param	dictionary
		 * The data selector object.
		 */
		public function DictionaryClassification( dictionary:Object )
		{
			_dict = dictionary;
			// TODO: _selectedElementBuffer ist unnnötig. wir können den
			// _elements Vector benutzen.
			_selectedElementBuffer = new ClassificationElement("DictionaryClassification", new Value(0));
			_selectedElement = null;
		}
		
		public function selectElement(value:*):IClassificationElement {
			if (!value) {
				_selectedElement = null;
			}
			var spaceEntity:SpaceModelEntity = value as SpaceModelEntity;
			if (spaceEntity) {
				for each (var key:String in _dict) {
					var attributeValue:* = spaceEntity.attributes[key];
					if (attributeValue) {
						_selectedElement = _selectedElementBuffer;
						_selectedElement.manipulator.value = _dict[key][attributeValue];
					} else {
						_selectedElement = null;
					}
				}
				/*
				var v:Number = parseFloat(value);
				var output:Number;
				if (v) {
					_selectedElement = _selectedElementBuffer;
					_selectedElement.manipulator.value = Math.sqrt(Math.abs(v) * _pre) * _post;
					if (v < 0) {
						_selectedElement.manipulator.value *= -1;
					}
				} else {
					_selectedElement = null;
				}
				*/
			} else {
				_selectedElement = null;
			}
			return _selectedElement;
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
			return "";
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
			return null;
		}
		
	}
	
}