package org.omoa.spacemodel 
{
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.ISpaceModel;
	/**
	 * ...
	 * @author SKS
	 */
	public class SpaceModelClone extends SpaceModel 
	{
		
		public function SpaceModelClone(id:String, bounds:BoundingBox, type:String, entityVector:Vector.<SpaceModelEntity>, recalculateBounds:Boolean = true ) 
		{
			_id = id;
			if (bounds) {
				_bounds = bounds;
			} else {
				_bounds = new BoundingBox(0, 0, 1, 1);
			}
			_type = type;
			entities = entityVector;
			if (recalculateBounds) reinitialize();
			_complete = true;
		}
		
		private function reinitialize():void {
			var r:Rectangle = entities[0].bounds.clone();
			for each (var sme:SpaceModelEntity in entities) {
				r = r.union(sme.bounds as Rectangle);
				sme.model = this;
			}
			_bounds.fromRectangle( r );			
		}
		
	}

}