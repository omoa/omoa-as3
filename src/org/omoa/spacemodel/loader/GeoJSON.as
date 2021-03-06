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
	
	import com.brokenfunction.json.decodeJson;
	import flash.display.GraphicsPath;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.GeometryType;
	import org.omoa.spacemodel.*;
	import org.omoa.util.GeometryFunctions;
	
	/**
	 * ...
	 * 
	 * @author Sebastian Specht
	 *
	 */
	
	public class GeoJSON extends AbstractSMLoader {
		private var json:Object;
		private var loader:URLLoader
		
		public function GeoJSON() {
			super();
		}
		
		override public function load( url:String, parameters:Object = null ):void {
			// TODO: provide a choice for name and id properties
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete );
			loader.addEventListener(IOErrorEvent.IO_ERROR, error );
			loader.addEventListener(ProgressEvent.PROGRESS, progress);
			loader.load( new URLRequest(url) );
		}
		
		private function progress(e:ProgressEvent):void {
			dispatchEvent(e);
		}
		
		private function loadComplete( e:Event ):void {
			if (loader) {
				//trace( "Load complete");
				initialize( loader.data );
				loader.removeEventListener(Event.COMPLETE, loadComplete );
				loader.removeEventListener(IOErrorEvent.IO_ERROR, error );
				loader.removeEventListener(ProgressEvent.PROGRESS, progress);
				loader = null;
			}
		}
		
		private function error(e:Event):void {
			trace( "Load error" + e);
		}
		
		override public function initialize( data:* ):void {
			var jsonString:String = data as String;
			
			if (jsonString) {
				json = decodeJson( jsonString, true );
				parseFeature( json );
				json = null;
				jsonString = null;
				_complete = true;
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		private function parseRing( path:GraphicsPath, ring:Array ):void {
			var i:int; var length:int = ring.length;
			
			path.moveTo( ring[0][0], ring[0][1] );						
			for (i = 1; i < length; i++) {
				path.lineTo( ring[i][0], ring[i][1] );
			}
		}
		
		private function parseFeature( json:Object ):void {
			
			if (json.hasOwnProperty("type") && json.type == "Feature") {
				
				var sme:SpaceModelEntity = new SpaceModelEntity();
				var JSONode:Object = json;
				
				
				if (JSONode.hasOwnProperty("id")) {
					sme.id = JSONode.id;
				}
				
				// TODO: provide a choice for name and id properties
				if (JSONode.hasOwnProperty("properties")) {
					sme.attributes = JSONode.properties;
					if (!sme.id && JSONode.properties.hasOwnProperty("id")) {
						sme.id = JSONode.properties.id;
					}
					if (JSONode.properties.hasOwnProperty("name")) {
						sme.name = JSONode.properties.name;
					} else if (JSONode.properties.hasOwnProperty("NAME")) {
						sme.name = JSONode.properties.NAME;
					} else {
						sme.name = sme.id;
					}
					if (JSONode.properties.hasOwnProperty("bbox")) {
						sme.bounds = new BoundingBox(JSONode.properties.bbox[0],
													JSONode.properties.bbox[1],
													JSONode.properties.bbox[2],
													JSONode.properties.bbox[3]);
					}
				}
				
				if (JSONode.hasOwnProperty("geometry")) {
					var g:Object = JSONode.geometry;
					var coordinates:Array = g.coordinates;
					var path:GraphicsPath;
					var center:Point;
					var bounds:BoundingBox;
					var ring:Array;
					
					if (g.hasOwnProperty("type")) {
						switch (g.type) {
							case 'Point':
								_type = GeometryType.GEOMETRY_POINT; //TODO: improve
								center = new Point(coordinates[0], coordinates[1]);
								var fuzz:Number = center.x * 0.0000001;
								if (!sme.bounds) {
									bounds = new BoundingBox( center.x, center.y, center.x+fuzz, center.y+fuzz );
								} else {
									bounds = sme.bounds;
								}
								break;
							
							case 'LineString':
								_type = GeometryType.GEOMETRY_LINE;
								
								path = new GraphicsPath();
								parseRing( path, coordinates);
								
								if (sme.bounds) {
									//TODO: improve
									center = sme.bounds.topLeft; 
								} else {
									bounds = new BoundingBox(0, 0, 0, 0);
									GeometryFunctions.boundsFromPath( path, bounds );
									center = new Point(coordinates[0][0], coordinates[0][1]); 
								}
								
								break;
							case 'MultiLineString':
								_type = GeometryType.GEOMETRY_LINE;
								path = new GraphicsPath();
								
								for each (ring in coordinates) {
									parseRing( path, ring);
								}
								
								if (sme.bounds) {
									//TODO: improve
									center = sme.bounds.topLeft; 
								} else {
									bounds = new BoundingBox(0, 0, 0, 0);
									GeometryFunctions.boundsFromPath( path, bounds );
									center = new Point(coordinates[0][0][0], coordinates[0][0][1]); 
								}
								break;
							case 'Polygon':
								_type = GeometryType.GEOMETRY_AREA;
								path = new GraphicsPath();
								//TODO: Test
								for each (ring in coordinates) {
									parseRing( path, ring);
								}
								
								if (sme.bounds) {
									//TODO: improve
									center = sme.bounds.topLeft; 
								} else {
									bounds = new BoundingBox(0, 0, 0, 0);
									GeometryFunctions.boundsFromPath( path, bounds );
									center = new Point(coordinates[0][0], coordinates[0][1]); 
								}
								break;
							case "MultiPolygon":
								_type = GeometryType.GEOMETRY_AREA;
								path = new GraphicsPath();
								var outerRing:Array;
								
								for each (outerRing in coordinates) {
									for each (ring in outerRing) {
										parseRing( path, ring);
									}
								}
								
								if (sme.bounds) {
									//TODO: improve
									center = sme.bounds.topLeft; 
								} else {
									bounds = new BoundingBox(0, 0, 0, 0);
									GeometryFunctions.boundsFromPath( path, bounds );
									center = new Point(coordinates[0][0][0], coordinates[0][0][1]); 
								}
								break;
							
							case "GeometryCollection":
								throw new Error('Can not handle GeometryCollection features.');
								break;
							case 'MultiPoint':
								throw new Error('Can not handle MultiPoint features - please use multiple Point features.');
								break;
							default:
								throw new Error('Invalid GeoJSON object.');
							
						}
						sme.center = center;
						sme.path = path;
						if (!sme.bounds) {
							sme.bounds = bounds;
						}
						var b:Rectangle;
						if (_bounds) {
							b = sme.bounds as Rectangle;
							_bounds.fromRectangle( _bounds.union(b) );
						} else {
							b = sme.bounds as Rectangle;
							_bounds = new BoundingBox(0, 0, 0, 0);
							_bounds.fromRectangle(b);
						}
					}
				} else {
					// has no Geometry - raise Error?
				}
				addEntity(sme);
				//}
			} else if (json.hasOwnProperty("type") 
					&& json.type == "FeatureCollection"
					&& json.hasOwnProperty("features") ) 
			{
				var features:Array = json.features as Array;
				for each (var feature:Object in features) {
					parseFeature( feature );
				}
				if (json.hasOwnProperty("bbox")) {
					_bounds = new BoundingBox(json.bbox[0], json.bbox[1], json.bbox[2], json.bbox[3]);
				} else {
					//TODO:
				}
			} else {
				// malformed?
			}
				
				
			
		}
		
	}
	
}