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

package org.omoa.datamodel.loader {
	
	import flash.events.Event;
	import org.omoa.datamodel.AbstractDMLoader;
	import org.omoa.datamodel.DataModel;
	import org.omoa.framework.Datum;
	import org.omoa.datamodel.GenericDataModel;
	import org.omoa.framework.ModelDimension;
	import org.omoa.framework.ModelDimensionType;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	
	public class SMEAttributeDataModel extends AbstractDMLoader {
		
		public function SMEAttributeDataModel(id:String=null, spaceModel:ISpaceModel=null, attributeKey:String=null) {
			super();
			if (id && spaceModel && attributeKey) {
				_id = id;
				initialize(spaceModel, attributeKey);
			}
		}
		
		override public function load(url:String, parameters:Object = null):void {
			initialise(parameters);
		}
		
		override public function initialise(data:*):void {
			if (data is Object) {
				if (data.spaceModel && data.attributeKey && data.spaceModel is ISpaceModel) {
					initialize( data.spaceModel as ISpaceModel, data.attributeKey );
					_isComplete = true;
					dispatchEvent( new Event( Event.COMPLETE ));
				}
			}
		}
		
		//TODO: implement for multiple value Dimension, not just one
		private function initialize(spaceModel:ISpaceModel, attributeKey:String ):void {
			var codes:Array = new Array();
			var attributes:Array = new Array();
			var numberCount:int = 0;
			var notNumberCount:int = 0;
			
			var iterator:ISpaceModelIterator = spaceModel.iterator();
			var sme:SpaceModelEntity;
			var n:Number;
			
			// we need to if we are dealing with numbers or strings
			while (iterator.hasNext()) {
				sme = iterator.next();
				codes.push(sme.id);
				attributes.push(sme.attributes[attributeKey]);
				n = parseFloat( sme.attributes[attributeKey] )
				//if (isNaN(n)) { // isNaN() is slow
				if (n!=n) {
					notNumberCount++;
				} else {
					numberCount++;
				}
			}
			
			// we need to decide which model implementation we use:
			// DataModel for numbers, GenericDataModel for strings
			var dimType:String;
			if (numberCount > notNumberCount) {
				dimType = ModelDimensionType.INTERVAL;
				model = new DataModel( _id );
			} else {
				dimType = ModelDimensionType.NOMINAL
				model = new GenericDataModel( _id );
			}
			
			// set Dimension
			var spaceDimension:ModelDimension = 
					new ModelDimension( spaceModel.id,
										spaceModel.id + " entities",
										"(ID)",
										ModelDimensionType.ENTITY_ID,
										codes );
			addPropertyDimension( spaceDimension );
			
			var attributeDimension:ModelDimension = 
					new ModelDimension( attributeKey, 
										spaceModel.id + "'s " + attributeKey,
										"",
										dimType,
										null, null, true );
			addValueDimension( attributeDimension );
			
			// store data
			var value:Datum = new Datum();
			value.description = createDescription();
			value.description.selectByCode( value.description.valueDimensionOrder(), attributeKey );
			
			for ( var i:int = 0; i < codes.length; i++) {
				value.description.selectByCode( 1, codes[i] );
				value.value = attributes[i];
				addDatum( value );
			}

			_isComplete = true;
		}
		
	}

}