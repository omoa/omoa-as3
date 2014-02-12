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

package org.omoa.spacemodel {

	import flash.display.BitmapData;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsPath;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.ISpaceModel;
	
	import org.omoa.framework.Description;
	//import org.omoa.framework.IDataModel;

	/**
	 * Represents one spatial entity like a country, a road segment, a river sement, a city etc.
	 * 
	 * As part of a SpaceModel, it has a unique id and a name. The geometry
	 * is stored in the path property and/or in the center property. The import
	 * filter (loader) may store entity attributes in the attributes property.
	 * 
	 * You probably never create a SpaceModelEntity, the import filters create those
	 * during Model construction.
	 * 
	 * @author Sebastian Specht
	 */
	public class SpaceModelEntity {
		/**
		 * Unique ID of the entity.
		 */
		public var id:String;
		/**
		 * Name of the entity.
		 */
		public var name:String;
		/**
		 * The model, the entity originates from.
		 */
		public var model:ISpaceModel;

		/**
		 * BoundingBox of the geometry
		 */
		public var bounds:BoundingBox;
		/**
		 * A center point of the entity.
		 */
		public var center:Point;

		/**
		 * An associative array holding entitity attributes
		 * from the input file.
		 */
		public var attributes:Object;
		//public var attributes:IDataModel;

		/**
		 * The geometry data of the entity. May be null.
		 */
		public var path:IGraphicsPath;
		
		/**
		 * The raster data of the entity. May be null.
		 */
		public var bitmapData:BitmapData;
		
		private var _dataDescriptions:Object;

		public function SpaceModelEntity(dataDescriptions:Object=null) {
			if (dataDescriptions) {
				_dataDescriptions = dataDescriptions;
			}
		}
		
		/**
		 * Adds a linked Description to a DataModel. An entity can hold one
		 * Description per DataModel.
		 * 
		 * @param	dataDescription The Description created by a DataModel.
		 */
		public function addDescription( dataDescription:Description ):void {
			//_dataDescriptions[ dataDescription.model.id ] = null;
			if (dataDescription) {
				if (!_dataDescriptions) {
					_dataDescriptions = new Object();
				}
				_dataDescriptions[ dataDescription.model.id ] = dataDescription;
			}
		}
		
		/**
		 * Remove a linked Description.
		 * 
		 * @param	dataDescription
		 */
		public function removeDescription( dataDescription:Description ):void {
			if (_dataDescriptions && dataDescription && dataDescription.model) {
				_dataDescriptions[ dataDescription.model.id ] = null;
				delete _dataDescriptions[ dataDescription.model.id ];
			}
		}
		
		/**
		 * Returns a Description (DataModel link) for a given DataModel-ID.
		 * 
		 * @param	modelID The ID-String of the DataModel.
		 * @return  The Description or null.
		 */
		public function getDescription( modelID:String ):Description {
			if (_dataDescriptions) {
				return _dataDescriptions[modelID] as Description;
			}
			return null;
		}
		
		/**
		 * Returns a list of all linked DataModel-IDs.
		 * 
		 * @return An Array of DataModel-ID-Strings.
		 */
		public function getModelIDs():Array {
			var keys:Array = [];
			if (_dataDescriptions) {
				for (var key:String in _dataDescriptions) {
					keys.push( key );
				}
			}
			return keys;
		}
		
		public function toString():String {
			var out:String;
			out = name + " (" + id + ")\r";
			if (attributes) {
				for (var attributeName:String in attributes) {
					out += attributeName + "=" + attributes[attributeName] + "; ";
				}
			}
			out += "\rLinked DataModels: " + getModelIDs().join(", ");
			return out;
		}

	} 
} 