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
	import flash.net.URLRequest;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.GeometryType;
	import org.omoa.spacemodel.*;
	
	/**
	 * ...
	 * 
	 * @author Sebastian Specht
	 *
	 */
	
	public class AsmaSpaceXml extends AbstractSMLoader {
		private var xml:XML;
		private var loader:URLLoader
		
		private var _parameters:Object;
		
		public function AsmaSpaceXml() {
			super();
		}
		
		override public function load( url:String, parameters:Object = null ):void {
			_parameters = parameters;
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete );
			loader.addEventListener(IOErrorEvent.IO_ERROR, error );
			loader.load( new URLRequest(url) );
		}
		
		private function loadComplete( e:Event ):void {
			if (loader) {
				//trace( "Load complete");
				initialize( loader.data );
				loader.removeEventListener(Event.COMPLETE, loadComplete );
				loader.removeEventListener(IOErrorEvent.IO_ERROR, error );
				loader = null;
			}
		}
		
		private function error(e:Event):void {
			trace( "Load error");
			trace ( e );
		}
		
		override public function initialize( data:* ):void {
			var xml:XML;
			if (data is XML) {
				xml = data as XML;
			} else {
				xml = new XML(data);
			}
			
			if (xml) {
				
				// an ID may already be assigned
				if (!_id) {
					_id = xml.@id;
				}
					
				switch (xml.@type.toString().toLowerCase()) {
					case "2":
					case "area":
					case "poly": _type = GeometryType.GEOMETRY_AREA;
						break;
					case "1":
					case "line": _type = GeometryType.GEOMETRY_LINE;
						break;
					case "0":
					case "point": _type = GeometryType.GEOMETRY_POINT;
						break;
				}
				var isPacked:Boolean = false;
				if (xml.@packed.toString().toLowerCase() == "true") {
					isPacked = true;
				}
				
				if (_parameters && _parameters.packed) {
					isPacked = _parameters.packed;
				}
				
				var sme:SpaceModelEntity;
				var bb:Array;
				
				bb = xml.@b.toString().split("|");
				_bounds = new BoundingBox( bb[0], bb[1], bb[2], bb[3] );
				
				var attributeName:String;
				
				
				// Alternative Implementierung für Attribute als DM
				//var attributeNamesExcludedFromDM:String = " p b giscode id space_id";
				//var attributeNames:Object = new Object();
				//var attributes:Object = new Object();
				//var entityIds:Array = new Array();
				
				for each ( var place:XML in xml.place) {
					sme = new SpaceModelEntity();
					sme.id = place.@giscode.toString();
					if (sme.id == "") {
						sme.id = place.@id.toString();
					}
					sme.name = place.@name.toString();
					bb = place.@b.toString().split("|");
					if (bb && bb.length==4) {
						sme.bounds = new BoundingBox( bb[0], bb[1], bb[2], bb[3] );
					} else {
						sme.bounds = new BoundingBox(0, 0, 0, 0);
					}
					
					bb = place.@p.toString().split("|");
					sme.center = new Point( bb[0], bb[1] );
					
					// Alternative Implementierung für Attribute als DM
					//attributes[ sme.id ] = new Object();
					//entityIds.push(sme.id);
					
					for each ( var attribute:XML in place.@ * ) {
						attributeName = attribute.name().toString();
						//if (attributeNamesExcludedFromDM.indexOf( attributeName )<1) {
							sme.attributes[ attributeName ] = attribute.toString();
							// Alternative Implementierung für Attribute als DM
							//attributes[ id ][ attributeName ] = attribute.toString();
							//attributeNames[ attributeName ]++;
						//}
					}
					
					if (geometryType == GeometryType.GEOMETRY_AREA ||
						geometryType == GeometryType.GEOMETRY_LINE)
					{
						var path:GraphicsPath = new GraphicsPath();
						var points:Array
						var x0:Number = 0;
						var y0:Number = 0;
						if (isPacked) {
							x0 = sme.bounds.minx;
							y0 = sme.bounds.miny;
						}
						for each (var line:XML in place.line) {
							points = line.toString().split("|");
							if (points.length > 2) {
								path.moveTo( x0 + parseFloat(points[0]), y0 + parseFloat(points[1]) );
								var pointPairs:int = points.length / 2;
								for (var i:int = 1; i < pointPairs; i++) {
									path.lineTo( x0 + parseFloat(points[i * 2]), y0 + parseFloat(points[i * 2 + 1]) );
								}
							}
						}
						sme.path = path;
					}
					addEntity( sme );
				}
				
				/*
				// Alternative Implementierung für Attribute als DM
				_attributes = new DataModel( _id );
				
				var dmSpaceDimension:ModelDimension = new ModelDimension( _id + "_entities", "space entities", "(ID)", ModelDimensionType.ENTITY_ID, entityIds );
				_attributes.addPropertyDimension( dmSpaceDimension );
				
				var dmValueDimension:ModelDimension;
				
				for (attributeName in attributeNames) {
					dmValueDimension = new ModelDimension( attributeName, attributeName, attributeName, ModelDimensionType.INTERVAL );
					_attributes.addValueDimension( dmValueDimension );
				}
				
				
				
				for ( var entityID:String in attributes ) {
					
				}
				
				*/
				
				_complete = true;
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			
			
		}
		
	}
	
}