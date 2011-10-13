package yourfirstmap {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import org.omoa.classification.Value;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelLoader;
	import org.omoa.layer.ImageLayer;
	import org.omoa.layer.SymbolLayer;
	import org.omoa.Map;
	import org.omoa.spacemodel.BoundingBox;
	import org.omoa.symbol.VectorSymbol;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	public class Main extends Sprite {
		
		// 1. You should (at least) create a class variable for the omoa map object
		private var map:Map;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// set up stage, recommended
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// entry point of the demo
			
			// 2. We create a map. A map is a flash DisplayObject. 
			map = new Map();
			
			// 3. We need to add it to the display list of our flash movie.
			addChild( map );
			map.resize(800, 600);

			// 4. A map does not display anything. We need to create a view (MapFrame)
			//    and give it a name.
			map.createMapFrame("mapframe1");
			
			
			
			// 5. We need to create a SpaceModel first. 
			//    We will load it from a SHP-File.
			var sm:ISpaceModel = map.createSpaceModel( "WorldAdmin0",
									"110m_admin_0_countries",
									{ id:"ISO_A3", name:"NAME_SM", modelID:"WorldAdmin0" } );
			
			// NOTA BENE:
			// Instead of creating a class variable for the SpaceModel or
			// a local variable (above) you can request it by name at any time.
			// This...
			trace( sm.id );
			// ...is the same as this:
			trace( map.spacemodel("WorldAdmin0").id );
			// This applies to models, mapframes and layers.
			
			
			
			// 6. We create an SymbolLayer that uses the SpaceModel...
			var layer:SymbolLayer = map.createLayer( "Admin0_bg", sm ) as SymbolLayer;
			
			// 7. ...and add a Symbol to render the countries vector data.
			var s:VectorSymbol = new VectorSymbol();
			
			// 8. We add the symbol to the layer...
			layer.addSymbol(s);
			
			// 9. ...and our layer to the MapFrame.
			map.mapframe("mapframe1").addLayer(layer);
			
			
			
			// 10. That's it.
			// But the map is a bit boring. So we continue 
			// to add more layers.
			// You may have understood the principle by now...
			
			// We are adding rivers...
			map.createSpaceModel( "rivers", "110m-rivers-lake-centerlines");
			map.createLayer( "rivers", map.spacemodel("rivers") );
			var riverSymbol:VectorSymbol = new VectorSymbol();
			riverSymbol.setProperty( riverSymbol.FILLALPHA, new Value(0) );
			riverSymbol.setProperty( riverSymbol.OUTLINECOLOR, new Value(0x2255ff) );
			riverSymbol.setProperty( riverSymbol.OUTLINEWIDTH, new Value(2) );
			SymbolLayer(map.layer("rivers")).addSymbol(riverSymbol);	
			map.mapframe("mapframe1").addLayer( map.layer("rivers"));
			
			// ...and lakes.
			map.createSpaceModel( "lakes", "110m-lakes" );
			map.createLayer("lakes", map.spacemodel("lakes") );
			var lake:VectorSymbol = new VectorSymbol();
			lake.setProperty( lake.OUTLINECOLOR, new Value(0x2255ff) );
			lake.setProperty( lake.FILLCOLOR, new Value( 0x99aaff ));
			SymbolLayer(map.layer("lakes")).addSymbol(lake);
			map.mapframe("mapframe1").addLayer( map.layer("lakes"));
			
		}
		
	}
	
}