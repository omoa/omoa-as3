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
	 * This class represents one dimension of a DataModel, examples: "Time" {1999,2000,2001},
	 * "Sex" {male,female}, "Country" {UK,PL,FR}.
	 * 
	 * @see org.omoa.framework.ModelDimensionType
	 * 
	 * @author Sebastian Specht
	 */
	
	 // TODO This needs a serious rework in conjunction with the Description. UNDEFINED and WILDCARD need to be defined at a central place. Additionally,
	 // they should not be part of the Dimension Codes but instead be part of Description.
	 // TODO Introduce errors for ValueDimension that define codes and PropertyDimensions that do not define codes.
	 // TODO Enable ValueDimension to handle NOMINAL and ORDINAL data.
	public class ModelDimension {
		
		public static const UNDEFINED:String = "_";
		public static const UNDEFINED_INDEX:int = 0;
		
		private var _title:String;
		private var _unit:String;
		private var _id:String;
		private var _type:String;
		private var _description:String;
		private var _url:String;
		private var _isRemote:Boolean;
		private var _isValue:Boolean;
		private var _codes:Vector.<String>;
		private var _labels:Vector.<String>;
		
		private var codeIndex:Object;
		
		public function ModelDimension(	id:String,
										title:String,
										unit:String,
										type:String,
										codes:Array = null,
										labels:Array = null,
										isValueDimension:Boolean = false,
										description:String = "",
										url:String = "",
										isRemote:Boolean = false
										) {
			_id = id;
			_title = title;
			_unit = unit;
			_type = type;
			
			_codes = new Vector.<String>();
			_codes[0] = UNDEFINED;
			if (codes) {
				for each( var code:String in codes) {
					_codes.push( code );
				}
				
				codeIndex = { };
				if (type==ModelDimensionType.NOMINAL || type==ModelDimensionType.ORDINAL || ModelDimensionType.ENTITY_ID) {
					for ( var i:int = 0; i < _codes.length; i++) {
						codeIndex[_codes[i] as String] = i;
					}
				}
			}
			
			_labels = new Vector.<String>();
			if (labels) {
				_labels[0] = UNDEFINED;
				for each( var label:String in labels) {
					_labels.push( label );
				}
			} else {
				_labels = _codes.concat();
			}
			
			_isValue = isValueDimension;
			_description = description;
			_url = url;
			_isRemote = isRemote;
		}
		
		public function get codes():Vector.<String> {
			return _codes.concat();
		}
		
		public function get codeCount():int {
			return _codes.length;
		}
		
		public function indexOfCode( code:String ):int {
			return codeIndex[code];
		}
		
		public function code( index:int ):String {
			if (index > -1 && index < _codes.length) {
				return _codes[index];
			}
			return UNDEFINED;
		}

		public function get labels():Vector.<String> {
			return _labels.concat();
		}
		
		public function label( index:int ):String {
			if (index > -1 && index < _labels.length) {
				return _labels[index];
			}
			return UNDEFINED;
		}

		public function get type():String {
			return _type;
		}

		public function get classificationID():String {
			return _id;
		}

		public function get title():String {
			return _title;
		}

		public function get unit():String {
			return _unit;
		}

		public function get description():String {
			return _description;
		}

		public function get url():String {
			return _url;
		}

		public function get isValueDimension():Boolean {
			return _isValue;
		}

		public function get isRemote():Boolean {
			return _isRemote;
		}

	} 
} 