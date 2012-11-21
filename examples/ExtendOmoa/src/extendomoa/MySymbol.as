package extendomoa 
{
	import flash.geom.Matrix;
	import org.omoa.spacemodel.SpaceModelEntity;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import org.omoa.framework.ISymbol;
	import org.omoa.framework.SymbolProperty;
	import org.omoa.framework.SymbolPropertyType;
	import org.omoa.symbol.AbstractSymbol;
	
	/**
	 * ...
	 * @author SKS
	 */
	public class MySymbol extends AbstractSymbol implements ISymbol 
	{
		public const COLOR:String = "color";
		
		protected var color:uint = 0xff0000;
		
		public function MySymbol() 
		{
			_symbolProperties = new Vector.<SymbolProperty>(1, true);
			
			_symbolProperties[0] = new SymbolProperty();
			_symbolProperties[0].name = COLOR;
			_symbolProperties[0].type = SymbolPropertyType.VALUE;
			
			super();
			
			// The SymbolLayer needs to know how to treat this symbol.
			// The following properties store this information.
			
			// Should the layer treat the symbol individually for each SpaceModelEntity?
			_entities = false;	
			
			// Should the layer call the rescale function?
			_rescale = false;
			
			// Should the layer call the recenter function?
			_recenter = false;
			
			// Should the layer enable interactivity?
			_interactive = false;
			
			// Should the layer apply the transformation matrix?
			_transform = true;
		}
		
		override protected function setStaticProperty(property:SymbolProperty):void {
			switch (property.name) {
				case COLOR: color = Number(property.manipulator.value); break;
			}
		}
		
		override public function prepareRender(parentSprite:Sprite):void 
		{
			// Before the symbol is rendered we clear the graphics.
			// This is only done once, immediately before the
			// rendering is done for each entity.
			parentSprite.graphics.clear();
			
			//parentSprite.graphics.beginFill( 0xff0000, 0.2);
		}
		
		override protected function renderEntity(target:DisplayObject, spaceEntity:SpaceModelEntity, transformation:Matrix):void 
		{
			var s:Sprite = target as Sprite;
			
			s.graphics.beginFill( color, 0.2);
			
			s.graphics.drawRoundRect(
				spaceEntity.bounds.x, spaceEntity.bounds.y,
				spaceEntity.bounds.width, spaceEntity.bounds.height,
				1, 1 );
			
			s.graphics.endFill();
		}
		
		override public function afterRender(parentSprite:Sprite):void 
		{
			// parentSprite.graphics.endFill();
		}
	}

}