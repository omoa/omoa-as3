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
	
	/**
	 * This Classification fetches a numerical value from a DataModel 
	 * multiplies this value by <code>preFactor</code>, calculates the
	 * squareroot, multiplies it by <code>postFactor</code> and
	 * stores the result in the value property of the selected element.
	 * 
	 * If the fetched value is not numerical, the selected element is set
	 * <code>null</code>.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class SquarerootClassification extends AbstractClassification {
		
		private var _pre:Number;
		private var _post:Number;
		
		private var _selectedElementBuffer:ClassificationElement;
		
		/**
		 * This Classification fetches a numerical value from a DataModel 
		 * multiplies this value by <code>preFactor</code>, calculates the
		 * squareroot, multiplies it by <code>postFactor</code> and
		 * stores the result in the value property of the selected element.
		 * 
		 * @param	preFactor
		 * The fetched value is multiplied by this factor
		 * before the the squareroot is calculated.
		 * @param	postFactor
		 * The fetched value is multiplied by this factor
		 * after the the squareroot is calculated.
		 * @param	dataDescription
		 * The data selector object.
		 */
		public function SquarerootClassification( preFactor:Number = 1,
												  postFactor:Number = 1, 
												  dataDescription:Description = null)
		{
			super()
			_description = dataDescription;
			_pre = preFactor;
			_post = postFactor;
			// TODO: _selectedElementBuffer ist unnnötig. wir können den
			// _elements Vector benutzen.
			_selectedElementBuffer = new ClassificationElement("SquarerootClassification", new Value(0));
			_selectedElement = null;
		}
		
		override public function selectElement(value:*):IClassificationElement {
			if (!value) {
				_selectedElement = null;
			} else {
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
			}
			return _selectedElement;
		}
		
	}
	
}