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
	
	import org.omoa.datamodel.Description;
	import org.omoa.framework.IClassificationElement;
	import org.omoa.framework.ISymbolPropertyManipulator;
	
	/**
	 * The BorderClassification fetches a value and finds the right class for that value
	 * within the specified borders.
	 * @author Sebastian Specht
	 */
	
	public class BorderClassification extends AbstractClassification {
		
		private var _selectedElementBuffer:ClassificationElement = new ClassificationElement("SquarerootClassification", new Value(0));
		public var noDataClass:ClassificationElement = null;
		
		/**
		 * Creates a new BorderClassification using the given class borders and the 
		 * ISymbolPropertyManipulators.
		 * 
		 * @param	dataDescription
		 * The relevant Description.
		 * @param	borders
		 * An array of numeric class border values.
		 * @param	values
		 * An array of numeric values or ISymbolPropertyManipulators serving as the class values.
		 * You need one entry more than entries in the <code>borders</code> array.
		 */
		public function BorderClassification( dataDescription:Description, borders:Array = null, values:Array = null) {
			super();
			if (borders.length != values.length - 1) {
				throw new Error( "You need (borders + 1) values in a BorderClassification" );
			}
			_description = dataDescription;
			if (borders && values) {
				for (var i:int = 0; i < values.length; i++ ) {
					var element:ClassificationElement;
					if (values[i] is Number || values[i] is String) {
						element = new ClassificationElement( values[i], new Value(values[i]) );
					} else if (values[i] is ISymbolPropertyManipulator) {
						element = new ClassificationElement( "Class " + i, values[i] as ISymbolPropertyManipulator );
					}
					if (i==0) {
						element.selector.min = null;
					} else {
						element.selector.min = Number(borders[i-1]);
					}
					if (i == borders.length) {
						element.selector.max = null;
					} else {
						element.selector.max = Number(borders[i]);
					}
					
					_elements.push( element );
					//trace ( "Element: >" + element.selector.min + " <=" + element.selector.max + "  ==>  " + element.label );
				}
			}
			_selectedElement = _selectedElementBuffer;
		}
		
		override public function selectElement(value:*):IClassificationElement {
			if (value != null) {
				for each (var element:ClassificationElement in _elements) {
					if (element.selector.min === null && value <= element.selector.max) {
						_selectedElement = element;
						return _selectedElement;
					} else if (element.selector.max === null && value > element.selector.min) {
						_selectedElement = element;
						return _selectedElement;
					} else if (value > element.selector.min && value <= element.selector.max) {
						_selectedElement = element;
						return _selectedElement;
					}
				}
			}
			
			if (noDataClass) {
				_selectedElement = noDataClass;
			} else {
				_selectedElement = _selectedElementBuffer;
			}
			return _selectedElement;
		}
		
	}
	
}