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

package org.omoa.overlay {
	
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsPath;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.omoa.framework.IOverlay;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.spacemodel.BoundingBox;
	
	
	/**
	 * [SUPERALPHA] Visualizes a coordinate grid.
	 * 
	 * @see org.omoa.framework.IOverlay IOverlay
	 * 
	 * @author Sebastian Specht
	 */
	
	public class Gridlines implements IOverlay {
		
		private var _id:String;
		private var _spaceModel:ISpaceModel;
		private var _isSetup:Boolean = false;
		private var _gridLines:Array;	
		
		public function Gridlines( id:String, spaceModel:ISpaceModel, gridLines:Array = null ) {
			_id = id;
			_spaceModel = spaceModel;
			if (!gridLines) {
				//TODO: do during setup and derive meaningful values from SpaceModel.bounds
				_gridLines = new Array(30, 10, 1);
			} else {
				_gridLines = gridLines;
			}
		}
		
		public function get spaceModel():ISpaceModel { return _spaceModel; }
		
		public function get id():String { return _id; }
		
		public function get isSetup():Boolean { return _isSetup; }
		
		public function setup(sprite:Sprite):void {
			var stroke:GraphicsStroke = new GraphicsStroke( 0 );
			var strokefill:GraphicsSolidFill = new GraphicsSolidFill(0x000099, 0.05);
			
			var linesPerWidth:int;
			var linesPerHeight:int;
			var shape:Shape;
			var path:IGraphicsPath;
			var commands:Vector.<int>;
			var pathdata:Vector.<Number>;
			
			var rect:Rectangle;
			var line:int;
			var x:Number;
			var y:Number;
			
			stroke.fill = strokefill;
			stroke.scaleMode = LineScaleMode.NONE;
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0, 0, 1, 1);
			mask.graphics.endFill();
			mask.visible = false;
			sprite.mask = mask;
			sprite.addChild( mask );
			
			for each (var gridWidth:Number in _gridLines) {
				shape = new Shape();
				sprite.addChild(shape);
				
				rect = _spaceModel.bounds as Rectangle;
				linesPerWidth = rect.width / gridWidth + 1.5;
				linesPerHeight = rect.height / gridWidth + 1.5;
				
				pathdata = new Vector.<Number>;
				commands = new Vector.<int>;
				
				//TODO: Elaborate for projected grids
				
				for (line = 0; line < linesPerWidth; line++) {
					x = rect.left + line * gridWidth;
					
					commands.push( GraphicsPathCommand.MOVE_TO );
					pathdata.push(x); // x
					pathdata.push(rect.top); // y
					
					commands.push( GraphicsPathCommand.LINE_TO );
					pathdata.push(x); // x
					pathdata.push(rect.bottom); // y
				}
				
				for (line = 0; line < linesPerHeight; line++) {
					y = rect.top + line * gridWidth;
					
					commands.push( GraphicsPathCommand.MOVE_TO );
					pathdata.push(rect.left);
					pathdata.push(y);
					
					commands.push( GraphicsPathCommand.LINE_TO );
					pathdata.push(rect.right);
					pathdata.push(y);
				}
				
				path = new GraphicsPath(commands, pathdata);
				
				var graphic:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
				
				graphic.push(stroke);
				graphic.push(path);
				
				shape.graphics.drawGraphicsData( graphic );
			}
			
			
			_isSetup = true;
		}
		
		public function deconstruct(sprite:Sprite):void {
			// does this work? :-)
			while (sprite.numChildren) {
				sprite.removeChildAt(0);
			}
		}
		
		public function render(sprite:Sprite, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var gridWidth:Number;
			var numGrids:int = _gridLines.length;
			var shape:Shape;
			
			sprite.mask.width = displayExtent.width;
			sprite.mask.height = displayExtent.height;
			
			trace( displayExtent );
			trace(sprite.mask.getBounds( sprite.stage ));
			
			for (var i:int = 0; i < numGrids; i++ ) {
				gridWidth = _gridLines[i];
				shape = sprite.getChildAt(i+1) as Shape;
				
				if ( int(gridWidth * transformation.a) > 15 ) {
					shape.visible = true;
				} else {
					shape.visible = false;
				}
				shape.transform.matrix = transformation;
			}
		}


		
	}

}