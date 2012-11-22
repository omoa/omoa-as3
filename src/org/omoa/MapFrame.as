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

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import org.omoa.framework.ILayer;
	import org.omoa.framework.IOverlay;
	import org.omoa.framework.IProjection;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.Map;
	import org.omoa.projection.AbstractProjection;
	import org.omoa.framework.BoundingBox;
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
		
		
		private var _layers:Vector.<ILayer> = new Vector.<ILayer>();
		private var _overlays:Vector.<IOverlay> = new Vector.<IOverlay>();
		private var _map:Map;
		
		private var _bg:Shape;
		private var _layerContainerWrapper:Sprite;
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
			//_layerContainer.cacheAsBitmap = true;
			_layerContainerWrapper.addChild( _layerContainer);
			
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
			_bg.graphics.clear();
			_bg.graphics.beginFill(value);
			_bg.graphics.drawRect(0, 0, 1, 1);
			_bg.graphics.endFill();
		}
		
		override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
			//_layerContainer.cacheAsBitmap = true;
			_layerContainer.startDrag(lockCenter, bounds);

			addEventListener(MouseEvent.MOUSE_MOVE, whileDrag);
		}
		
		private function whileDrag(e:MouseEvent):void {
			_overlayContainer.visible = false;
		}
		
		public function followDrag( x:Number, y:Number):void {
			_layerContainer.x = x;
			_layerContainer.y = y;
		}
		
		public function stopFollowDrag():void {
			_layerContainer.x = 0;
			_layerContainer.y = 0;
		}
		
		//TODO: There is an offset involved.
		public function dragPosition():Point {
			return _layerContainer.getRect(this).topLeft; 
		}
		
		override public function stopDrag():void {
			removeEventListener(MouseEvent.MOUSE_MOVE, whileDrag);
			_overlayContainer.visible = true;
			_layerContainer.stopDrag();
			
			//_layerContainer.cacheAsBitmap = false;
			moveCenterByScreenCoordinates( _layerContainer.x*-1, _layerContainer.y*-1 );
			_layerContainer.x = 0;
			_layerContainer.y = 0;
		}
		
		public function addLayer(layer:ILayer):void {
			if (projection.isIdentical(layer.spaceModel.projection)) {
				var layerSprite:Sprite = new Sprite();
				layerSprite.name = layer.id;
				
				_layers.push( layer );
				if (_map) {
					_map.addLayer( layer );
				}
				
				_layerContainer.addChild( layerSprite );
				
				if (layer.spaceModel.isComplete) {
					// set up layer now
					layer.setup( layerSprite );
					renderLayer( layer.id );
				} else {
					// defer layer setup until ISpaceModel is ready
					layer.spaceModel.addEventListener(Event.COMPLETE, setupLayer, false, 100 );
				}
				
			} else {
				throw new Error( "The Projection of the Layers SpaceModel " +
				"does not match the Projection of the MapFrame." );
			}
			
		}
		
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
		
		/**
		 * Initializing all layers with a certain ISpaceModel. The
		 * listener has been registered in addLayer.
		 * 
		 * @param	e	
		 */
		private function setupLayer(e:Event):void {
			var spaceModel:ISpaceModel = e.target as ISpaceModel;
			var layer:ILayer;
			var layerSprite:Sprite;
			
			if (spaceModel) {
				spaceModel.removeEventListener( Event.COMPLETE, setupLayer );
				for each ( layer in _layers) {
					if (layer.spaceModel == spaceModel) {
						layerSprite = _layerContainer.getChildByName(layer.id) as Sprite;
						layer.setup( layerSprite );
						if (isNaN(_scale)) {
							resetBoundsAndScale();
						}
						renderLayer( layer.id );
					}
				}
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
		}
		
		/* ===========================================
		 * Extent Manipulation
		 * =========================================== */
		
		public function resize(widthNew:Number, heightNew:Number):void {
			_bg.width = widthNew;
			_bg.height = heightNew;
			_worldWidth = widthNew / _scale;
			_worldHeight = heightNew / _scale;
			
			_frameDecoration.graphics.clear();
			if (!isNaN(borderColor)) {
				_frameDecoration.graphics.lineStyle(1, borderColor, 1, true);
				_frameDecoration.graphics.drawRect(0, 0, widthNew - 0.55, heightNew - 0.55);
			}
			calculateBounds();
			recenter();
			
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
			
			layerTransformation.tx = ((0 - center.x) - (viewportBounds.minx - center.x)) * _scale;
			layerTransformation.ty = (center.y - (viewportBounds.miny - center.y)) * _scale;
			layerTransformation.a = _scale;
			layerTransformation.d = _scale * -1;
			
		}
		
		private function resetBoundsAndScale():void {
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
				_scale = Math.max( _bg.width / bounds.width, _bg.height / bounds.height ) * 1.0;
			} else {
				_scale = Math.min( _bg.width / bounds.width, _bg.height / bounds.height ) * 1.0;
			}
			
			_referenceScale = _scale;
			
			_minimum_scale = _scale * minZoomFactor;
			_maximum_scale = _scale * maxZoomFactor;
			
			center.x = bounds.minx + bounds.width * 0.5;
			center.y = bounds.maxy - bounds.height * 0.5;
			
			_worldWidth = _bg.width / _scale;
			_worldHeight = _bg.height / _scale;
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
			//_layerContainer.cacheAsBitmap = false;
			for each (layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.rescale( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			renderOverlays();
			//_layerContainer.cacheAsBitmap = true;
			//trace( name + "'s rescale took (ms): " + (new Date().time - totalT) );
		}
		
		/** 
		 * To be called on a change of the map center (panning) or of the map extent (resize).
		 */
		private function recenter():void {
			var layerSprite:Sprite;
			var layer:ILayer;
			
			//var totalT:Number = new Date().time;
			//_layerContainer.cacheAsBitmap = false;
			for each (layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.recenter( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			renderOverlays();
			//_layerContainer.cacheAsBitmap = true;
			//trace( name + "'s recenter took (ms): " + (new Date().time -totalT) );
		}
		
		// Aushilfsweise: Rendern auslösen (nach Daten-Änderung z.B.
		public function reRender():void {
			render();
		}
		
		private function render():void {
			var layer:ILayer;
			var layerSprite:Sprite;
			
			//var totalT:Number = new Date().time;
			//_layerContainer.cacheAsBitmap = false;
			for each ( layer in _layers) {
				layerSprite = _layerContainer.getChildByName(layer.id) as Sprite;
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.render( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
				}
			}
			//_layerContainer.cacheAsBitmap = true;
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
			//_layerContainer.cacheAsBitmap = false;
			if (layer) {
				layerSprite = _layerContainer.getChildByName( layerID ) as Sprite;
				if (layer.isSetup(layerSprite) && layerSprite.visible) {
					layer.render( layerSprite, _bg.getRect( stage ), viewportBounds, layerTransformation );
					calculateBounds();
					rescale();
				}
			}
			//_layerContainer.cacheAsBitmap = true;
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