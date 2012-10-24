package extendomoa
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.omoa.classification.Value;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.layer.SymbolLayer;
	import org.omoa.Map;
	import org.omoa.symbol.VectorSymbol;
	
	/**
	 * ...
	 * @author SKS
	 */
	public class Main extends Sprite 
	{
		private var m:Map;
		private var sm:ISpaceModel;
		private var layer:SymbolLayer;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// entry point
			
			// We create a conventional map...
			m = new Map();
			addChild(m);
			
			// ...with a conventional map frame.
			m.createMapFrame("omoaFrame");
			
			// We load some data.
			sm = m.createSpaceModel(
				"countries",
				"110m_admin_0_countries",
				{ id:"ISO_A3", name:"NAME_SM", modelID:"WorldAdmin0" } 
			);
			sm.addEventListener(Event.COMPLETE, smComplete);
			
			// We create a conventional SymbolLayer...
			layer = m.createLayer("omoaSymbolLayer", sm) as SymbolLayer;
			m.mapframe("omoaFrame").addLayer(layer);
			
			// ...and add a conventional Symbol.
			layer.addSymbol( new VectorSymbol() );
			
			m.resize( 400, 600 );
		}
		
		private function smComplete(e:Event):void 
		{
			addMySymbol();
			addMyEntitySymbol();
		}
		
		private function addMySymbol():void 
		{
			// We create an instance of our own symbol class...
			var mySymbol:MySymbol = new MySymbol();
			
			// ... set the COLOR property ...
			mySymbol.setProperty( mySymbol.COLOR, new Value( 0x0000ff ) );
			
			// ... and add the symbol to the layer.
			layer.addSymbol( mySymbol );
		}
		
		private function addMyEntitySymbol():void 
		{
			// We create an instance of our own symbol class...
			var mySymbol:MyEntitySymbol = new MyEntitySymbol();
			
			// ... set the COLOR property ...
			mySymbol.setProperty( mySymbol.COLOR, new Value( 0x000000 ) );
			
			// ... and add the symbol to the layer.
			layer.addSymbol( mySymbol );
		}
	}
	
}