package org.omoa.framework 
{
	import flash.geom.Rectangle;
	import org.omoa.spacemodel.SpaceModelEntity;
	
	/**
	 * ...
	 * @author SKS
	 */
	public interface ISpaceModelIndex 
	{
		function createIndex(entities:Vector.<SpaceModelEntity>):void;
		function getCells(bounds:Rectangle):Vector.<int>;
		function getCellsOutside(bounds:Rectangle):Vector.<int>;
		function getEntities(cellID:int):Vector.<SpaceModelEntity>;
		
		function iterator(bounds:Rectangle):ISpaceModelIterator;
		function iteratorOutside(bounds:Rectangle):ISpaceModelIterator;
	}
	
}