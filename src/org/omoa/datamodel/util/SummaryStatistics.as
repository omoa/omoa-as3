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

package org.omoa.datamodel.util 
{
	import org.omoa.framework.IDataModelIterator;
	
	/**
	 * Simple statistics on DataModels.
	 * 
	 * @author Sebastian Specht
	 */
	public class SummaryStatistics 
	{
		
		public function SummaryStatistics() {
			
		}
		
		/**
		 * Calculates the sum. Naive implementation - will fail on everything but numbers.
		 * @param	i	An IDataModelIterator instance.
		 * @return	The sum.
		 */
		public static function sum(i:IDataModelIterator):Number {
			var sum:Number = 0;
			i.reset();
			while (i.hasNext()) {
				sum += i.next().value;
			}
			return sum;
		}
		
		/**
		 * Calculates the mean value. Naive implementation - will fail on everything but numbers.
		 * @param	i	An IDataModelIterator instance.
		 * @return	The statistical mean.
		 */
		public static function mean(i:IDataModelIterator):Number {
			if (i.count() > 0) {
				return sum(i) / i.count();
			}
			return NaN;
		}
		
		
		public static function minimum(i:IDataModelIterator):Number {
			
			i.reset();
			var min:Number = i.next().value;
			while (i.hasNext()) {
				var wert:Number = i.next().value;
				if (wert < min) {
					min = wert;
				}
			}
			return min;
		}
		
	}

}