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
	
package org.omoa.framework {

	/**
	 * A Description stores a description of a value within a DataModel
	 * or a subset of a DataModel; example of a Description: "GERMANY.FEMALE.1989.GDP"
	 * (scalar value), "GERMANY.FEMALE.*.GDP" (one dimensional description)
	 * or "GERMANY.*.*.GDP" (two dimensional description). 
	 * 
	 * @author Sebastian Specht
	 */
	
	 // TODO This needs a serious rework in conjunction with the ModelDimension. UNDEFINED and WILDCARD need to be defined at a central place. Additionally,
	 // ModelDimension they should not be part of the Dimension Codes.
	public class Description {
		
		public static const UNDEFINED:String = "_";
		public static const UNDEFINED_INDEX:int = 0;
		public static const WILDCARD:String = "*";
		public static const WILDCARD_INDEX:int = -1;
		
		public static const SEPARATOR:String = ".";
		
		private var _propertyDimensions:Vector.<ModelDimension>;
		private var _valueDimensions:Vector.<ModelDimension>;
		private var _model:IDataModel;
		private var valueDimIdIndex:Object;
		private var selection:Vector.<int>;
		private var selectionLength:int;
		private var valueOrder:int;
		
		public var hasValueIndex:Boolean;
		public var valueIndex:int;

		public function Description(model:IDataModel, propertyDimensions:Vector.<ModelDimension>, valueDimensions:Vector.<ModelDimension>, descriptionString:String = null ) {
			_model = model;
			_propertyDimensions = propertyDimensions;
			_valueDimensions = valueDimensions;
			
			valueDimIdIndex = new Object();
			for (var i:int = 0; i < _valueDimensions.length; i++) {
				valueDimIdIndex[ _valueDimensions[i].classificationID ] = i + 1;
				//trace( "------" + _valueDimensions[i].classificationID + "------" + valueDimIdIndex[ _valueDimensions[i].classificationID ]);
			}
			valueOrder = _propertyDimensions.length + 1;
			selectionLength = valueOrder+1;
			
			selection = new Vector.<int>( selectionLength );
			
			hasValueIndex = false;
			valueIndex = 0;
			if (descriptionString) {
				fromString( descriptionString );
			}
		}
		
		public function get model():IDataModel {
			return _model;
		}
		
		
		/** Returns true, unless the selection contains UNDEFINED ("_") 
		 * or WILDCARD ("*") values.
		 */
		public function get representsScalar():Boolean {
			for (var i:int = 1; i < selectionLength; i++) {
				if (selection[i] < 1) {
					return false;
				}
			}
			return true;
		}
		
		
		/** Returns true, unless the selections contains an UNDEFINED value ("_").
		 * 
		 */
		public function get representsSomething():Boolean {
			for (var i:int = 1; i < selectionLength; i++) {
				if (selection[i] == 0) {
					return false;
				}
			}
			return true;
		}

		public function selectedDimensionCount():int {
			return selection.length-1;
		}
		
		public function valueDimensionOrder():int {
			return valueOrder;
		}

		public function selectByCode(order:int, code:String = UNDEFINED):Boolean {
			var hasCode:Boolean = true;
			if (order > 0 && order < valueOrder) {
				if (code == UNDEFINED) {
					selection[order] = UNDEFINED_INDEX;
				} else if (code == WILDCARD) {
					selection[order] = WILDCARD_INDEX;
				} else {
					var codeindex:int = _propertyDimensions[order - 1].indexOfCode( code );
					if (codeindex>0) {
						selection[order] = codeindex;
					} else {
						selection[order] = UNDEFINED_INDEX;
						hasCode = false;
					}
				}
			} else if (order == valueOrder) {
				if (code == UNDEFINED) {
					selection[valueOrder] = UNDEFINED_INDEX;
				} else if (code == WILDCARD) {
					selection[valueOrder] = WILDCARD_INDEX;
				} else {
					selection[valueOrder] = valueDimIdIndex[code];
					if (!selection[valueOrder]) {
						hasCode = false;
					}
				}
				
			}
			hasValueIndex = false;
			valueIndex = 0;
			return hasCode;
		}

		public function selectByIndex(order:int, codeIndex:int = UNDEFINED_INDEX):void {
			if (order > 0 && order < valueOrder) {
				if (_propertyDimensions[order-1].codeCount > codeIndex && codeIndex > 0) {
					selection[order] = codeIndex;
				} else if (codeIndex == WILDCARD_INDEX) {
					selection[order] = WILDCARD_INDEX;
				} else {
					selection[order] = UNDEFINED_INDEX;
				}
			} else if (order == valueOrder) {
				selection[valueOrder] = codeIndex;
			}
			hasValueIndex = false;
			valueIndex = 0;
		}

		public function selectedDimension(order:int):ModelDimension {
			if (order > 0 && order < valueOrder) {
				return _propertyDimensions[order-1];
			} else if (order == valueOrder) {
				return _valueDimensions[ selection[ valueOrder ]-1 ];
			}
			return null;
		}

		public function selectedCode(order:int):String {
			if (order > 0 && order < valueOrder) {
				return _propertyDimensions[order-1].code( selection[order]);
			} else if (order == valueOrder) {
				return _valueDimensions[ selection[ valueOrder ]-1 ].classificationID;
			}
			return "";
		}

		public function selectedIndex(order:int):int {
			if (order > 0 && order < valueOrder) {
				return selection[order];
			} else if (order == valueOrder) {
				return selection[ valueOrder ];
			}
			return 0;
		}
		
		public function combine( target:Description, gapFiller:Description):void {
			var order:int;
			var thisIndex:int;
			var fillIndex:int;
			if (_model == gapFiller.model) {
				for (order = 1; order < valueOrder; order++) {
					thisIndex = selectedIndex(order);
					if (thisIndex == UNDEFINED_INDEX || thisIndex == WILDCARD_INDEX) {
						fillIndex = gapFiller.selectedIndex(order);
						if (fillIndex != WILDCARD_INDEX) {
						// TODO	
						}
						target.selectByIndex( order, fillIndex );
						//trace( this + " /// " + gapFiller + " /// " + target );
					} else {
						target.selectByIndex( order, thisIndex );
					}
				}
			} else {
				trace("The models don't fit");
			}
			target.hasValueIndex = false;
			target.valueIndex = 0;
		}

		public function toString():String {
			var codes:Array = new Array();
			for (var i:int = 1; i < valueOrder; i++) {
				if (selection[i] === UNDEFINED_INDEX) {
					codes.push( UNDEFINED );
				} else if (selection[i] === WILDCARD_INDEX) {
					codes.push( WILDCARD );
				} else {
					codes[i-1] = _propertyDimensions[i-1].code( selection[i] );
				}
			}
			if (selection[valueOrder] === UNDEFINED_INDEX) {
				codes.push( UNDEFINED );
			} else if (selection[valueOrder] === WILDCARD_INDEX) {
				codes.push( WILDCARD );
			} else {
				codes.push( _valueDimensions[selection[valueOrder]-1].classificationID );
			}
			return codes.join(SEPARATOR);
		}

		public function fromString(descriptionString:String):void {
			var codes:Array = descriptionString.split(SEPARATOR);
			for ( var i:int = 0; i < codes.length; i++) {
				selectByCode( i + 1, codes[i] );
			}
			hasValueIndex = false;
			valueIndex = 0;
		}

	} 
} 