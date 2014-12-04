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
	import org.omoa.framework.IClassification;
	import org.omoa.framework.IClassificationElement;
	import org.omoa.framework.IStyle;
	import org.omoa.framework.ISymbolPropertyManipulator;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * This Classification creates a simple linkage between an attribute of a SpaceModelEntity
	 * and a value.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class DictionaryClassification implements IClassification, ISymbolPropertyManipulator {
		
		private var _elements:Vector.<IClassificationElement> = new Vector.<IClassificationElement>();
		private var _selectedElement:IClassificationElement;
		private var _selectedElementBuffer:ClassificationElement;
		
		private var _label:String = "DictionaryClassification";
		private var _classificationDescription:String;
		
		private var _dict:Object;
		
		/**
		 * This Classification creates a simple linkage between an attribute of a SpaceModelEntity
		 * and a value. The data selector object follows the form: 
		 * {"<attribute key>":{"<attribute value>": <symbol value>, <attribute value>: <symbol value>}}
		 * 
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
				for (var key:String in _dict) {
					var attributeValue:* = spaceEntity.attributes[key];
					if (attributeValue!==null) {
						_selectedElement = _selectedElementBuffer;
						_selectedElement.manipulator.value = _dict[key][attributeValue];
					} else {
						_selectedElement = null;
					}
				}
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
			return null;
		}
		
	}
	
}