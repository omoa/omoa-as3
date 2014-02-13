package org.omoa.spacemodel.index 
{
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.spacemodel.AbstractIterator;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * Iterates over a list of SpaceModelEntities from an array of index cells,
	 * therefore entites may appear multiple times.
	 * 
	 * @author SKS
	 */
	public class GridIndexIterator extends AbstractIterator 
	{
		private var index:GridIndex;
		private var cells:Vector.<int>;
		private var entities:Vector.<SpaceModelEntity>;
		
		private var cellIndex:int = 0;
		private var cellCount:int;
		private var entityIndex:int = 0;
		private var entityCount:int;
		
		private var _count:int = -1;
		
		public function GridIndexIterator(gridIndex:GridIndex, cellIDs:Vector.<int>) {
			// we omit the super() by intention
			index = gridIndex;
			cells = cellIDs;
			reset();
		}
		
		override public function next():SpaceModelEntity {
			return entities[entityIndex++];
		}
		
		override public function count():int {
			if (_count > -1) {
				return _count
			}
			_count = 0;
			for (var i:int = 0; i < cells.length; i++) {
				_count += index.getEntities(cells[i]).length;
			}
			return _count;
		}
		
		override public function reset():void {
			cellIndex = 0;
			entityIndex = 0;
			cellCount = cells.length;
			if (cellCount) {
				entities = index.getEntities(cells[cellIndex]);
				entityCount = entities.length;
			} else {
				entityCount = 0;
			}
		}
		
		override public function hasNext():Boolean {
			if (entityIndex < entityCount) {
				return true;
			} else {
				cellIndex++;
				if (cellIndex < cellCount) {
					entities = index.getEntities( cells[cellIndex] );
					entityCount = entities.length;
					if (entityCount > 0) {
						entityIndex = 0;
						return true;
					} else {
						return hasNext();
					}	
				}
			}
			return false;
		}
		
		override public function type():String {
			return "GridIndexIterator";
		}
		
		override public function iterator(type:String = null):ISpaceModelIterator {
			// _entities must be filled first!
			throw new Error("Not implememnted yet!");
			return super.iterator( type );
		}
		
	}

}