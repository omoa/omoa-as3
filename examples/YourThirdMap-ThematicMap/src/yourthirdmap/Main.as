package yourthirdmap {
	
	import flash.display.*;
	import flash.events.*;
	import org.omoa.*;
	import org.omoa.classification.*;
	import org.omoa.datamodel.*;
	import org.omoa.datamodel.loader.*;
	import org.omoa.framework.*;
	import org.omoa.layer.*;
	import org.omoa.spacemodel.*;
	import org.omoa.symbol.*;
	
	/**
	 * ...
	 * 
	 * @author Sebastian Specht
	 */
	public class Main extends Sprite {
		
		private var map:Map;
		
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// set up stage, recommended
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// entry point of the demo
			
			// ****************************
			//  Scroll down...
			// ****************************
			
			
			map = new Map();
			addChild( map );
			map.resize(800, 600);
			map.createMapFrame("mapframe1");
				
			
			// We are adding the background raster image.
			var rasterSM:ISpaceModelLoader = map.createSpaceModel("cities", null, null, "RasterSpaceModel" ) as ISpaceModelLoader;
			rasterSM.initialize( {  bounds: new BoundingBox( -180, -90, 180, 90),
									tiles: [
										{ url: "MU_5400_T.png", bounds: new BoundingBox( -180, -90, 180, 90) }
										]
								 } );
			
			var imageLayer:ImageLayer = map.createLayer( "cities", rasterSM, "ImageLayer" ) as ImageLayer;
			map.mapframe("mapframe1").addLayer(imageLayer);
			
			
			// We are adding the countries,
			// but we won't add a layer yet
			var sm:ISpaceModel = map.createSpaceModel( "WorldAdmin0",
									"110m_admin_0_countries",
									{ id:"NAME_SM", name:"NAME_SM", modelID:"WorldAdmin0" } );
			
			// ****************************
			// ... stop.
			// ****************************
			
			// We are adding an event listener to the Country-SpaceModel.
			// The moment the model is intialized we will continue there,
			sm.addEventListener(Event.COMPLETE, smComplete);
			
			// ****************************
			// Scoll down to the smComplete() function
			// ****************************
			
			// We are adding rivers...
			map.createSpaceModel( "rivers", "110m-rivers-lake-centerlines");
			map.createLayer( "rivers", map.spacemodel("rivers") );
			var riverSymbol:VectorSymbol = new VectorSymbol();
			riverSymbol.setProperty( riverSymbol.FILLALPHA, new Value(0) );
			riverSymbol.setProperty( riverSymbol.OUTLINECOLOR, new Value(0x99aaff) );
			riverSymbol.setProperty( riverSymbol.OUTLINEWIDTH, new Value(1) );
			SymbolLayer(map.layer("rivers")).addSymbol(riverSymbol);	
			map.mapframe("mapframe1").addLayer( map.layer("rivers"));
			
			// ...and lakes.
			map.createSpaceModel( "lakes", "110m-lakes" );
			map.createLayer("lakes", map.spacemodel("lakes") );
			var lake:VectorSymbol = new VectorSymbol();
			lake.setProperty( lake.OUTLINECOLOR, new Value(0x99aaff) );
			lake.setProperty( lake.FILLCOLOR, new Value( 0xaaccff ));
			SymbolLayer(map.layer("lakes")).addSymbol(lake);
			map.mapframe("mapframe1").addLayer( map.layer("lakes"));	
			
		}
		
		private function smComplete(e:Event):void {
			// ****************************
			// Thematic Mapping layer
			// ****************************
			
			// As we want to access the SpaceModel,
			// we needed to wait for it to be loaded.
			
			// 1. For thematic maps you need some statistical data.
			//    We store statistical data in an IDataModel.
			//    For this example we will load some data from the 
			//    attributes of the SpaceModelEntities
			//    (these attributes are located in the Dbf-File that came with 
			//    the Shapefile).
			
			//    There are other columns too. See here:
			var sme:SpaceModelEntity = map.spacemodel("WorldAdmin0").entity(0);
			trace(sme.toString());
			
			
			var gdp:IDataModel = new SMEAttributeDataModel( "gdp",  map.spacemodel("WorldAdmin0"), "GDP_USDM" );
			
			//    The SMEAttributeDataModel class creates one property dimension 
			//    (the IDs of the countries)
			//    and one value dimension (the GDP value from the column "GDP_USDM").
			
			
			
			//    A Description can be seen as a query on a DataModel.
			var description:Description = gdp.createDescription("Afghanistan.GDP_USDM");
			trace(description.toString());
			
			//    A Datum can store the result of such a "query".
			//    The IDataModel.getDatum() function creates a datum Object.
			//    This can be a costly operation.
			var datum:Datum = gdp.getDatum( description );
			trace( "GDP for Afghanistan: " + datum );
			
			//    The updateDatum() is much faster as no object is created.
			datum.description.selectByCode( 1, "Germany" );
			gdp.updateDatum( datum );
			trace( "GDP for Germany: " + datum );
			
			
			
			
			// TEXT Data example
			/*
			 * Location
			 * Population (in thousands) total	
			 * Population median age (years)	
			 * Population proportion under 15 (%)	
			 * Population proportion over 60 (%)	
			 * Population living in urban areas (%)	
			 * Annual population growth rate (%)
			 */
			var settings:Object = {
				linebreak:"\r\n",
				separator:"\t",
				hasHeader:true,
				values: [
				{
				  name:'population proportion',
				  id:'prop',
				  unit:'%',
				  type:'ratio'
				}
				],
				properties: [
				{
				  id: 'WorldAdmin0',
				  name: 'Country',
				  unit:'ID',
				  type: 'ID',
				  column: 0
				},
				{
				  id: 'agegroup',
				  name: 'Age group',
				  unit:'',
				  type: 0,
				  column: false,
				  codes:['under15','over60'],
				  columns:[
					{
					  id:'under15',
					  column:3
					},
					{
					  id:'over60',
					  column:4
					}
				  ]
				} 
				]
			};
			
			var dm:IDataModel = map.createDataModel( "whopop", "who_pop.txt", settings );
			dm.addEventListener(Event.COMPLETE, dmComplete);
			
			
			map.layoutMapFrames();
			map.updateDebug();
		}
		
		private function dmComplete(e:Event):void {
			trace( "==========================" );
			trace( "The DataModel is complete..." );
			
			var dm:IDataModel = e.target as IDataModel;
			if (!dm) {
				trace( "...but f*cked up." );
				return;
			}
			
			trace( dm );
			trace( dm.getDatum( dm.createDescription("Algeria.under15")));
			trace( dm.getDatum( dm.createDescription("Algeria.under15.prop")));
			

			
			var people:IDataModel = new SMEAttributeDataModel( "people",  map.spacemodel("WorldAdmin0"), "PEOPLE" );
			map.addDataModel(people);
			
			var sme:SpaceModelEntity = map.spacemodel("WorldAdmin0").entity( 4 );
			trace(sme);
			trace( people.getDatum(people.createDescription( sme.id + ".PEOPLE")).value 
			       + " people live in " + sme.name + ". ");
			
			
			
			
			
			var layer:SymbolLayer = map.createLayer( "Admin0_bg", map.spacemodel("WorldAdmin0") ) as SymbolLayer;
			var s:VectorSymbol = new VectorSymbol();
			s.setProperty( s.FILLALPHA, new Value(0.5));
			s.setProperty( s.OUTLINECOLOR, new Value(0xaaaaaa));
			layer.addSymbol(s);
			map.mapframe("mapframe1").addLayer(layer);	
			
			
			
			
			var tld:IDataModel = new SMEAttributeDataModel( "tld",  map.spacemodel("WorldAdmin0"), "INTERNET_" );
			trace( tld.getDatum(tld.createDescription( sme.id + ".INTERNET_")).value 
			       + " is the TLD of " + sme.name + ". ");
			
			
			var peopleLayer:SymbolLayer = map.createLayer( "people", map.spacemodel("WorldAdmin0")) as SymbolLayer;
			var peopleCircles:PointSymbolEntity = new PointSymbolEntity();
			peopleCircles.needsInteractivity = true;
			
			peopleCircles.setProperty( peopleCircles.FILLCOLOR, new Value(0x550000) );
			peopleCircles.setProperty( peopleCircles.FILLALPHA,
								new LinearInterpolateClassification(
										10, 		0.2, 
										50, 	1,
										dm.createDescription( "*.under15.prop") )
								);
			peopleCircles.setProperty( peopleCircles.SIZE,
								new SquarerootClassification(0.00001, 1,
												 people.createDescription( "*.PEOPLE"))
								//new Value(0.001)
												 );
												 
			
			
			peopleLayer.addSymbol( peopleCircles );
			map.mapframe("mapframe1").addLayer( peopleLayer );
		}
		
		private function zoomin(e:Event):void 
		{
			map.mapframe("mapframe1").zoomIn();
		}
		
	}
	
}