package org.omoa.spacemodel.index 
{
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.spacemodel.iterator.SimpleIterator;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * Iterates over a consolidated list (no double entities) of SpaceModelEntities
	 * from an array of index cells. The creation gets very expensive (slow!) for a higher number of
	 * entities.
	 * 
	 * @author SKS
	 */
	public class ConsolidatedGridIndexIterator extends SimpleIterator {
		
		
		public function ConsolidatedGridIndexIterator(gridIndex:GridIndex, cellIDs:Vector.<int>) {
			super(init(gridIndex, cellIDs));
		}
		
		private function init(gridIndex:GridIndex, cellIDs:Vector.<int>):Vector.<SpaceModelEntity> {
			var entities:Vector.<SpaceModelEntity> = new Vector.<SpaceModelEntity>();
			var cellEntities:Vector.<SpaceModelEntity>;
			var cellCount:int = cellIDs.length;
			var entityCount:int;
			var entity:SpaceModelEntity;
			
			for (var i:int = 0; i < cellCount; i++) {
				cellEntities = gridIndex.getEntities(cellIDs[i]);
				entityCount = cellEntities.length;
				for (var j:int = 0; j < entityCount; j++) {
					entity = cellEntities[j];
					if (entities.indexOf(entity) == -1) {
						entities.push(entity);
					}
				}
			}
			return entities;
		}
		
		override public function type():String {
			return "ConsolidatedGridIndexIterator";
		}
		
	}

}