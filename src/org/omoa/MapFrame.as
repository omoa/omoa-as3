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

package org.omoa {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.ILayer;
	import org.omoa.framework.IOverlay;
	import org.omoa.framework.IProjection;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.Map;
	import org.omoa.projection.AbstractProjection;
	import org.omoa.util.NavigationButtons;
	import org.omoa.util.OmoaLogo;
	
	/**
	 * A MapFrame, a map may have more than one, is the visible instance of a map on the screen.
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class MapFrame extends Sprite {

		public var center:Point = new Point(0, 0);
		public var bounds:BoundingBox = new BoundingBox( 0, 0, 1, 1);
		public var viewportBounds:BoundingBox = new BoundingBox( 0, 0, 1, 1);
		public var projection:IProjection = new AbstractProjection();
		public var transformation:Transform = null;  //veraltet???
		
		public var logo:OmoaLogo;
		public var navigation:NavigationButtons;
		public var borderColor:Number = 0x000000;
		
		public static const SCALE_FIT:String = "fit";
		public static const SCALE_FILL:String = "fill";
		/**
		 * Defines the way in which the method <code>fitToFrame()</code> interacts
		 * with the map scale. MapFrame.SCALE_FIT shows the whole map extent while 
		 * MapFrame.SCALE_FILL zooms in a bit. The calculated scale is used as
		 * a "reference scale" e.g. for minZoomFactor / maxZoomFactor. 
		 */
		public var scale_reset_strategy:String = SCALE_FILL;
		
		
		/**
		 * Defines minimum zoom factor of the map with regard to the internal
		 * reference scale (minZoomFactor * referenceScale).
		 */
		public var minZoomFactor:Number = 0.9;
		/**
		 * Defines maximum zoom factor of the map with regard to the internal
		 * reference scale (maxZoomFactor * referenceScale).
		 */
		public var maxZoomFactor:Number = 3.0;
		
		/**
		 * When set (in map coordinates), this option defines the constraints of 
		 * a map recenter operation (but not.
		 */
		public var viewportConstraints:BoundingBox = null;
		
		
		private var _layers:Vector.<ILayer> = new Vector.<ILayer>();
		private var _overlays:Vector.<IOverlay> = new Vector.<IOverlay>();
		private var _invalidatedLayers:Object;
		private var _map:Map;
		
		private var _bg:Shape;
		private var _layerContainerWrapper:Sprite;
		private var _layerCache:Bitmap;
		private var _layerCacheWrapper:Sprite;
		private var _layerContainer:Sprite;
		private var _frameDecoration:Sprite;
		private var _overlayContainer:Sprite;
		private var _debug:Shape;
		
		private var _scale:Number = NaN;
		private var _referenceScale:Number = NaN;
		private var _minimum_scale:Number = NaN;
		private var _maximum_scale:Number = NaN;
		private var _worldWidth:Number;
		private var _worldHeight:Number;
		
		private var layerTransformation:Matrix = new Matrix();
		private var _bgColor:int;
		
		public function MapFrame(map:Map=null) {
			_map = map;
			
			mouseEnabled = true;
			
			_bg = new Shape();
			bgColor = 0xfffff9;
			addChild( _bg );
			
			_layerContainerWrapper = new Sprite();
			_layerContainerWrapper.scrollRect = new Rectangle(0,0,1,1);
			addChild(_layerContainerWrapper);
			
			_layerContainer = new Sprite();
			_layerContainer.mouseChildren = true;
			_layerContainerWrapper.addChild( _layerContainer);
			
			
			_layerCacheWrapper = new Sprite();
			_layerCacheWrapper.visible = false;
			_layerCache = new Bitmap();
			_layerCacheWrapper.addChild(_layerCache);
			_layerContainerWrapper.addChild( _layerCacheWrapper);
			
			_frameDecoration = new Sprite();
			_frameDecoration.mouseChildren = false;
			addChild( _frameDecoration );
			
			_overlayContainer = new Sprite();
			_overlayContainer.mouseChildren = false;
			addChild( _overlayContainer );
			
			transformation = new Transform(_layerContainer);
			
			_debug = new Shape();
			_debug.name = "debug";
			addChild( _debug );
			
			layerTransformation.b = 0;
			layerTransformation.c = 0;
			
			logo = new OmoaLogo();
			addChild( logo );
			
			navigation = new NavigationButtons();
			addChild( navigation );
			navigation.addEventListener(NavigationButtons.EVENT_PLUS, zoomIn);
			navigation.addEventListener(NavigationButtons.EVENT_MINUS, zoomOut);
			navigation.addEventListener(NavigationButtons.EVENT_HOME, fitToFrame);
			
			navigation.addEventListener(NavigationButtons.EVENT_NORTH, moveNorth);
			navigation.addEventListener(NavigationButtons.EVENT_SOUTH, moveSouth);
			navigation.addEventListener(NavigationButtons.EVENT_WEST, moveWest);
			navigation.addEventListener(NavigationButtons.EVENT_EAST, moveEast);
		}
		
		public function setMap( map:Map ):void {
			_map = map;
		}
		
		public function set bgColor( value:int ):void {
			_bgColor = value;
			_bg.graphics.clear();
			_bg.graphics.beginFill(value);
			_bg.graphics.drawRect(0, 0, 1, 1);
			_bg.graphics.endFill();
		}
		
		public function get bgColor():int {
			return _bgColor;
		}
		
		override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
			if (_layerContainer.cacheAsBitmap) {
				_layerContainer.startDrag(lockCenter, bounds);
			} else {
				_layerCacheWrapper.startDrag(lockCenter, bounds);
			}

			addEventListener(MouseEvent.MOUSE_MOVE, whileDrag);
		}
		
		private function whileDrag(e:MouseEvent):void {
			_overlayContainer.visible = false;
			if (!_layerContainer.cacheAsBitmap) {
				_layerCacheWrapper.visible = true;
				_layerContainer.visible = false;
			}
		}
		
		public function followDrag( x:Number, y:Number):void {
			if (_layerCacheWrapper.visible) {
				_layerCacheWrapper.x = x;
				_layerCacheWrapper.y = y;
			} else {
				_layerContainer.x = x;
				_layerContainer.y = y;
			}
		}
		
		public function stopFollowDrag():void {
			if (_layerCacheWrapper.visible) {
				_layerCacheWrapper.x = 0;
				_layerCacheWrapper.y = 0;
			} else {
				_layerContainer.x = 0;
				_layerContainer.y = 0;
			}
		}
		
		//TODO: There is an offset involved.
		public function dragPosition():Point {
			var p:Point;
			if (_layerCacheWrapper.visible) {
				p = _layerCacheWrapper.getRect(this).topLeft;
			} else {
				p = _layerContainer.getRect(this).topLeft;
			}
			return p;
		}
		
		override public function stopDrag():void {
			var movement:Number
			
			removeEventListener(MouseEvent.MOUSE_MOVE, whileDrag);
			_overlayContainer.visible = true;
			_layerContainer.visible = true;
			
			
			if (_layerCacheWrapper.visible) {
				_layerCacheWrapper.stopDrag();
				movement = Math.abs(_layerCacheWrapper.x * _layerCacheWrapper.y);
				if (movement>4) {
					moveCenterByScreenCoordinates( _layerCacheWrapper.x * -1, _layerCacheWrapper.y * -1 );
				}
				_layerCacheWrapper.x = 0;
				_layerCacheWrapper.y = 0;
				_layerCacheWrapper.visible = false;
			} else {
				_layerContainer.stopDrag();
				movement = Math.abs(_layerContainer.x * _layerContainer.y);
				if (movement>4) {
					moveCenterByScreenCoordinates( _layerContainer.x * -1, _layerContainer.y * -1 );
				}
				_layerContainer.x = 0;
				_layerContainer.y = 0;
			}
		}
		
		/* ===========================================
		 * Layer Manipulation
		 * =========================================== */
		
		public function addLayer(layer:ILayer):void {
			if (projection.isIdentical(layer.spaceModel.projection)) {
				var layerSprite:Sprite = new Sprite();
				layerSprite.name = layer.id;
				layerSprite.mouseChildren = false;
				layerSprite.mouseEnabled = false;
				
				_layers.push( layer );
				if (_map) {
					_map.addLayer( layer );
				}
				
				_layerContainer.addChild( layerSprite );
				
				if (layer.spaceModel.isComplete) {
					// set up layer now
					layer.setup( layerSprite );
					renderLayer( layer.id );
					layer.spaceModel.addEventListener( Event.CHANGE, onSpaceModelChange );
				} else {
					// defer layer setup until ISpaceModel is ready
					layer.spaceModel.addEventListener(Event.COMPLETE, onSpaceModelComplete, false, 100 );
				}
				
				layer.addEventListener(Event.CHANGE, onLayerInvalidate);
				
			} else {
				throw new Error( "The Projection of the Layers SpaceModel " +
				"does not match the Projection of the MapFrame." );
			}
			
		}
		
		private function onLayerInvalidate(e:Event):void {
			var layer:ILayer = e.target as ILayer;
			
			if (layer) {
				invalidateLayer(layer.id);
			}
		}
		
		private function invalidateLayer(id:String):void {
			if (!_invalidatedLayers) {
				_invalidatedLayers = new Object();
				addEventListener(Event.ENTER_FRAME, renderInvalidatedLayers);
			}
			_invalidatedLayers[id] = "invalid";
		}
		
		private function renderInvalidatedLayers(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, renderInvalidatedLayers);
			var id:String;
			for (id in _invalidatedLayers) {
				renderLayer(id);
			}
			_invalidatedLayers = null;
		}
		
		public function removeLayer( layerID:String ):ILayer {
			var layer:ILayer = _map.layer(layerID);
			if (!layer) {
				return null;
			}
			
			var layerSprite:Sprite = _layerContainer.getChildByName( layerID ) as Sprite;
			if (layerSprite) {
				layer.cleanup( layerSprite );
				
				// This may be a bit paranoid...
				layerSprite.removeChildren();
				
				_layerContainer.removeChild( layerSprite );	
				
				if (layer.spaceModel.hasEventListener(Event.COMPLETE)) {
					layer.spaceModel.removeEventListener( Event.COMPLETE, onSpaceModelComplete );
				}
				
				if (layer.spaceModel.hasEventListener(Event.CHANGE)) {
					layer.spaceModel.removeEventListener( Event.CHANGE, onSpaceModelChange );
				}
				
							
				layerSprite = null;
			}
			
			_layers.splice( _layers.indexOf(layer), 1 );
			
			layer.removeEventListener(Event.CHANGE, onLayerInvalidate);
			
			return layer;			
		}
		
		
		/**
		 * Initializing all layers with a certain ISpaceModel. The
		 * listener has been registered in addLayer.
		 * 
		 * @param	e	
		 */
		private function onSpaceModelComplete(e:Event):void {
			var spaceModel:ISpaceModel = e.target as ISpaceModel;
			var layer:ILayer;
			var layerSprite:Sprite;
			
			if (spaceModel) {
				spaceModel.removeEventListener( Event.COMPLETE, onSpaceModelComplete );
				setupLayers(spaceModel);
				spaceModel.addEventListener( Event.CHANGE, onSpaceModelChange );
			}
		}
		
		public function onSpaceModelChange(e:Event):void {
			var sm:ISpaceModel = e.target as ISpaceModel;
			var layer:ILayer;
			if (sm) {
				setupLayers(sm);
			}
		}
		
		public function countLayers():int {
			return _layers.length;
		}
		
		public function getLayer( index:int ):ILayer {
			if (index >= 0 && index < _layers.length) {
				return _layers[index];
			}
			return null;
		}
		
		public function getLayerSpriteByID( layerID:String ):Sprite {
			var layerSprite:Sprite;
			layerSprite = _layerContainer.getChildByName( layerID ) as Sprite;
			return layerSprite;
		}
		
		public function isLayerVisible( layerID:String ):Boolean {
			var layerSprite:Sprite;
			layerSprite = _layerContainer.getChildByName( layerID ) as Sprite;
			if (layerSprite) {
				return layerSprite.visible;
			}
			return false;
		}
		
		public function setLayerVisibility( layerID:String, visible:Boolean = true ):void {
			var layerSprite:Sprite;
			layerSprite = _layerContainer.getChildByName( layerID ) as Sprite;
			if (layerSprite && layerSprite.visible!=visible) {
				if (visible) {
					var layer:ILayer = _map.layer(layerID);
					if (layer && layer.isSetup(layerSprite)) {
						//invalidateLayer(layer.id);
						layer.rescale( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
						layer.recenter( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
					}
				}
				layerSprite.visible = visible;
			}
			
		}
		
		/* ===========================================
		 * Overlay Manipulation
		 * =========================================== */
		
		public function addOverlay(overlay:IOverlay):void {
			var overlaySprite:Sprite = new Sprite();
			overlaySprite.name = overlay.id;
			_overlayContainer.addChild( overlaySprite );
			_overlays.push( overlay );
			if (overlay.spaceModel) {
				if (overlay.spaceModel.isComplete) {
					overlay.setup( overlaySprite );
				} else {
					overlay.spaceModel.addEventListener(Event.COMPLETE, eventOverlaySMComplete, false, 500 );
				}
			} else {
				// has no SpaceModel, which is OK
				overlay.setup( overlaySprite );
			}
			renderOverlays();
		}
		
		private function eventOverlaySMComplete(e:Event):void {
			var sm:ISpaceModel = e.target as ISpaceModel;
			for each (var overlay:IOverlay in _overlays) {
				if (overlay.spaceModel == sm) {
					overlay.spaceModel.removeEventListener(Event.COMPLETE, eventOverlaySMComplete);
					overlay.setup( _overlayContainer.getChildByName( overlay.id ) as Sprite );
					break;
				}
			}
		}
		
		public function removeOverlay(overlay:IOverlay):void {
			var overlaySprite:Sprite = _overlayContainer.getChildByName(overlay.id) as Sprite;
			if (_overlays.indexOf(overlay) > -1) {
				if (overlaySprite) {
					overlay.deconstruct(overlaySprite);
					_overlayContainer.removeChild(overlaySprite);
				}
				_overlays.splice( _overlays.indexOf(overlay), 1);
			}
			renderOverlays();
		}
		
		/* ===========================================
		 * Scale Manipulation
		 * =========================================== */
		
		public function fitToFrame(e:Event = null):void {	
			resetBoundsAndScale();
			
			// Bounds nun dem Kartenausschnitt anpassen
			calculateBounds();
			
			// force render
			render();
			renderOverlays();
			
			if (e) {
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		
		public function zoomIn(e:Event=null):void {
			zoom(1.5);
			if (e) {
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		
		public function zoomOut(e:Event=null):void {
			zoom(0.75);
			if (e) {
				dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		
		public function zoom(factor:Number=0.7):void {
			_scale *= factor;
			if (_scale < _minimum_scale) {
				_scale = _minimum_scale;
			}
			if (_scale > _maximum_scale) {
				_scale = _maximum_scale;
			}
			_worldWidth = _bg.width / _scale;
			_worldHeight = _bg.height / _scale;
			calculateBounds();
			rescale();
			dispatchEvent( new Event(Event.CHANGE) );
		}
		
		public function zoomToFactor(zoomFactor:Number=1.0):void {
			_scale = _referenceScale * zoomFactor;
			if (_scale < _minimum_scale) {
				_scale = _minimum_scale;
			}
			if (_scale > _maximum_scale) {
				_scale = _maximum_scale;
			}
			_worldWidth = _bg.width / _scale;
			_worldHeight = _bg.height / _scale;
			calculateBounds();
			rescale();
		}
		
		public function get zoomFactor():Number {
			return _scale / _referenceScale;
		}
		
		/* ===========================================
		 * Extent Manipulation
		 * =========================================== */
		
		public function resize(widthNew:Number, heightNew:Number):void {
			var zF:Number = zoomFactor;
			
			_bg.width = widthNew;
			_bg.height = heightNew;
			
			resetBoundsAndScale();
				
			_worldWidth = widthNew / _scale;
			_worldHeight = heightNew / _scale;
			
			_frameDecoration.graphics.clear();
			if (!isNaN(borderColor)) {
				_frameDecoration.graphics.lineStyle(1, borderColor, 1, true);
				_frameDecoration.graphics.drawRect(0, 0, widthNew - 0.55, heightNew - 0.55);
			}
			calculateBounds();
			
			if (logo) {
				logo.x = 5;
				logo.y = heightNew - logo.height - 5;
			}
			
			var r:Rectangle = _layerContainerWrapper.scrollRect;
			r.x = 0;
			r.y = 0;
			r.width = widthNew;
			r.height = heightNew;
			_layerContainerWrapper.scrollRect = r;
			
			if (navigation) {
				navigation.x = 5;
				navigation.y = 5;
			}
			
			zoomToFactor(zF);
		}
		
		public function moveNorth(e:Event = null):void {
			moveCenterByScreenCoordinates( 0, _bg.height * -0.33);
			if (e) {
				dispatchEvent( new Event(Event.SCROLL) );
			}
		}
		
		public function moveSouth(e:Event = null):void {
			moveCenterByScreenCoordinates( 0, _bg.height * 0.33);
			if (e) {
				dispatchEvent( new Event(Event.SCROLL) );
			}
		}
		
		public function moveEast(e:Event = null):void {
			moveCenterByScreenCoordinates( _bg.height * 0.33, 0);
			if (e) {
				dispatchEvent( new Event(Event.SCROLL) );
			}
		}
		
		public function moveWest(e:Event = null):void {
			moveCenterByScreenCoordinates( _bg.height * -0.33, 0);
			if (e) {
				dispatchEvent( new Event(Event.SCROLL) );
			}
		}
		
		public function setCenterByScreenCoordinates( x:Number, y:Number ):void {
			//trace( "Clicked: " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			center.x = viewportBounds.minx + x / _scale;
			center.y = viewportBounds.maxy - y / _scale;
			calculateBounds();
			//trace( "Clicked: " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			recenter();
		}
		
		public function moveCenterByScreenCoordinates( x:Number, y:Number ):void {
			//trace( "Clicked: " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			center.x = center.x + (x / _scale);
			center.y = center.y - (y / _scale);
			calculateBounds();
			//trace( "Clicked: " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			recenter();
		}
		
		public function setCenterByStageCoordinates( x:Number, y:Number ):void {
			//trace( "Clicked: " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			var p:Point = new Point( x - this.x, y - this.y );
			p = this.globalToLocal( p );
			center.x = viewportBounds.minx + (p.x) / _scale;
			center.y = viewportBounds.maxy - (p.y ) / _scale;
			calculateBounds();
			//trace( "Clicked (stage): " +x + ", " + y + " entspricht "+center.x+", "+center.y);
			recenter();
		}
		
		public function setCenterByMapCoordinates( x:Number, y:Number, scale:Number = NaN ):void {
			
			center.x = x;
			center.y = y;
			calculateBounds();
			
			if (!isNaN(scale)) {
				_scale = scale;
				_worldWidth = _bg.width / _scale;
				_worldHeight = _bg.height / _scale;
				calculateBounds();
				rescale();
			} else {
				recenter();
			}
		}
		
		private function calculateBounds():void {
			viewportBounds.minx = center.x - _worldWidth * 0.5;
			viewportBounds.miny = center.y - _worldHeight * 0.5;
			viewportBounds.maxx = center.x + _worldWidth * 0.5;
			viewportBounds.maxy = center.y + _worldHeight * 0.5;
			
			if (viewportConstraints) {
				if (!viewportConstraints.containsRect(viewportBounds)) {
					if (viewportBounds.minx < viewportConstraints.minx) {
						viewportBounds.minx = viewportConstraints.minx;
					}
					if (viewportBounds.maxx > viewportConstraints.maxx) {
						viewportBounds.minx -= (viewportBounds.maxx - viewportConstraints.maxx);
					}
					if (viewportBounds.miny < viewportConstraints.miny) {
						viewportBounds.miny = viewportConstraints.miny;
					}
					if (viewportBounds.maxy > viewportConstraints.maxy) {
						viewportBounds.miny -= (viewportBounds.maxy - viewportConstraints.maxy);
					}
					center = viewportBounds.center;
				}
			}
			
			layerTransformation.tx = ((0 - center.x) - (viewportBounds.minx - center.x)) * _scale;
			layerTransformation.ty = (center.y - (viewportBounds.miny - center.y)) * _scale;
			layerTransformation.a = _scale;
			layerTransformation.d = _scale * -1;
			
		}
		
		public function resetBoundsAndScale():void {
			var b:Rectangle = new Rectangle();
			var layer:ILayer;
			
			if (_layers.length > 0) {
				for each (layer in _layers) {
					if (layer.spaceModel.isComplete) {
						b = b.union(layer.spaceModel.bounds as Rectangle);
					}
				}
				bounds.fromRectangle(b);
			} else {
				return;
			}
			
			if (scale_reset_strategy == SCALE_FILL) {
				_referenceScale = Math.max( _bg.width / bounds.width, _bg.height / bounds.height ) * 1.0;
			} else {
				_referenceScale = Math.min( _bg.width / bounds.width, _bg.height / bounds.height ) * 1.0;
			}
			
			if (isNaN(_scale)) {
				_scale = _referenceScale;
			}
			
			_minimum_scale = _referenceScale * minZoomFactor;
			_maximum_scale = _referenceScale * maxZoomFactor;
			
			if (center.x==0 && center.y==0) {
				center.x = bounds.minx + bounds.width * 0.5;
				center.y = bounds.maxy - bounds.height * 0.5;
			}
			
			_worldWidth = _bg.width / _scale;
			_worldHeight = _bg.height / _scale;
			
			//rescale();
			//recenter();
		}
		
		/* ===========================================
		 * Rendering
		 * =========================================== */
		
		/**
		 * To be called on a scale change.
		 */
		private function rescale():void {
			var layerSprite:Sprite;
			var layer:ILayer;
			
			//var totalT:Number = new Date().time;
			
			invalidateCache();
			
			for each (layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.rescale( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			renderOverlays();
			
			//trace( name + "'s rescale took (ms): " + (new Date().time - totalT) );
		}
		
		/** 
		 * To be called on a change of the map center (panning) or of the map extent (resize).
		 */
		private function recenter():void {
			var layerSprite:Sprite;
			var layer:ILayer;
			
			//var totalT:Number = new Date().time;
			
			invalidateCache();
			
			for each (layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.recenter( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			renderOverlays();
			
			//trace( name + "'s recenter took (ms): " + (new Date().time -totalT) );
		}
		
		// Aushilfsweise: Rendern auslösen (nach Daten-Änderung z.B.
		public function reRender():void {
			render();
		}
		
		/**
		 * Executes a setup on all layers with the corresponding space model.
		 * 
		 * @param	spaceModel
		 */
		private function setupLayers(spaceModel:ISpaceModel):void {
			var layer:ILayer;
			var layerSprite:Sprite;
			
			for each ( layer in _layers) {
				if (layer.spaceModel == spaceModel) {
					layerSprite = _layerContainer.getChildByName(layer.id) as Sprite;
					layer.setup( layerSprite );
				}
			}
			
			if (isNaN(_scale)) {
				resetBoundsAndScale();
			}
			
			for each ( layer in _layers) {
				if (layer.spaceModel == spaceModel) {
					renderLayer( layer.id );
				}
			}
		}
		
		private function render():void {
			var layer:ILayer;
			var layerSprite:Sprite;
			
			//var totalT:Number = new Date().time;
			
			invalidateCache();
			
			for each ( layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite;
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.render( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			
			//trace( name + "'s render took (ms): " + (new Date().time -totalT) );
		}
		
		public function renderLayer( layerID:String ):void {
			var layerSprite:Sprite;
			var layer:ILayer;
			for each (layer in _layers) {
				if (layer.id == layerID) {
					break;
				}
			}
			
			invalidateCache();
			
			if (layer) {
				layerSprite = _layerContainer.getChildByName( layerID ) as Sprite;
				if (layer.isSetup(layerSprite)) {
					layer.render( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
					calculateBounds();
					rescale();
				}
			}
			
		}
		
		public function renderOverlays():void {
			var overlay:IOverlay;
			var overlaySprite:Sprite;
			
			for each ( overlay in _overlays) {
				if (overlay.isSetup) {
					overlaySprite = _overlayContainer.getChildByName(overlay.id) as Sprite;
					overlay.render(  overlaySprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
		}
		
		private function invalidateCache():void {
			_layerContainer.cacheAsBitmap = false;
			addEventListener(Event.ENTER_FRAME, recreateCache);
		}
		
		private function recreateCache(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, recreateCache);
			
			var r:Rectangle = _layerContainer.getBounds(stage);
			
			if ((r.width * r.height) < 0xffffff) {
				// Flash-Player-internal caching
				_layerContainer.cacheAsBitmap = true;
				//_layerContainer.visible = true;
				_layerCacheWrapper.visible = false;
				trace("autocache");
			} else {
				// manual caching
				//_layerCacheWrapper.visible = true;
				//_layerContainer.visible = false;
				if (!_layerCache.bitmapData
					|| _layerCache.bitmapData.width != _bg.width
					|| _layerCache.bitmapData.height != _bg.height)
				{
					var b:BitmapData = new BitmapData(_bg.width, _bg.height);
					_layerCache.bitmapData = b;
					//_layerCache.alpha = 0.5;
				}
				/*
				if (_layerCache.bitmapData.width != _bg.width || _layerCache.bitmapData.height != _bg.height) {
					
				}
				*/
				addEventListener(Event.ENTER_FRAME, recreateBitmapCache);
				_layerCacheWrapper.x = 0;
				_layerCacheWrapper.y = 0;
				trace("Manually caching layerContainer with " + Math.sqrt(r.width * r.height) + " square px." + r);
				trace(  _layerContainer.scrollRect );
			}
		}
		
		private function recreateBitmapCache(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, recreateBitmapCache);
			var r:Rectangle = _layerContainer.getBounds(stage);
			//var rBmp:Rectangle = new Rectangle( r.x * -1, r.y*-1, _bg.width, _bg.height);
			var rBmp:Rectangle = new Rectangle( 0, 0, _bg.width, _bg.height);
			_layerCache.bitmapData.fillRect( _layerCache.bitmapData.rect, _bgColor);
			_layerCache.bitmapData.draw( _layerContainerWrapper, null, null, null, rBmp );
			//_layerCacheWrapper.visible = true;
		}
		
		
		override public function get width():Number { return super.width; }
		
		override public function set width(value:Number):void {
			resize(value, _bg.height);
		}
		
		override public function get height():Number { return super.height; }
		
		override public function set height(value:Number):void {
			resize(_bg.width, value);
		}
		
		public function get scale():Number { return _scale; }
		
		public function set scale(value:Number):void {
			if (value != _scale) {
				_scale = value;
				_worldWidth = _bg.width / _scale;
				_worldHeight = _bg.height / _scale;
				calculateBounds();
				
				removeEventListener(Event.ENTER_FRAME, applyRecenter);
				removeEventListener(Event.ENTER_FRAME, applyRescale);
				
				addEventListener(Event.ENTER_FRAME, applyRescale);
			}
		}
		
		public function get centerX():Number { return center.x; }
		
		public function set centerX(value:Number):void {
			center.x = value;
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, applyRecenter);
			}
		}
		
		public function get centerY():Number { return center.y; }
		
		public function set centerY(value:Number):void {
			center.y = value;
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, applyRecenter);
			}
		}
		
		private function applyRecenter(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, applyRecenter);
			calculateBounds();
			recenter();
		}
		
		private function applyRescale(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, applyRecenter);
			removeEventListener(Event.ENTER_FRAME, applyRescale);
			calculateBounds();
			rescale();
		}
		

	}
}