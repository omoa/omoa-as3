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

package org.omoa.spacemodel.loader {
	
	import flash.display.GraphicsPath;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.GeometryType;
	import org.omoa.spacemodel.*;
	import org.vanrijkom.dbf.*;
	import org.vanrijkom.shp.*;
	
	/**
	 * ...
	 * 
	 * @author Sebastian Specht
	 *
	 */
	
	public class Shapefile extends AbstractSMLoader {
		
		private var attributeFieldName:String = "";
		private var attributeFieldId:String = "";
		
		private var loaderShp:URLLoader;
		private var loaderDbf:URLLoader;
		
		private var shp:ByteArray;
		private var dbf:ByteArray;
		
		public function Shapefile() {
			super();
		}
		
		override public function load(url:String, parameters:Object = null):void {
			if (parameters) {
				if (parameters.id) {
					attributeFieldId = parameters.id;
				}
				if (parameters.name) {
					attributeFieldName = parameters.name;
				}
				if (parameters.modelID && !_id) {
					_id = parameters.modelID;
				}
			}
			
			loaderShp = new URLLoader();
			loaderShp.dataFormat = URLLoaderDataFormat.BINARY;
			loaderShp.addEventListener(Event.COMPLETE, shpComplete);
			loaderShp.addEventListener(IOErrorEvent.IO_ERROR, error);
			loaderDbf = new URLLoader();
			loaderDbf.dataFormat = URLLoaderDataFormat.BINARY;
			loaderDbf.addEventListener(Event.COMPLETE, dbfComplete);
			loaderDbf.addEventListener(IOErrorEvent.IO_ERROR, error);
			
			loaderShp.load(new URLRequest(url + ".shp"));
			loaderDbf.load(new URLRequest(url + ".dbf"));
		}
		
		private function error(e:IOErrorEvent):void {
			throw new Error(e.toString());
		}
		
		private function dbfComplete(e:Event):void {
			loaderDbf.removeEventListener(Event.COMPLETE, dbfComplete);
			loaderDbf.removeEventListener(IOErrorEvent.IO_ERROR, error );
			dbf = loaderDbf.data as ByteArray;
			if (shp) {
				initialise( null );
			}
			loaderDbf = null;
		}
		
		private function shpComplete(e:Event):void {
			loaderShp.removeEventListener(Event.COMPLETE, dbfComplete);
			loaderShp.removeEventListener(IOErrorEvent.IO_ERROR, error );
			shp = loaderShp.data as ByteArray;
			if (dbf) {
				initialise( null );
			}
			loaderShp = null;
		}
		
		override public function initialise(data:*):void {
			DbfHeader;
			var shpRaw:ByteArray
			var dbfRaw:ByteArray;
			var dbfHeader:DbfHeader;
			var shpHeader:ShpHeader
			
			if (data) {
				if (data is Array) {
					shpRaw = data[0] as ByteArray;
				} else if (data is Object) {
					shpRaw = data.shp as ByteArray;
				}
			} else {
				shpRaw = shp;
			}
			
			if (shpRaw) {
				shpHeader = new ShpHeader(shpRaw);
				var shpRecords:Array = ShpTools.readRecords(shpRaw);
				
				if (shpHeader.shapeType != ShpType.SHAPE_POINT
				&& shpHeader.shapeType != ShpType.SHAPE_POLYLINE
				&& shpHeader.shapeType != ShpType.SHAPE_POLYGON) {
					throw new Error( "Not able to handle a Shapefile of type " + shpHeader.shapeType );
				}
				
				if (data) {
					if (data is Array) {
						dbfRaw = data[1];
					} else if (data is Object) {
						dbfRaw = data.dbf;
					}
				} else {
					dbfRaw = dbf;
				}
				if (dbfRaw) {
					dbfHeader = new DbfHeader(dbfRaw);
				} else {
					trace("Keine dbf.")
				}
				
				var poly:ShpPolygon;
				var point:ShpPoint;
				var line:ShpPolyline;
				var center:Point;
				var bbox:BoundingBox;
				var sme:SpaceModelEntity;
				var path:GraphicsPath;
				var ringIndex:String;
				var first:Boolean;
				
				if (!_id) {
					_id = "sm"+Math.random();
				}
				// BUG in shpHeader: width = xmax und height = y-max
				_bounds = new BoundingBox( shpHeader.boundsXY.left, shpHeader.boundsXY.top,
											shpHeader.boundsXY.width, shpHeader.boundsXY.height );
				
				for each (var record:ShpRecord in shpRecords) {
					sme = new SpaceModelEntity();
					
					// store geometry-specific stuff
					switch (shpHeader.shapeType) {
						case ShpType.SHAPE_POLYGON:
							_type = GeometryType.GEOMETRY_AREA;
							poly = record.shape as ShpPolygon;
							bbox = new BoundingBox( poly.box.left, poly.box.top, poly.box.width, poly.box.height );
							//TODO: Use proper algorithm for center point
							center = bbox.topLeft.clone();
							center.offset( bbox.width * 0.5, bbox.height * 0.5);
							path = new GraphicsPath();
							for (ringIndex in poly.rings) {
								first = true;
								for each (point in poly.rings[ringIndex]) {
									if (first) {
										path.moveTo( point.x, point.y );
										first = false;
									} else {
										path.lineTo( point.x, point.y );
									}
								}
							}
						break;
						case ShpType.SHAPE_POINT:
							_type = GeometryType.GEOMETRY_POINT;
							point = record.shape as ShpPoint;
							center = new Point( point.x, point.y );
							bbox = new BoundingBox( point.x, point.y, point.x, point.y );
							path = null;
						break;
						case ShpType.SHAPE_POLYLINE:
							_type = GeometryType.GEOMETRY_LINE;
							line = record.shape as ShpPolyline;
							bbox = new BoundingBox( line.box.left, line.box.top, line.box.right, line.box.bottom );
							//TODO: Use proper algorithm for polygon center point
							center = bbox.topLeft;
							path = new GraphicsPath();
							for (ringIndex in line.rings) {
								first = true;
								for each (point in line.rings[ringIndex]) {
									if (first) {
										path.moveTo( point.x, point.y );
										first = false;
									} else {
										path.lineTo( point.x, point.y );
									}
								}
							}
						break;
					}
					sme.bounds = bbox;
					sme.center = center;
					sme.path = path;
					
					// store attributes from DBF, if any
					if (dbfHeader) {
						sme.attributes = new Object();
						var dbfRecord:DbfRecord = DbfTools.getRecord(dbfRaw, dbfHeader, record.number - 1);
						var value:String;
						for each (var field:DbfField in dbfHeader.fields) {
							value = dbfRecord.values[field.name];
							// trim whitespaces
							sme.attributes[field.name] = value.replace(/^\s+|\s+$/gs, '');
						}
						sme.id = sme.attributes[attributeFieldId];
						sme.name = sme.attributes[attributeFieldName];
					}
					
					// assign (required) id and name (in case it failed)
					if (!sme.id) {
						sme.id = "id" + record.number;
					}
					if (!sme.name) {
						sme.name = "entity" + record.number;
					}
					
					// store entity to SpaceModel
					addEntity(sme);
				}
			} else {
				trace( "No Raw data" );
			}
			
			_complete = true;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}

}