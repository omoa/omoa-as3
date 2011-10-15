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
		public var attributes:Object = new Object();
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
			} else {
				_dataDescriptions = new Object();
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
				_dataDescriptions[ dataDescription.model.id ] = dataDescription;
			}
		}
		
		/**
		 * Remove a linked Description.
		 * 
		 * @param	dataDescription
		 */
		public function removeDescription( dataDescription:Description ):void {
			if (dataDescription && dataDescription.model) {
				_dataDescriptions[ dataDescription.model.id ] = null;
			}
		}
		
		/**
		 * Returns a Description (DataModel link) for a given DataModel-ID.
		 * 
		 * @param	modelID The ID-String of the DataModel.
		 * @return  The Description or null.
		 */
		public function getDescription( modelID:String ):Description {
			return _dataDescriptions[modelID] as Description;
		}
		
		/**
		 * Returns a list of all linked DataModel-IDs.
		 * 
		 * @return An Array of DataModel-ID-Strings.
		 */
		public function getModelIDs():Array {
			var keys:Array = [];
			for (var key:String in _dataDescriptions) {
				keys.push( key );
			}
			return keys;
		}
		
		/**
		 * Dupliziert ein SME. Wird verschwinden.
		 */
		public function duplicateTransformed( matrix:Matrix ):SpaceModelEntity {
			//TODO: Das ist Mist
			var sme:SpaceModelEntity;
			if (matrix) {
				sme = new SpaceModelEntity( _dataDescriptions )
				sme.id = id;
				sme.name = name;
				sme.attributes = attributes;
				sme.center = matrix.transformPoint( center );
				sme.bounds = new BoundingBox(0,0,1,1);
				sme.bounds.topLeft = matrix.transformPoint( bounds.topLeft );
				sme.bounds.bottomRight = matrix.transformPoint( bounds.bottomRight );
				var gp:GraphicsPath = path as GraphicsPath;
				if (gp) {
					var v:Vector.<Number> = gp.data.slice(0, gp.data.length );// new Vector.<Number>( gp.data.length );
					var l:int = gp.data.length / 2;
					var p:Point = new Point();
					var index:int;
					for (var i:int = 0; i < l; i++) {
						index = i * 2;
						//p.x = gp.data[index];
						//p.y = gp.data[int(index + 1)];
						//p = matrix.transformPoint( p );
						v[index] = v[index] * matrix.a;
						v[int(index + 1)] = v[int(index + 1)] * matrix.d;
					}
					sme.path = new GraphicsPath( gp.commands, v, gp.winding );
				}
			}
			return sme;
		}
		
		public function toString():String {
			var out:String;
			out = name + " (" + id + ")\r";
			for (var attributeName:String in attributes) {
				out += attributeName + "=" + attributes[attributeName] + "; ";
			}
			out += "\rLinked DataModels: " + getModelIDs().join(", ");
			return out;
		}

	} 
} 