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
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.omoa.framework.GeometryType;
	import org.omoa.framework.ISpaceModelLoader;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModel;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * A SpaceModel extension that loads and stores bitmap images as raster tiles.
	 * 
	 * @author Sebastian Specht
	 */
	public class RasterSpaceModel extends SpaceModel implements ISpaceModelLoader {
		
		public const URL_ATTRIBUTE:String = "_url";
		public const MIN_ATTRIBUTE:String = "_min";
		public const MAX_ATTRIBUTE:String = "_max";
		
		private var overview:SpaceModelEntity;
		private var overviewLoader:Loader;
		private var overviewRaw:ByteArray;
		
		private var loaderToEntity:Dictionary;
		private var loaderCounter:int = 0;
		
		public function RasterSpaceModel() {
			super();
			_type = GeometryType.GEOMETRY_BOUNDS;
			_id = "RasterSpaceModel" + Math.round(Math.random() * 1000000);
			loaderToEntity = new Dictionary();
		}
		
		/**
		 * Initialise the raster tiles and start the loading process.
		 * 
		 * The <code>data</code> Parameter is expected to hold an Object of the following form:
		 * 
		 * <pre>
		 * var data:Object = {
		 * 					bounds: <i>BoundingBox</i>,
		 * 					tiles:  [
		 * 					   {url: <i>filename as String</i>, bounds: <i>BoundingBox</i>, min: <i>min as Number</i>, max: <i>max as Number</i> },
		 * 					   {url: <i>filename as String</i>, bounds: <i>BoundingBox</i>}
		 * 							]
		 * 					 }
		 * </pre>
		 * 
		 * The top level bounds object is optional, the tile bounds and url are required. 
		 * The min and max properties for scale dependant display of the tiles
		 * are optional and have no function at the moment.
		 * 
		 * @param	data Is expected to be an Object.
		 */
		public function initialize(data:*):void {
			if (data) {
				if (data.bounds) {
					_bounds = data.bounds as BoundingBox;
				}
				if (data.tiles) {
					
					var tile:Object;
					var min:Number, max:Number;
					var loader:Loader;
					
					for each (tile in data.tiles) {
						min = max = 0;
						if (tile.min) {
							min = tile.min as Number;
						}
						if (tile.max) {
							max = tile.max as Number;
						}
						if (!_bounds) {
							_bounds = tile.bounds as BoundingBox;
						}
						//TODO: Calculate SpaceModel bounds from tiles.
						
						if (!data.bounds) {
							_bounds.fromRectangle( _bounds.union( tile.bounds as Rectangle) );
						}
						
						addRasterTile( tile.url as String,
									   tile.bounds as BoundingBox,
									   min, max );
					}
				}
			}
		}
		
		public function addRasterTile(url:String,
										bounds:BoundingBox, 
										minDisplayScale:Number = 0,
										maxDisplayScale:Number = 0):void {
			var sme:SpaceModelEntity = new SpaceModelEntity();
			sme.name = _id + "_" + entities.length;
			sme.id = entities.length.toString();
			sme.bounds = bounds;
			sme.attributes = new Object();
			sme.attributes[URL_ATTRIBUTE] = url;
			sme.attributes[MIN_ATTRIBUTE] = minDisplayScale;
			sme.attributes[MAX_ATTRIBUTE] = maxDisplayScale;
			addEntity(sme);
			
			loaderCounter++;
			
			var loader:Loader = new Loader();
			//TODO: Add Error Response;
			loader.contentLoaderInfo.addEventListener(Event.INIT, loaderInitResponse);
			loader.load( new URLRequest(url) );
			loaderToEntity[loader] = sme;
		}
		
		private function loaderInitResponse(e:Event):void {
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			if (loaderInfo) {
				
				var sme:SpaceModelEntity = loaderToEntity[ loaderInfo.loader ] as SpaceModelEntity;
				if (sme) {
					sme.bitmapData = Bitmap(loaderInfo.content).bitmapData;
					
					// clean up
					loaderInfo.loader.removeEventListener(Event.INIT, loaderInitResponse);
					loaderInfo.loader.unloadAndStop();
					delete( loaderToEntity[ loaderInfo.loader ] );
					loaderInfo = null;
					loaderCounter--;
				}
				if (loaderCounter < 1) {
					_complete = true;
					dispatchEvent( new Event( Event.COMPLETE ) );
				}
			}
		}
		
		public function setId(value:String):void {
			_id = value;
		}
		
		public function load(url:String, parameters:Object = null):void {
			// we could load some standard format raster tiles here, like e.g. map server.
		}
		
		
		
	}

}