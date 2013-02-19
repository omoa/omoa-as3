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
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import org.omoa.*;
	import org.omoa.datamodel.AbstractDMLoader;
	import org.omoa.framework.*;
	import org.omoa.layer.AbstractLayer;
	import org.omoa.layer.SymbolLayer;
	import org.omoa.spacemodel.AbstractSMLoader;
	import org.omoa.util.NavigationButtons;
	
	/**
	 * This class is the main dispatcher object of an omoa map.
	 * 
	 * @author Sebastian Specht
	 *
	 */

	public class Map extends Sprite {
		
		public var synchronizeMapFrames:Boolean = false;
		public var mapframeMargin:int = 10;

		protected var layers:Vector.<ILayer> = new Vector.<ILayer>();
		protected var spaceModels:Vector.<ISpaceModel> = new Vector.<ISpaceModel>();
		protected var dataModels:Vector.<IDataModel> = new Vector.<IDataModel>();
		
		protected var mapFrames:Vector.<MapFrame> = new Vector.<MapFrame>();
		
		private var _width:Number=1;
		private var _height:Number=1;
		
		private var bgShape:Shape;
		private var debugBox:TextField;
		
		private var dragMapFrame:MapFrame;
		private var clickTimer:Timer;
		private var clickEventBuffer:MouseEvent;
		private var clickEventMapFrame:MapFrame;
		private var clickEventStageCoordinates:Point = new Point();
		
		public function Map() {
			
			/*
			
			debugBox = new TextField();
			debugBox.name = "debugBox";
			var tf:TextFormat = debugBox.defaultTextFormat;
			tf.size = 8;
			tf.font = "_typewriter";
			
			debugBox.defaultTextFormat = tf;
			debugBox.autoSize = TextFieldAutoSize.LEFT;
			debugBox.multiline = true;
			debugBox.appendText("Hallo Welt!");
			addChild(debugBox);
			
			*/
		}
		
		// ===================================================================
		// MapFrame Management
		
		/**
		 * Adds a MapFrame to the mapframe pool and, if it is has no parent 
		 * display object, adds it as child to the display list. The layers of
		 * the MapFrame are added to the layer pool of the map.
		 * 
		 * @param	mapFrame The map frame.
		 * @param	name An identifier (unique among the MapFrames).
		 */
		public function addMapFrame( mapFrame:MapFrame, name:String = null ):void {
			// check uniqueness of name
			for each (var mf:MapFrame in mapFrames) {
				if (mf.name == name) {
					throw new Error(" MapFrame name '" + name + "' is not unique.");
				}
				if (mf.name == mapFrame.name) {
					throw new Error(" MapFrame name '" + mapFrame.name + "' is not unique.");
				}
			}
			
			if (name) {
				mapFrame.name = name;
			} else if (!mapFrame.name) {
				mapFrame.name = "MapFrame" + mapFrames.length;
			}
			
			mapFrames.push( mapFrame );
			
			mapFrame.setMap( this );
			
			// add to display list, if not done already (or somewhere else)
			if (!mapFrame.parent) {
				addChild( mapFrame );
			}
			
			_mapFrameAddInteractivity( mapFrame );			
			
			for (var index:int = 0; index < mapFrame.countLayers(); index++) {
				addLayer( mapFrame.getLayer(index) );
			}
			
			mapFrame.addEventListener( Event.SCROLL, mapFrameCenterChange);
			mapFrame.addEventListener( Event.CHANGE, mapFrameChange);
			
			if (synchronizeMapFrames && mapFrames.length > 1) {
				var preMF:MapFrame = mapFrames[mapFrames.length - 2];
				mapFrame.setCenterByMapCoordinates( preMF.center.x, preMF.center.y, preMF.scale );
			}
		}
		
		/**
		 * Creates a new MapFrame as a child sprite of the map sprite and adds it to
		 * the internal list on mapframes.
		 * 
		 * @param	name The name of the mapframe.
		 * @return	The MapFrame.
		 */
		public function createMapFrame( name:String ):MapFrame {
			var mf:MapFrame;
			
			// check uniqueness of name
			for each (mf in mapFrames) {
				if (mf.name == name) {
					throw new Error(" MapFrame name '" + name + "' is not unique.");
				}
			}
			
			mf = new MapFrame(this);
			mf.name = name;
			addMapFrame( mf );
			
			layoutMapFrames();
			
			return mf;
		}
		
		/**
		 * Adds event handlers to a MapFrame.
		 */
		protected function _mapFrameAddInteractivity( mf:MapFrame ):void {
			mf.buttonMode = true;
			mf.mouseChildren = true;
			
			//mf.addEventListener(MouseEvent.CLICK, frameClick);
			mf.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			//mf.addEventListener(MouseEvent.MOUSE_UP, clickStartsTimer, false, 1);
			
			//mf.addEventListener(MouseEvent.MOUSE_UP, stopDragging, false, 10000);
			
			//mf.doubleClickEnabled = true;
			//mf.addEventListener(MouseEvent.DOUBLE_CLICK, frameClick);// frameDoubleClick);
			
			
			
			clickTimer = new Timer( 250, 1 );
			//mf.addEventListener(MouseEvent.CLICK, clickStartsTimer, false, 10000);
			clickTimer.addEventListener(TimerEvent.TIMER, clickTimerFired);
			
			mf.addEventListener(MouseEvent.MOUSE_WHEEL, frameWheel);
		}
		
		/**
		 * Returns a mapframe by name.
		 * 
		 * @param	name The name of the mapframe.
		 * @return	The MapFrame.
		 */
		public function mapframe( name:String ):MapFrame {
			for each (var mf:MapFrame in mapFrames) {
				if (mf.name == name) {
					return mf;
				}
			}
			throw new Error( "MapFrame " + name + " does not exist." );
			return null;
		}
		
		/**
		 * Returns the number of mapframes.
		 */
		public function countMapFrames():uint {
			return mapFrames.length;
		}
		
		/**
		 * Returns a mapframe by index.
		 */
		public function getMapFrame( index:uint ):MapFrame {
			if (index < mapFrames.length) {
				return mapFrames[index];
			}
			return null;
		}
		
		/**
		 * Layout all MapFrames (that are child sprites of the map) horizontaly
		 * with equal width. This layout is a fixed behaviour at the moment. If
		 * you want your own layout you either subclass Map or you add the MapFrame to
		 * another DisplayObjectContainer and do the layout for yourself.
		 */
		public function layoutMapFrames():void {
			_layoutMapFrames();
		}
		protected function _layoutMapFrames():void {
			var mf:MapFrame;
			var mfCountChild:int = 0;
			for each (mf in mapFrames) {
				if (mf.parent == this) { mfCountChild++; }
			}
			var mfWidth:Number = (_width - (mfCountChild + 1) * mapframeMargin) / mfCountChild;
			var count:int;
			
			for each (mf in mapFrames) {
				// only layout mapframes that are children of the map sprite
				if (mf.parent == this) {
					mf.y = mapframeMargin;
					mf.x = 1 + mapframeMargin + mfWidth * count + mapframeMargin * count;
					
					mf.resize( mfWidth, _height - 2 * mapframeMargin );
					
					count++;
				}
			}
		}
		
		// ===================================================================
		// MapFrame Event handling
		
		/**
		 * Starts a dragging action.
		 */
		private function startDragging(e:MouseEvent):void {
			// add drag-edn as well as "normal" click behaviour
			dragMapFrame = e.currentTarget as MapFrame;
			
			if (dragMapFrame) {
				if (synchronizeMapFrames) {
					dragMapFrame.startDrag();
				} else {
					dragMapFrame.startDrag();
				}
				dragMapFrame.addEventListener(MouseEvent.MOUSE_MOVE, whileDragging);
				dragMapFrame.addEventListener(MouseEvent.MOUSE_UP, clickStartsTimer);
			}
		}
		
		/**
		 * Handles the a dragging action.
		 */
		private function whileDragging(e:MouseEvent):void {
			// this is a definitely drag action.
			// stop drag behaviour...
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging, true );
			
			// ...and remove the normal "click" behaviour
			if (dragMapFrame) {
				dragMapFrame.removeEventListener(MouseEvent.MOUSE_UP, clickStartsTimer);
				//stage.quality = StageQuality.LOW;
				if (synchronizeMapFrames) {
					// This does not really work
					/*
					var p:Point = dragMapFrame.dragPosition();
					for each (var mf:MapFrame in mapFrames) {
						if (mf != dragMapFrame) {
							mf.followDrag( p.x, p.y );
						}
					}
					*/
				}
			}
		}
		
		/**
		 * Handles the end of a dragging action.
		 */
		private function stopDragging(e:MouseEvent):void {
			// the drag action has ended.
			var mf:MapFrame;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging, true);
			
			if (dragMapFrame) {
				e.stopImmediatePropagation();
				dragMapFrame.removeEventListener(MouseEvent.MOUSE_MOVE, whileDragging);
				//stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
				
				if (synchronizeMapFrames) {
					dragMapFrame.stopDrag();
					for each (mf in mapFrames) {
						if (mf != dragMapFrame) {
							mf.stopFollowDrag();
							mf.setCenterByMapCoordinates(  dragMapFrame.center.x, dragMapFrame.center.y );
						}
					}
				} else {
					dragMapFrame.stopDrag();
				}
				clickTimer.reset();
				//stage.quality = StageQuality.HIGH;
			}
			//e.stopPropagation();
			//e.stopImmediatePropagation();
			dragMapFrame = null;
			//TODO: Syncronize mapframes?
		}
		
		/**
		 * Handles click / doubleclick logic.
		 */
		private function clickStartsTimer(e:MouseEvent):void {
			// the mouse button has been released, but the 			
			// mouse has not moved: remove the drag-handlers
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			dragMapFrame.stopDrag();
			dragMapFrame.removeEventListener(MouseEvent.MOUSE_MOVE, whileDragging);
			dragMapFrame = null;
			
			if (e.currentTarget is MapFrame && !(e.target.parent is NavigationButtons) ) {	
				// timer-based double click logic
				if (clickTimer.running) {
					// handle double click
					clickTimer.reset();
					frameDoubleClick(e);
					clickEventBuffer = null;
					clickEventMapFrame = null;
				} else {
					// start timer and wait for clickTimerFired() or a new click
					clickTimer.start();
					clickEventBuffer = e.clone() as MouseEvent;
					clickEventMapFrame = e.currentTarget as MapFrame;
					clickEventStageCoordinates.x = e.stageX;
					clickEventStageCoordinates.y = e.stageY;
				}
			}
		}
		
		/**
		 * Handles timer based clicks.
		 */
		private function clickTimerFired(e:TimerEvent):void {
			clickTimer.reset();
			clickEventMapFrame = null;
			clickEventBuffer = null;
			// handle single click here
		}
		
		/**
		 * Unused an not working. Centers the map on click. Need an mouse event.
		 */
		private function frameClick(e:MouseEvent=null):void {
			var mf:MapFrame;
			var p:Point;
			
			mf = e.currentTarget as MapFrame;
			trace( "click " + e.stageX, e.stageY );
			if (mf) {
				
				p = new Point( e.stageX, e.stageY );
				p = mf.globalToLocal( p );
			} else {
				mf = clickEventMapFrame;
				if (mf) {
					p = new Point( clickEventStageCoordinates.x, clickEventStageCoordinates.y );
					p = mf.globalToLocal( p );
				}
				return;
			}
			
			if (synchronizeMapFrames) {
				for each(mf in mapFrames) {
					if (!e.altKey) {
						mf.setCenterByScreenCoordinates( p.x, p.y );
						if (e.shiftKey) {
							mf.zoomIn();
						}
						if (e.ctrlKey) {
							mf.zoomOut();
						}
						//e.stopPropagation();
					}
				}
			} else {
				if (!e.altKey) {
					mf.setCenterByScreenCoordinates( p.x, p.y );
					if (e.shiftKey) {
						mf.zoomIn();
					}
					if (e.ctrlKey) {
						mf.zoomOut();
					}
				}
			}
			
			//e.stopImmediatePropagation();
		}
		
		/**
		 * Centers the map and zooms in (Ctrl: zoom out) on double click.
		 * @param	e	
		 */
		private function frameDoubleClick(e:MouseEvent=null):void {
			var mf:MapFrame;
			var p:Point;
			
			mf = e.currentTarget as MapFrame;
			if (!mf) {
				mf = clickEventMapFrame;
			}
			if (mf) {
				p = new Point( e.stageX, e.stageY );
				p = mf.globalToLocal( p );
			} else {
				return;
			}
			
			if (synchronizeMapFrames) {
				for each(mf in mapFrames) {
					mf.setCenterByScreenCoordinates( p.x, p.y );
					if (e.ctrlKey) {
						mf.zoomOut();
					} else {
						mf.zoomIn();
					}
				}
			} else {
				mf.setCenterByScreenCoordinates( p.x, p.y );
				if (e.ctrlKey) {
					mf.zoomOut();
				} else {
					mf.zoomIn();
				}
			}
		}
		
		/**
		 * Handles mouse wheel action.
		 * 
		 * @param	e	MouseEvent from the wheel.
		 */
		private function frameWheel(e:MouseEvent):void {
			var mf:MapFrame;
			if (synchronizeMapFrames) {
				for each(mf in mapFrames) {
					mf.zoom(1.0+(e.delta/20));
				}
			} else {
				mf = e.currentTarget as MapFrame;
				
				if (!mf) {
					// if the event originates from another Object
					// the search is a bit more complicated
					search: for each(mf in mapFrames) {
						if(mf.hitTestPoint(e.stageX, e.stageY)) {
							break search;
						}
					}
				}
				if (mf) {
					//mf.setCenterByScreenCoordinates( e.localX, e.localY );
					mf.zoom(1.0 + (e.delta / 20));
				}
			}
		}
		
		
		private function mapFrameChange(e:Event):void {
			var sourceMapFrame:MapFrame = e.currentTarget as MapFrame;
			if (sourceMapFrame && synchronizeMapFrames) {
				for each (var mf:MapFrame in mapFrames) {
					if (mf != sourceMapFrame) {
						mf.setCenterByMapCoordinates( sourceMapFrame.center.x, sourceMapFrame.center.y, sourceMapFrame.scale );
					}
				}
			}
		}
		
		private function mapFrameCenterChange(e:Event):void {
			var sourceMapFrame:MapFrame = e.currentTarget as MapFrame;
			if (sourceMapFrame && synchronizeMapFrames) {
				for each (var mf:MapFrame in mapFrames) {
					if (mf != sourceMapFrame) {
						mf.setCenterByMapCoordinates( sourceMapFrame.center.x, sourceMapFrame.center.y, sourceMapFrame.scale );
					}
				}
			}
		}
		
		
		
		
		// ===================================================================
		// Layer Management

		/**
		 * Adds a new layer to the layer pool and stores its the space model. Remember: For
		 * layers to be displayed you need to add them to a MapFrame.
		 * 
		 * @param	layer
		 */
		public function addLayer(layer:ILayer):void {			
			if (layers.indexOf(layer) < 0) {
				// check uniqueness of name
				for each (var layr:ILayer in layers) {
					if (layr.id == layer.id) {
						throw new Error(" Layer name '" + layer.id + "' is not unique.");
					}
				}
				layers.push( layer );
			}
			addSpaceModel( layer.spaceModel );
		}
		
		/**
		 * Creates a new layer of the given class and adds it to the internal layer pool. Remember: For
		 * layers to be displayed you need to add them to a MapFrame.
		 * 
		 * @param	name	An unique layer identifier.
		 * @param	spaceModel	An ISpaceModel instance (or the ID-String of one).
		 * @param	layerClassName The Classname of the layer. If the layer is not from the omoa namespace
		 * 							you need to include the full package name.
		 * @return The layer created. You don't need to necessarily need to store it.
		 * 				You can fetch it any time by calling <code>map.layer("layer name")</code>.
		 */
		public function createLayer(name:String, spaceModel:ISpaceModel=null, layerClassName:String="SymbolLayer"):ILayer {
			var layerClass:Class;
			var layer:ILayer;
			
			// check uniqueness of name
			for each (layer in layers) {
				if (layer.id == name) {
					throw new Error(" Layer name '" + name + "' is not unique.");
				}
			}
			
			layer = AbstractLayer.create( layerClassName, name, spaceModel );
			
			if (layer) {
				layers.push(layer);
				if (spaceModel) {
					addSpaceModel( spaceModel );
				}
			} else {
				throw new Error(" Layer '" + name + "' not created.");
			}
			
			return layer;
		}
		
		/**
		 * Returns a layer from the layer pool.
		 * 
		 * @param	name The name of the layer.
		 * @return The layer instance.
		 */
		public function layer(name:String):ILayer {
			for each (var layer:ILayer in layers) {
				if (layer.id == name) {
					return layer;
				}
			}
			throw new Error( "Layer " + name + " does not exist." );
			return null;
		}
		
		/**
		 * Returns a layer from the layer pool as SymbolLayer.
		 * Convenience function.
		 * 
		 * @param	name The name of the layer.
		 * @return The layer instance.
		 */
		public function symbolLayer(name:String):SymbolLayer {
			var layer:ILayer = layer(name);
			if (layer is SymbolLayer) {
				return layer as SymbolLayer;
			} else {
				throw new Error( "SymbolLayer " + name + " does not exist." );
			}
			return null;
		}
		
		/**
		 * Returns the number of layers in the layer pool.
		 * 
		 * @return
		 */
		public function countLayers():uint {
			return layers.length;
		}
		
		/**
		 * Returns a layer by index.
		 * 
		 * @param	index The index of the layer in the layer pool.
		 * @return  The layer.
		 */
		public function getLayer(index:uint):ILayer {
			if (index < layers.length) {
				return layers[index];
			}
			return null;
		}
		
		// ===================================================================
		// Model Management

		/**
		 * Adds a SpaceModel to the SpaceModel pool of the map and links
		 * it to existing DataModels. SpaceModels and 
		 * DataModels in the model pool are linked against each other using
		 * matching SpaceModel-Ids and Classification-Id (must be the first
		 * dimension of the DataModel).
		 * 
		 * @see org.omoa.spacemodel.SpaceModel SpaceModel linkDataModel
		 * 
		 * @param	spaceModel The SpaceModel to be added.
		 */
		public function addSpaceModel(spaceModel:ISpaceModel):void {
			
			if (spaceModels.indexOf(spaceModel) < 0) {
				// check uniqueness of name
				for each (var sm:ISpaceModel in spaceModels) {
					if (sm.id == spaceModel.id) {
						throw new Error(" SpaceModel name '" + spaceModel.id + "' is not unique.");
					}
				}
				
				spaceModels.push( spaceModel );
				if (!spaceModel.isComplete) {
					spaceModel.addEventListener( Event.COMPLETE, eventSpaceModelComplete, false, 1000 );
				} else {
					linkModels(spaceModel);
				}
			}	
		}
		
		/**
		 * Creates a SpaceModel and adds it to the map.
		 * 
		 * @param	name	A name that is unique among the SpaceModels of the map.
		 * @param	url		An Url that is passed to the loader.
		 * @param	parameters	The parameters for the loader.
		 * @param	loaderClassName	The class name of the loader: "Shapefile", "RasterSpaceModel" or "AsmaSpaceXml"
		 * @return	Returns the ISpaceModel(Loader)
		 */
		public function createSpaceModel( name:String, url:String, parameters:Object = null, loaderClassName:String = "Shapefile" ):ISpaceModel {
			var spaceModel:ISpaceModel;
			var loader:ISpaceModelLoader;
			
			// check uniqueness of name
			for each (spaceModel in spaceModels) {
				if (spaceModel.id == name) {
					throw new Error(" SpaceModel name '" + name + "' is not unique.");
				}
			}
			
			// create loader
			loader = AbstractSMLoader.create( loaderClassName, name );
			spaceModel = loader as ISpaceModel;
			
			// load
			if (loader) {
				addSpaceModel( spaceModel );
				loader.load( url, parameters );
			} else {
				throw new Error(" SpaceModel '" + name + "' not created.");
			}
			
			return spaceModel;
		}
		
		/**
		 * Returns an ISpaceModel instance from the model pool.
		 * 
		 * @param	name The name of the ISpaceModel.
		 * @return
		 */
		public function spacemodel( name:String ):ISpaceModel {
			for each (var spaceModel:ISpaceModel in spaceModels) {
				if (spaceModel.id == name) {
					return spaceModel;
				}
			}
			throw new Error( "SpaceModel '" + name + "' does not exist." );
			return null;
		}
		
		/**
		 * Event handler for defered initialization of SpaceModels.
		 */
		private function eventSpaceModelComplete(e:Event):void {
			var sm:ISpaceModel = e.target as ISpaceModel;
			if (sm) {
				sm.removeEventListener( Event.COMPLETE, eventSpaceModelComplete );
				linkModels( sm );
			}
		}

		public function addDataModel(dataModel:IDataModel):void {
			if (dataModels.indexOf(dataModel) < 0) {
				// check uniqueness of name
				for each (var dm:IDataModel in dataModels) {
					if (dataModel.id == dm.id) {
						throw new Error(" DataModel name '" + dataModel.id + "' is not unique.");
					}
				}
				
				dataModels.push( dataModel );
				if (!dataModel.isComplete) {
					dataModel.addEventListener( Event.COMPLETE, eventDataModelComplete, false, 1000 );
				} else {
					linkModels( dataModel );
				}
			}
		}
		
		public function createDataModel( name:String, url:String, parameters:Object, loaderClassName:String = "Text" ):IDataModel {
			var dataModel:IDataModel;
			var loader:IDataModelLoader;
			
			// check uniqueness of name
			for each (dataModel in dataModels) {
				if (dataModel.id == name) {
					throw new Error(" SpaceModel name '" + name + "' is not unique.");
				}
			}
			
			// create loader
			loader = AbstractDMLoader.create( loaderClassName, name );
			dataModel = loader as IDataModel;
			
			// load
			if (loader) {
				addDataModel( dataModel );
				loader.load( url, parameters );
			} else {
				throw new Error(" DataModel '" + name + "' not created.");
			}
			
			return dataModel;
		}
		
		public function datamodel( name:String ):IDataModel {
			for each (var dataModel:IDataModel in dataModels) {
				if (dataModel.id == name) {
					return dataModel;
				}
			}
			throw new Error( "DataModel '" + name + "' does not exist." );
			return null;
		}
		
		/**
		 * Event handler for defered initialization of DataModels.
		 */
		private function eventDataModelComplete(e:Event):void {
			var dm:IDataModel = e.target as IDataModel;
			if (dm) {
				dm.removeEventListener( Event.COMPLETE, eventSpaceModelComplete );
				linkModels( dm );
			}
		}
		
		private function linkModels(model:* = null):void {
			
			var spaceModel:ISpaceModel;
			var dataModel:IDataModel;
			
			if (!model) {
				for each (spaceModel in spaceModels) {
					for each (dataModel in dataModels) {
						if (dataModel.isComplete) {
							spaceModel.linkDataModel( dataModel );
						}
					}
				}
			} else if (model is ISpaceModel) {
				spaceModel = model as ISpaceModel;
				for each (dataModel in dataModels) {
					if (dataModel.isComplete) {
						spaceModel.linkDataModel( dataModel );
					}
				}
			} else if (model is IDataModel) {
				dataModel = model as IDataModel;
				for each (spaceModel in spaceModels) {
					if (spaceModel.isComplete) {
						spaceModel.linkDataModel( dataModel );
					}
				}
			}
		}
		
		// ===================================================================
		// DisplayObject Management
		
		/**
		 * Resizes the map object and calls layoutMapFrames().
		 * 
		 * @param	width	Width of the whole map, including mapframeMargin
		 * @param	height
		 */
		public function resize( width:Number, height:Number ):void {
			_width = width;
			_height = height;
			layoutMapFrames();
		}
		
		override public function get height():Number { return _height; }
		
		override public function set height(value:Number):void 
		{
			_height = value;
		}
		
		override public function get width():Number { return _width; }
		
		override public function set width(value:Number):void 
		{
			_width = value;
		}

		// ===================================================================
		// Debug
		
		public function updateDebug():void {
			var text:String;
			
			text = "SpaceModel (" + spaceModels.length + ") ================================\r";
			for each (var sm:ISpaceModel in spaceModels) {
				text += sm.id + ": " + sm.entityCount() + " (" + sm.geometryType + ") entities. bounds: " + sm.bounds + "\r";
			}
			
			text += "\rDataModel (" + dataModels.length + ") ================================\r";
			for each (var dm:IDataModel in dataModels) {
				text += dm.id + ": propertyDims " + dm.propertyDimensionCount() + ", valueDims " + dm.valueDimensionCount() + "\r";
			}
			
			text += "\rMapFrame (" + mapFrames.length + ") ================================\r";
			for each (var mf:MapFrame in mapFrames) {
				text += mf.name + ": " + mf.bounds + "\r";
				text += "        " + mf.viewportBounds + " " + mf.transformation.matrix + "\r";
				text += "     at " + mf.getBounds(this.stage) + "\r";
			}
			
			if (debugBox) {
				debugBox.text = text;
				debugBox.x = debugBox.y = mapframeMargin;
			}
		}
	}
}