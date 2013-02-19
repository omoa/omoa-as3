package yoursecondmap {
	
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
	import org.omoa.framework.BoundingBox;
	import org.omoa.symbol.PointSymbolEntity;
	import org.omoa.symbol.VectorSymbol;
	
	/**
	 * ...
	 * @author Sebastian Specht
	 */
	public class Main extends Sprite {
		
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
			stage.addEventListener(Event.RESIZE, resize);
			
			// entry point of the demo
			
			
			map = new Map();
			addChild( map );
			map.mapframeMargin = 0;
			map.resize(800, 600);
			map.createMapFrame("mapframe1");
			
			
			
			
			
			
			
			
			var rasterSM:ISpaceModelLoader = map.createSpaceModel("cities", null, null, "RasterSpaceModel" ) as ISpaceModelLoader;
			rasterSM.initialize( {  bounds: new BoundingBox( -180, -90, 180, 90),
									tiles: [
										{ url: "HYP_2700W.jpg", bounds: new BoundingBox( -180, -90, 0, 90) },
										{ url: "HYP_2700E.jpg", bounds: new BoundingBox(0, -90, 180, 90) },
										//{ url: "MU_5400_T.png", bounds: new BoundingBox( -180, -90, 180, 90) }
										]
								 } );
			
			var imageLayer:ImageLayer = map.createLayer( "cities", rasterSM, "ImageLayer" ) as ImageLayer;
			
			map.mapframe("mapframe1").addLayer(imageLayer);
			
			
			// We are adding the countries.
			var sm:ISpaceModel = map.createSpaceModel( "WorldAdmin0",
									//"ne_50m_admin_0_countries",
									"110m_admin_0_countries",
									{ id:"ISO_A3", name:"NAME_SM", modelID:"WorldAdmin0" } );
			var layer:SymbolLayer = map.createLayer( "Admin0_bg", sm ) as SymbolLayer;
			var s:VectorSymbol = new VectorSymbol();
			s.setProperty( s.FILLALPHA, new Value(0.0));
			s.setProperty( s.OUTLINECOLOR, new Value(0xffffff));
			layer.addSymbol(s);
			map.mapframe("mapframe1").addLayer(layer);
			
			// We are adding rivers...
			map.createSpaceModel( "rivers", "110m-rivers-lake-centerlines");
			//map.createSpaceModel( "rivers", "50m-rivers-lake-centerlines");
			map.createLayer( "rivers", map.spacemodel("rivers") );
			var riverSymbol:VectorSymbol = new VectorSymbol();
			riverSymbol.setProperty( riverSymbol.FILLALPHA, new Value(0) );
			riverSymbol.setProperty( riverSymbol.OUTLINECOLOR, new Value(0x3b76ac));// 0x76a6cc) );
			riverSymbol.setProperty( riverSymbol.OUTLINEWIDTH, new Value(1) );
			SymbolLayer(map.layer("rivers")).addSymbol(riverSymbol);	
			map.mapframe("mapframe1").addLayer( map.layer("rivers"));
			
			// ...and lakes.
			map.createSpaceModel( "lakes", "110m-lakes" );
			//map.createSpaceModel( "lakes", "50m-lakes" );
			map.createLayer("lakes", map.spacemodel("lakes") );
			var lake:VectorSymbol = new VectorSymbol();
			lake.setProperty( lake.OUTLINECOLOR, new Value(0x3b76ac) );
			lake.setProperty( lake.FILLCOLOR, new Value( 0xc1dbec ));
			SymbolLayer(map.layer("lakes")).addSymbol(lake);
			map.mapframe("mapframe1").addLayer( map.layer("lakes"));
			
			map.createSpaceModel( "coast", "110m_land" );
			//map.createSpaceModel( "coast", "50m_coastline" );
			map.createLayer("coast", map.spacemodel("coast") );
			var coast:VectorSymbol = new VectorSymbol();
			coast.setProperty( coast.OUTLINECOLOR, new Value(0x3b76ac) );
			coast.setProperty( coast.FILLALPHA, new Value( 0 ));
			SymbolLayer(map.layer("coast")).addSymbol(coast);
			map.mapframe("mapframe1").addLayer( map.layer("coast"));
			
			// ...and urban areas.
			map.createSpaceModel( "urban", "110m_populated_places" );
			map.createLayer("urban", map.spacemodel("urban") );
			var urban:PointSymbolEntity = new PointSymbolEntity();
			urban.setProperty(urban.FILLCOLOR, new Value( 0x555555 ));
			urban.setProperty(urban.OUTLINECOLOR, new Value( 0x555555 ));
			SymbolLayer(map.layer("urban")).addSymbol(urban);
			map.mapframe("mapframe1").addLayer( map.layer("urban"));
			
			map.layoutMapFrames();
			
		}
		
		private function resize(e:Event):void 
		{
			if (map) {
				map.resize(stage.stageWidth, stage.stageHeight);
			}
		}
		
	}
	
}