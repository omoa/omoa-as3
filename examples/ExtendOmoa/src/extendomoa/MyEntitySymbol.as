package extendomoa 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.spacemodel.SpaceModelEntity;
	/**
	 * ...
	 * @author SKS
	 */
	public class MyEntitySymbol extends MySymbol 
	{
		
		public function MyEntitySymbol() 
		{
			super();
			
			_entities = true;
			_interactive = false;
			_transform = true; 	//true
			_rescale = true;	//
			_recenter = true;	//true
		}
		
		override public function setupEntity(parentSprite:Sprite, spaceEntity:SpaceModelEntity):DisplayObject {
			var entitySprite:Sprite = new Sprite();
			entitySprite.name = spaceEntity.id;
			parentSprite.addChild( entitySprite );
			return entitySprite;
		}
		
		override public function prepareRender(parentSprite:Sprite):void {
			var childSprite:Sprite;
			for (var i:int = 0; i < parentSprite.numChildren; i++) {
				childSprite = parentSprite.getChildAt(i) as Sprite;
				childSprite.graphics.clear();
			}
		}
		
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, transformation:Matrix):void 
		{
			var s:Sprite = target as Sprite;
			
			s.graphics.beginFill( color, 0.2);
			
			s.graphics.drawRoundRect(
				spaceEntity.bounds.width*-0.5, spaceEntity.bounds.height*-0.5,
				spaceEntity.bounds.width, spaceEntity.bounds.height,
				10, 10 );
			
			s.graphics.endFill();
			
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;	
		}
		
		
		override public function rescale(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;
		}
		
		override public function recenter(target:DisplayObject, spaceEntity:SpaceModelEntity, displayExtent:Rectangle, viewportBounds:BoundingBox, transformation:Matrix):void {
			var p:Point = transformation.transformPoint( spaceEntity.center );
			target.x = p.x;
			target.y = p.y;	
		}
	}

}