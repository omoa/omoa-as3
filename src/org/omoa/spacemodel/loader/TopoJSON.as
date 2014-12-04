package org.omoa.spacemodel.loader 
{
	import flash.display.GraphicsPath;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.Description;
	import org.omoa.framework.GeometryType;
	import org.omoa.framework.IDataModel;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.spacemodel.AbstractSMLoader;
	import com.brokenfunction.json.decodeJson;
	import org.omoa.spacemodel.SpaceModelClone;
	import org.omoa.spacemodel.SpaceModelEntity;
	import org.omoa.util.GeometryFunctions;
	
	
	/**
	 * Implementation of a Loader for the TopoJSON format. The individual "objects"
	 * / GeometryCollections can be obtained through getCollectionIDs() / createSpaceModel().
	 * 
	 * Specification: https://github.com/topojson/topojson-specification/blob/master/README.md
	 * @author SKS
	 */
	public class TopoJSON extends AbstractSMLoader {
		
		private var attributeFieldName:String = "";
		private var attributeFieldId:String = null;
		private var compact:Boolean = false;
		
		private var json:Object;
		private var loader:URLLoader
		
		private var quantized:Boolean = false;
		private var t_sx:Number = 1.0;
		private var t_sy:Number = 1.0;
		private var t_dx:Number = 0;
		private var t_dy:Number = 0;
		
		private var arcs:Vector.<Array> = new Vector.<Array>();
		
		private var entityCollections:Object = new Object();
		private var entityCollectionTypes:Object = new Object();
		private var collectionIDs:Array = new Array();
		private var t:Timer;
		
		public function TopoJSON() {
			super();
		}
		
		override public function load( url:String, parameters:Object = null ):void {
			if (parameters) {
				if (parameters.hasOwnProperty("id")) {
					if (parameters.id != null) {
						attributeFieldId = parameters.id;
					} else {
						attributeFieldId = null;
					}
				}
				if (parameters.name) {
					attributeFieldName = parameters.name;
				}
				if (parameters.modelID && !_id) {
					_id = parameters.modelID;
				}
				if (parameters.hasOwnProperty("compact") && parameters.compact == true) {
					compact = true;
				}
			}
			
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
				trace( new Date().getTime() + " TopoJSON a1" );
				json = decodeJson( jsonString, true );
				trace( new Date().getTime() + " TopoJSON a2" );
				if (json.hasOwnProperty("type") && json.type == "Topology") {
					// json Represents the root object
					if (json.hasOwnProperty("bbox")) {
						_bounds = new BoundingBox(json.bbox[0], json.bbox[1], json.bbox[2], json.bbox[3]);
					}
					if (json.hasOwnProperty("transform")) {
						// This is a quantized topojson file
						quantized = true;
						t_sx = json.transform.scale[0];
						t_sy = json.transform.scale[1];
						t_dx = json.transform.translate[0];
						t_dy = json.transform.translate[1];
					}
					if (json.hasOwnProperty("arcs")) {
						// process arcs
						var arc:Array;
						if (quantized) {
							for each (arc in json.arcs) {
								arcs.push(
									decodeArc(arc)
								);
							}
						} else {
							for each (arc in json.arcs) {
								arcs.push( arc );
							}
						}
					}
					if (json.hasOwnProperty("objects")) {
						// process GeometryCollections ("layers")
						var firstIndex:int = 0;
						var previousLength:int = 0;
						for (var collectionID:String in json.objects) {
							var collection:Object = json.objects[collectionID];
							
							if (collection.hasOwnProperty("type")
								&& collection.type == "GeometryCollection"
								&& collection.hasOwnProperty("geometries")) 
							{
								//entities = new Vector.<SpaceModelEntity>();
								for each (var feature:Object in collection.geometries) {
									parseFeature( feature );
								}
								switch (feature.type) {
									case "Polygon":
										_type = GeometryType.GEOMETRY_AREA;
										break;
									case "Point":
										_type = GeometryType.GEOMETRY_POINT;
										break;
									case "LineString":
										_type = GeometryType.GEOMETRY_LINE;
										break;
									case "MultiPolygon":
										_type = GeometryType.GEOMETRY_AREA;
										break;
									case "MultiLineString":
										_type = GeometryType.GEOMETRY_LINE;
										break;
									case "MultiPoint":
										// Omoa can not represent that, leave default GeometryType.GEOMETRY_NONE;
										break;
								}
								entityCollections[collectionID] = entities.slice(firstIndex);
								firstIndex = entities.length
								entityCollectionTypes[collectionID] = _type;
								collectionIDs.push(collectionID);
							}
						}
					}
				}
				json = null;
				jsonString = null;
				
				//TODO: Calculate center for each sme
				var sme:SpaceModelEntity = entities[0];
				if (sme && sme.path && !sme.bounds) {
					// The file did not countain bounding boxes on an entity level
					t = new Timer(50);
					t.addEventListener(TimerEvent.TIMER, postprocessBounds);
					t.start();
				} else {
					finalizeModel();
				}
			}
		}
		
		private function postprocessBounds(e:Event):void {
			t.removeEventListener(TimerEvent.TIMER, postprocessBounds);
			t = null;
			
			for each (var sme:SpaceModelEntity in entities) {
				sme.bounds = new BoundingBox(0, 1, 2, 3);
				GeometryFunctions.boundsFromPath(sme.path as GraphicsPath, sme.bounds);
				if (!sme.center) {
					sme.center = new Point();
					GeometryFunctions.centroid(sme.path as GraphicsPath, sme.center);
				}
			}
			
			finalizeModel();
		}
		
		private function finalizeModel():void {
			_complete = true;
			trace( new Date().getTime() + " TopoJSON b" );
			dispatchEvent( new Event( Event.COMPLETE ) );
			trace( new Date().getTime() + " TopoJSON c" );
		}
		
		private function decodeArc(arc:Array):Array {
			var x:Number = 0;
			var y:Number = 0;
			var sx:Number = t_sx;
			var sy:Number = t_sy;
			var dx:Number = t_dx;
			var dy:Number = t_dy;
			return arc.map(function(position:Array, index:int, arc:Array):Array {
				position = position.slice();
				position[0] = (x += position[0]) * sx + dx;
				position[1] = (y += position[1]) * sy + dy;
				return position;
			});
		}
		
		private function decodePosition(position:Array):Array {
			var sx:Number = t_sx;
			var sy:Number = t_sy;
			var dx:Number = t_dx;
			var dy:Number = t_dy;
			position = position.slice();
			position[0] = position[0] * sx + dx;
			position[1] = position[1] * sy + dy;
			return position;
		  }
		
		private function parseArc( path:GraphicsPath, arcsArray:Array ):void {
			var i:int;
			var arcIndex:int;
			var length:int;
			var arc:Array;
			
			var firstArc:Boolean = true;					
			for each (arcIndex in arcsArray) {
				if (arcIndex<0) {
					arc = arcs[ (arcIndex*-1)-1 ].slice().reverse();
				} else {
					arc = arcs[ arcIndex ]
				}			
				if (firstArc) {
					path.moveTo( arc[0][0], arc[0][1] );
					firstArc = false;
				}
				length = arc.length;
				for (i = 1; i < length; i++) {
					path.lineTo( arc[i][0], arc[i][1] );
				}
			}
		}
		
		private function parseFeature( json:Object ):void {
			var id:String;
			var name:String;
			var attributes:Object;
			var bbox:BoundingBox;
			var sme:SpaceModelEntity;
			var path:GraphicsPath;
			var ring:Array;
			
			if (json.hasOwnProperty("type")) {
				if (!attributeFieldId && json.hasOwnProperty("id")) {
					id = json.id;
				}
				if (json.hasOwnProperty("bbox")) {
					bbox = new BoundingBox(json.bbox[0], json.bbox[1], json.bbox[2], json.bbox[3]);
				}
				if (json.hasOwnProperty("properties") || json.hasOwnProperty("p")) {
					if (!compact) {
						attributes = json.properties;
					} else {
						attributes = json.p;
					}
					attributes.type = json.type;
					if (!id && attributes.hasOwnProperty(attributeFieldId)) {
						id = attributes[attributeFieldId];
					}
					if (attributes.hasOwnProperty(attributeFieldName)) {
						name = attributes[attributeFieldName];
					}
					if (!bbox && attributes.hasOwnProperty("bbox")) {
						bbox = new BoundingBox(attributes.bbox[0], attributes.bbox[1], 
												attributes.bbox[2], attributes.bbox[3]);
					}
				} else {
					attributes = [];
				}
				if (!id) {
					id = "id" + entityCount();
				}
				if (!name) {
					name = id;
				}
				if (json.hasOwnProperty("arcs") || json.hasOwnProperty("coordinates") || json.hasOwnProperty("c")) {
					sme = new SpaceModelEntity();
					sme.id = id;
					sme.name = name;
					sme.bounds = bbox;
					switch (json.type) {
						case "Polygon":
							path = new GraphicsPath();
							for each (ring in json.arcs) {
								parseArc( path, ring);
							}
							attributes.arcs = json.arcs;
							break;
						case "Point":
							var p:Array;
							if (!compact) {
								p = decodePosition( json.coordinates );
							} else {
								p = decodePosition( json.c );
							}
							sme.center = new Point( p[0], p[1]);
							var fuzz:Number = sme.center.x * 0.0000001;
							if (!sme.bounds) {
								sme.bounds = new BoundingBox( sme.center.x, sme.center.y, sme.center.x+fuzz, sme.center.y+fuzz );
							}
							break;
						case "LineString":
							path = new GraphicsPath();
							parseArc( path, json.arcs);
							attributes.arcs = json.arcs;
							break;
						case "MultiPolygon":
							path = new GraphicsPath();
							for each (var poly:Array in json.arcs) {
								for each (ring in poly) {
									parseArc( path, ring);
								}
							}
							attributes.arcs = json.arcs;
							break;
						case "MultiLineString":
							path = new GraphicsPath();
							for each (ring in json.arcs) {
								parseArc( path, ring);
							}
							attributes.arcs = json.arcs;
							break;
						case "MultiPoint":
							// Omoa can not represent that
							break;
					}
					sme.attributes = attributes;
					sme.path = path;
					addEntity(sme);
				}
			}
		}
		
		override public function linkDataModel(model:IDataModel, dataDescription:Description = null):void {
			// does this make sense?
			trace("TopoJSON.linkDataModel() not implemented");
		}
		
		public function createSpaceModel( collectionID:String, overrideSpaceModelID:String = null ):ISpaceModel {
			var smes:Vector.<SpaceModelEntity> = entityCollections[collectionID] as Vector.<SpaceModelEntity>;
			if (smes && smes.length>0) {
				if (!overrideSpaceModelID) {
					overrideSpaceModelID = collectionID;
				}
				var bounds:BoundingBox = new BoundingBox(_bounds.minx, _bounds.miny, _bounds.maxx, _bounds.maxy);				
				return new SpaceModelClone( overrideSpaceModelID, 
											bounds, 
											entityCollectionTypes[collectionID], 
											smes);
			}
			return null;
		}
		
		public function getCollectionIDs():Array {
			return collectionIDs.slice();
		}
	}

}