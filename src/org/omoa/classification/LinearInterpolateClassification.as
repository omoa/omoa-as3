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
	
	/**
	 * This class fetches a value from a DataModel and stores the interpolated
	 * result value in the selectedElement property.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class LinearInterpolateClassification extends AbstractClassification {
		private var _min:Number;
		private var _max:Number;
		private var _minClass:Number;
		private var _maxClass:Number;
		
		private var _factor:Number;
		
		private var _selectedElementBuffer:ClassificationElement;
		
		public function LinearInterpolateClassification( minValue:Number, minClassValue:Number, maxValue:Number, maxClassValue:Number, dataDescription:Description=null) {
			super();
			_min = minValue;
			_max = maxValue;
			_minClass = minClassValue;
			_maxClass = maxClassValue;
			
			_description = dataDescription;
			
			_factor = (_maxClass - _minClass) / (_max - _min);
			
			_selectedElementBuffer = new ClassificationElement("LinearInterpolation", new Value(0));
			_selectedElement = null;
		}
		
		override public function selectElement(value:*):IClassificationElement {
			if (!value) {
				_selectedElement = null;
			} else {
				var v:Number = parseFloat(value);
				if (v) {
					_selectedElement = _selectedElementBuffer;
					if (v <= _min) {
						_selectedElement.manipulator.value = _minClass;
					} else if (v >= _max) {
						_selectedElement.manipulator.value = _maxClass;
					} else {
						_selectedElement.manipulator.value = _minClass + ((v - _min) * _factor);
					}
				}
			}
			return _selectedElement;
		}
		
	}
	
}