package org.omoa.spacemodel.index 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelIndex;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.spacemodel.NullIterator;
	import org.omoa.spacemodel.SpaceModel;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * ...
	 * @author SKS
	 */
	public class GridIndex implements ISpaceModelIndex {
		
		private var xCellCount:int = 0;
		private var yCellCount:int = 0;
		
		private var allEntities:Vector.<SpaceModelEntity>;
		private var cells:Vector.<Vector.<Vector.<SpaceModelEntity>>>;
		
		private var cellSize:Point = new Point();
		private var gridRoot:Point = new Point();
		
		public function GridIndex(xCells:int = 10, yCells:int = 10) {
			xCellCount = xCells;
			yCellCount = yCells;
			if (xCells < 1 || yCells < 1) {
				throw new Error( "Cell count must be greater than zero." );
			}
		}
		
		/* INTERFACE org.omoa.framework.ISpaceModelIndex */
		
		public function createIndex(entities:Vector.<SpaceModelEntity>):void {
			var t:Number = new Date().getTime();
			
			if (!entities) {
				allEntities = null;
				cells = null;
				return;
			}
						
			if (entities.length>0) {
				var sme:SpaceModelEntity = entities[0];
				var cellSizeX:Number = cellSize.x = sme.model.bounds.width / xCellCount;
				var cellSizeY:Number = cellSize.y = sme.model.bounds.height / yCellCount;
				var rootX:Number = gridRoot.x = sme.model.bounds.left;
				var rootY:Number = gridRoot.y = sme.model.bounds.top;
				var x:int, y:int;
				
				cells = new Vector.<Vector.<Vector.<SpaceModelEntity>>>(xCellCount);
				
				// init vectors and cellbounds
				for (x = 0; x < xCellCount; x++) {
					cells[x] = new Vector.<Vector.<SpaceModelEntity>>(yCellCount);
					for (y = 0; y < yCellCount; y++) {
						cells[x][y] = new Vector.<SpaceModelEntity>();
					}
				}
				
				var xMinIndex:int, xMaxIndex:int, yMinIndex:int, yMaxIndex:int;
				var bounds:Rectangle;
				
				for each (var gridEntity:SpaceModelEntity in entities) {	
					bounds = gridEntity.bounds;
					xMinIndex = int((bounds.left - rootX) / cellSizeX); 
					xMaxIndex = int((bounds.right - rootX) / cellSizeX);
					yMinIndex = int((bounds.top - rootY) / cellSizeY); 
					yMaxIndex = int((bounds.bottom - rootY) / cellSizeY);
					if (xMaxIndex >= xCellCount) xMaxIndex = xCellCount-1;
					if (yMaxIndex >= yCellCount) yMaxIndex = yCellCount-1;
					for (y = yMinIndex; y <= yMaxIndex; y++) {
						for (x = xMinIndex; x <= xMaxIndex; x++) {
							cells[x][y].push( gridEntity );
						}
					}
				}
				
				// DEBUG
				trace("Indexing for " + sme.model.id + " took "+(new Date().getTime()-t)+" ms.");
				for (y = 0; y < yCellCount; y++) {
					var output:String = "";
					for (x = 0; x < xCellCount; x++) {
						output += "\t" + cells[x][y].length;
					}
					trace (output);
				}
			} else {
				allEntities = null;
				cells = null;
			}
		}
		
		public function getCells(bounds:Rectangle):Vector.<int> {
			var x:int, y:int;
			var xMinIndex:int, xMaxIndex:int, yMinIndex:int, yMaxIndex:int;
			
			var cellSizeX:Number = cellSize.x;
			var cellSizeY:Number = cellSize.y;
			var rootX:Number = gridRoot.x;
			var rootY:Number = gridRoot.y;
			
			xMinIndex = int((bounds.left - rootX) / cellSizeX); 
			xMaxIndex = int((bounds.right - rootX) / cellSizeX);
			yMinIndex = int((bounds.top - rootY) / cellSizeY); 
			yMaxIndex = int((bounds.bottom - rootY) / cellSizeY);
			if (xMaxIndex >= xCellCount) xMaxIndex = xCellCount-1;
			if (yMaxIndex >= yCellCount) yMaxIndex = yCellCount-1;
			if (xMinIndex < 0) xMinIndex = 0;
			if (yMinIndex < 0) yMinIndex = 0;
			
			var result:Vector.<int> = new Vector.<int>();
			
			for (y = yMinIndex; y <= yMaxIndex; y++) {
				for (x = xMinIndex; x <= xMaxIndex; x++) {
					result.push( y*xCellCount+x );
				}
			}
			return result;
		}
		
		public function getCellsOutside(bounds:Rectangle):Vector.<int> {
			var x:int, y:int;
			var xMinIndex:int, xMaxIndex:int, yMinIndex:int, yMaxIndex:int;
			
			var cellSizeX:Number = cellSize.x;
			var cellSizeY:Number = cellSize.y;
			var rootX:Number = gridRoot.x;
			var rootY:Number = gridRoot.y;
			
			xMinIndex = int((bounds.left - rootX) / cellSizeX); 
			xMaxIndex = int((bounds.right - rootX) / cellSizeX);
			yMinIndex = int((bounds.top - rootY) / cellSizeY); 
			yMaxIndex = int((bounds.bottom - rootY) / cellSizeY);
			if (xMaxIndex >= xCellCount) xMaxIndex = xCellCount-1;
			if (yMaxIndex >= yCellCount) yMaxIndex = yCellCount-1;
			if (xMinIndex < 0) xMinIndex = 0;
			if (yMinIndex < 0) yMinIndex = 0;
			
			var result:Vector.<int> = new Vector.<int>();
			
			for (x = 0; x < xCellCount; x++) {
				for (y = 0; y < yMinIndex; y++) {
					result.push( y*xCellCount+x );
				}
				for (y = yMaxIndex + 1; y < yCellCount; y++) {
					result.push( y*xCellCount+x );
				}
			}
			for (y = yMinIndex; y <= yMaxIndex; y++) {
				for (x = 0; x < xMinIndex; x++) {
					result.push( y*xCellCount+x );
				}
				for (x = xMaxIndex+1; x < xCellCount; x++) {
					result.push( y*xCellCount+x );
				}
			}
			return result;
		}
		
		public function getEntities(cellID:int):Vector.<SpaceModelEntity> {
			if (cells && cellID < xCellCount * yCellCount && cellID > -1) {
				var y:int = cellID / xCellCount;
				var x:int = cellID - y * xCellCount;
				return cells[x][y];
			}
			return null;
		}
		
		public function iterator(bounds:Rectangle, consolidated:Boolean = false):ISpaceModelIterator {
			if (!cells) {
				return new NullIterator();
			}
			if (consolidated)
				return new ConsolidatedGridIndexIterator(this, getCells(bounds));
			else
				return new GridIndexIterator(this, getCells(bounds));
		}
		
		public function iteratorOutside(bounds:Rectangle, consolidated:Boolean = false):ISpaceModelIterator {
			if (!cells) {
				return new NullIterator();
			}
			if (consolidated)
				return new ConsolidatedGridIndexIterator(this, getCellsOutside(bounds));
			else 
				return new GridIndexIterator(this, getCellsOutside(bounds));
		}
		
		public function createGridCellSpaceModel():ISpaceModel {
			var sm:SpaceModel = new SpaceModel();
			//sm.id
			return sm;
		}
		
	}

}