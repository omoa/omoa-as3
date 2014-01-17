package org.omoa.spacemodel 
{
	import org.omoa.framework.BoundingBox;
	/**
	 * ...
	 * @author SKS
	 */
	public class SpaceModelClone extends SpaceModel 
	{
		
		public function SpaceModelClone(id:String, bounds:BoundingBox, type:String, entityVector:Vector.<SpaceModelEntity> ) 
		{
			_id = id;
			_bounds = bounds;
			_type = type;
			entities = entityVector;
			_complete = true;
		}
		
	}

}