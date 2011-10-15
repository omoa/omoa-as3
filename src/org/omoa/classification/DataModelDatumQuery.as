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
	
	import org.omoa.datamodel.DataDescription;
	import org.omoa.datamodel.Datum;
	import org.omoa.framework.IClassificationElement;
	
	/**
	 * This class fetches a value from a DataModel and stores it in the selectedElement
	 * property. You can use it to get the "real" value from an DataModel, e.g. to display
	 * the value in text label.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class DatumQuery extends AbstractClassification {
		
		private var _selectedElementBuffer:ClassificationElement;
		
		public function DatumQuery( dataDescription:DataDescription=null) {
			super();
			_description = dataDescription;
			
			_selectedElementBuffer = new ClassificationElement("DatumQuery", new Value(0));
			_selectedElement = null;
		}
		
		override public function selectElement(value:*):IClassificationElement {
			if (!value) {
				_selectedElement = null;
			} else {
				var v:Number = parseFloat(value);
				if (v) {
					_selectedElement = _selectedElementBuffer;
					_selectedElement.manipulator.value = value;
				}
			}
			return _selectedElement;
		}
		
	}
	
}