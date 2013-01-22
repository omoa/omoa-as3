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
	import org.omoa.framework.IDataModel;
	import org.omoa.framework.IDataModelIterator;
	import org.omoa.framework.ModelDimension;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	
	public class AbstractDataModel extends EventDispatcher implements IDataModel {
		
		protected var _id:String = "";
		protected var _isRemote:Boolean = false;
		protected var _isComplete:Boolean = false;
		
		protected var propertyDimensions:Vector.<ModelDimension> = new Vector.<ModelDimension>;
		protected var valueDimensions:Vector.<ModelDimension> = new Vector.<ModelDimension>;
		
		public function AbstractDataModel(id:String) {
			_id = id;
		}
		
		public function addPropertyDimension(propertyDimension:ModelDimension):void {
			propertyDimensions.push( propertyDimension );
			if (propertyDimension.isRemote) {
				_isRemote = true;
			}
		}
		
		public function addValueDimension(valueDimension:ModelDimension):void {
			valueDimensions.push( valueDimension );
			if (valueDimension.isRemote) {
				_isRemote = true;
			}
		}
		
		public function createDescription( descriptionString:String = null ):Description {
			return new Description( this, propertyDimensions, valueDimensions, descriptionString );
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get isRemote():Boolean {
			return _isRemote;
		}
		
		public function get isComplete():Boolean {
			return _isComplete;
		}

		public function iterator(type:String):IDataModelIterator {
			return null;
		}

		public function propertyDimensionCount():int {
			return propertyDimensions.length;
		}

		public function propertyDimension(order:int):ModelDimension {
			if (order > 0 && order <= propertyDimensions.length) {
				return propertyDimensions[order-1];
			}
			return null;
		}

		public function valueDimensionCount():int {
			return valueDimensions.length;
		}

		public function valueDimension(index:int = 0):ModelDimension {
			if (index > -1 && index < valueDimensions.length) {
				return valueDimensions[index];
			}
			return null;
		}
		
		public function getDatum(description:Description):Datum {
			throw new Error( "getDatum() must be implemented in Subclass." );
		}
		
		public function updateDatum(datum:Datum):void {
			throw new Error( "updateDatum() must be implemented in Subclass." );
		}
		
		public function addDatum(datum:Datum):void {
			throw new Error( "addDatum() must be implemented in Subclass." );
		}
		
		override public function toString():String {
			throw new Error( "addDatum() must be implemented in Subclass." );
		}
	}
	
}