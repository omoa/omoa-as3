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

package org.omoa.datamodel {
	
	import flash.events.EventDispatcher;
	import org.omoa.framework.Datum;
	import org.omoa.framework.Description;
	import org.omoa.framework.ModelDimension;
	import org.omoa.framework.ModelDimensionType;
	
	/**
	* @author Sebastian Specht
	*/

	public class DataModel extends AbstractDataModel {

		protected var data:Vector.<Number>;
		
		private var inInitialization:Boolean = true;
		private var dimensionIndexOffset:Vector.<int>;
		private var countPDimensions:Number = 0;

		public function DataModel(id:String) {
			super(id);
		}

		override public function addDatum(datum:Datum):void {
			var i:int;
			var index:int;
			var valueIndex:int;
			if (inInitialization) {
				throw new Error( "No valueDimension given in the DataModel. You can't add a datum." );
			}
			if (datum.description.representsScalar) {
				for (i = 1; i <= countPDimensions; i++) {
					index += dimensionIndexOffset[i] * (datum.description.selectedIndex( i ) -1);
				}
				valueIndex = datum.description.selectedIndex( datum.description.valueDimensionOrder() )-1;
				if (valueIndex > -1) {
					data[index + dimensionIndexOffset[0] * valueIndex] = datum.value;
				} else {
					throw new Error( "You need to specify a ValueDimension together with the PropertyDimensions" );
				}
			} else {
				throw new Error( "Description does not represent a scalar value: " + datum.description );
			}
		}
		
		override public function getDatum(description:Description):Datum {
			var datum:Datum = new Datum();
			datum.description = description;
			if (description.representsScalar) {
				var index:int;
				var valueIndex:int = description.selectedIndex( description.valueDimensionOrder() ) -1;
				for (var i:int = 1; i <= countPDimensions; i++) {
					index += dimensionIndexOffset[i] * (description.selectedIndex( i ) -1);
				}
				//trace( description.selectedDimensionCount() + "/////" + valueIndex + "/////////////" + description.selectedIndex(description.valueDimensionOrder()));
				datum.description.valueIndex = index + dimensionIndexOffset[0] * valueIndex;
				datum.description.hasValueIndex = true;
				datum.value = data[datum.description.valueIndex];
			} else {
				datum.value = NaN;
			}
			return datum;
		}
		
		/**
		 * Updates a <code>Datum</code> with the data value according to the <code>Description</code>.
		 * This is the fastest way to request a data value, since it does not create any object.
		 * The description of the datum needs to point to a scalar value, otherwise the value property of
		 * the datum will be <code>NaN</code>.
		 * @param	datum	The Datum you want to be updated according to the description 
		 * 					property (Description).
		 */
		override public function updateDatum(datum:Datum):void {
			if (datum.description.hasValueIndex) {
				datum.value = data[datum.description.valueIndex];
			} else {
				if (datum.description.representsScalar) {
					var index:int;
					var valueIndex:int = datum.description.selectedIndex(datum.description.selectedDimensionCount()) - 1;
					if (valueIndex>-1) {
						for (var i:int = 1; i <= countPDimensions; i++) {
							index += dimensionIndexOffset[i] * (datum.description.selectedIndex( i ) -1);
						}
						datum.description.valueIndex = index + dimensionIndexOffset[0] * valueIndex;
						datum.description.hasValueIndex = true;
						datum.value = data[datum.description.valueIndex];
					} else {
						datum.value = NaN;
					}
				} else {
					datum.value = NaN;
				}
			}
		}

		override public function addPropertyDimension(propertyDimension:ModelDimension):void {
			if (inInitialization) {
				super.addPropertyDimension( propertyDimension );
				if (!(propertyDimension.type == ModelDimensionType.ENTITY_ID 
					|| propertyDimension.type == ModelDimensionType.NOMINAL
					|| propertyDimension.type == ModelDimensionType.ORDINAL))
				{
					throw new Error( "DataModel can not process this DimensionType as PropertyDimension" );
				}
			} else {
				throw new Error( "Model initialization finished. You can't add a PropertyDimensions after a ValueDimension." );
			}
		}

		override public function addValueDimension(valueDimension:ModelDimension):void {
			super.addValueDimension( valueDimension );
			
			var i:int;
			var index:int;
			if (inInitialization) {
				inInitialization = false;
				countPDimensions = propertyDimensions.length;
				
				dimensionIndexOffset = new Vector.<int>(countPDimensions);
				var j:int;
				var totalLength:int = 1;
				dimensionIndexOffset[countPDimensions] = 1;
				for (i = countPDimensions-1; i >= 0; i--) {
					dimensionIndexOffset[i] = dimensionIndexOffset[i + 1] * (propertyDimensions[i].codeCount-1);
				}
				totalLength = dimensionIndexOffset[0];
				trace( totalLength );
				data = new Vector.<Number>(totalLength);
			} else {
				data.length = valueDimensions.length * dimensionIndexOffset[0];
			}
		}
		
		override public function toString():String {
			var p:ModelDimension;
			var s:String = "|DataModel '"+id+"': " + propertyDimensions.length + " PropertyDimensions and " + valueDimensions.length + " ValueDimensions";
			s += "\n|---PropertyDimensions:";
			for each (p in propertyDimensions) {
				s += "\n|   " + p.classificationID + " " + p.title + " " + p.codeCount + " Ausprägungen: " + p.codes.slice(0,10);
			}
			s += "\n|---ValueDimensions:";
			for each (p in valueDimensions) {
				s += "\n|   " + p.classificationID + " " + p.title + " " + p.codeCount + " Ausprägungen";
			}
			s += "\n|     Offsets: " + dimensionIndexOffset + " // " + countPDimensions;
			if (data) {
				if (data.length > 10) {
					s += "\n|     Daten: " + data.slice( 0, 10);
				} else {
					s += "\n|     Daten: " + data;
				}
			}
			return s;
		}
		
		override public function clear():void 
		{
			data = new Vector.<Number>(data.length);
		}


	}
}