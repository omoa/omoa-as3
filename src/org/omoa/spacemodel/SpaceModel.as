/**
 * The spacemodel package contains all spatial data models, data types, 
 * import filters and iterators, with the exception of projection algorithms. 
 */
package org.omoa.spacemodel {

	import flash.display.GraphicsPath;
	import flash.display.IGraphicsPath;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import org.omoa.framework.BoundingBox;
	import org.omoa.framework.Description;
	import org.omoa.framework.ISpaceModelIndex;
	import org.omoa.framework.ModelDimension;
	import org.omoa.framework.GeometryType;
	import org.omoa.framework.IDataModel;
	import org.omoa.framework.IProjection;
	import org.omoa.framework.ISpaceModel;
	import org.omoa.framework.ISpaceModelIterator;
	import org.omoa.framework.ModelDimensionType;
	import org.omoa.projection.AbstractProjection;
	import org.omoa.util.GeometryFunctions;
	

	/**
	 * A SpaceModel is a collection of SpaceModelEntities of a common GeometryType.
	 * 
	 * @author Sebastian Specht
	 */
	
	public class SpaceModel extends EventDispatcher implements ISpaceModel {

		protected var _id:String;
		protected var _type:String = GeometryType.GEOMETRY_NONE;
		protected var _bounds:BoundingBox;
		protected var _index:ISpaceModelIndex;
		protected var _projection:IProjection = new AbstractProjection();
		protected var _attributes:IDataModel;
		protected var _complete:Boolean = false;
		protected var entities:Vector.<SpaceModelEntity> = new Vector.<SpaceModelEntity>;


		public function SpaceModel() {
		}
		
		/**
		 * The BoundingBox of the SpaceModel.
		 */
		public function get bounds():BoundingBox { return _bounds; }

		/**
		 * Adds an entity to the collection.
		 * 
		 * @param	entity
		 */
		protected function addEntity(entity:SpaceModelEntity):void {
			entity.model = this;
			entities.push( entity );
		}

		protected function setProjection(projection:IProjection):void {
		}

		public function get projection():IProjection {
			return _projection;
		}
		
		public function setIndex(index:ISpaceModelIndex):void {
			_index = index;
			if (_index) {
				_index.createIndex( entities.slice( 0, entities.length ) );
			}
		}
		
		public function get index():ISpaceModelIndex {
			return _index;
		}

		/**
		 * The GeometryType of the entities in the collection.
		 */
		public function get geometryType():String {
			return _type;
		}
		
		/**
		 * The ID of the Model.
		 */
		public function get id():String {
			return _id;
		}
		
		/**
		 * True, if this Model is beyond its initialization phase.
		 */
		public function get isComplete():Boolean {
			return _complete;
		}
		
		/**
		 * Returns an iterator of the specified type to the elements of this collection.
		 * 
		 * @param	type 	The type of the iterator, leave empty for a SimpleIterator.
		 * @return	An iterator of the given type, a SimpleIterator if no type is specified or a NullIterator.
		 */
		public function iterator(type:String = null):ISpaceModelIterator {
			return new AbstractIterator( entities.slice(0, entities.length) ).iterator( type );
		}
		
		
		public function findById(id:String):SpaceModelEntity {
			var entity:SpaceModelEntity;
			for each (entity in entities) {
				if (entity.id == id) {
					return entity;
				}
			}
			return null;
		}
		
		public function findByCoordinate(x:Number, y:Number):SpaceModelEntity {
			var bounds:Rectangle = new Rectangle(x, y, 0.000001, 0.000001);
			var i:ISpaceModelIterator;
			var sme:SpaceModelEntity;
			var testEntities:Vector.<SpaceModelEntity> = new Vector.<SpaceModelEntity>();
			
			if (_index) {
				i = _index.iterator(bounds, true);
			} else {
				i = iterator();
			}
			
			while (i.hasNext()) {
				sme = i.next();
				if (sme.bounds.containsPoint( bounds.topLeft )) {
					testEntities.push( sme );
				}
			}
			
			for each (sme in testEntities) {
				if (GeometryFunctions.pointInPolygon(sme.path as GraphicsPath, x, y)) {
					return sme;
				}
			}
			return null;
		}

		/**
		 * Not implemented.
		 */
		public function attributes():IDataModel {
			return null;
		}

		/**
		 * Not implemented.
		 */
		public function getIndexByAttribute(attribute:String, value:String):int {
			return 0;
		}

		/**
		 * The number of entities.
		 */
		public function entityCount():int {
			return entities.length;
		}

		/**
		 * Returns the entity at the given index.
		 * 
		 * @param	index The index number of an entity.
		 * @return	An entity.
		 */
		public function entity(index:uint):SpaceModelEntity {
			return entities[ index ];
		}
		
		/**
		 * This method creates links between a DataModel and the entities of this SpaceModel.
		 * 
		 * If you give model and a dataDescription containing a "*" this is applied
		 * 
		 * @param	model	The Model.
		 * @param	dataDescription		
		 */
		public function linkDataModel( model:IDataModel, dataDescription:Description = null ):void {
			var order:int;
			var dimension:ModelDimension;
			var entity:SpaceModelEntity;
			var description:Description;
			
			if (dataDescription) {
				var wildcardDimensionOrder:int;
				for (order = 1; order <= model.propertyDimensionCount(); order++) {
					if (dataDescription.selectedIndex( order ) == Description.WILDCARD_INDEX) {
						wildcardDimensionOrder = order;
					}
					
				}
				for each (entity in entities) {
					description = model.createDescription( dataDescription.toString() );
					if (description.selectByCode( wildcardDimensionOrder, entity.id )) {
						entity.addDescription( description );
					}
				}
			} else {
				/*
				 * Automatic join based on SpaceModel-ID and ClassificationID.
				 * Works only for the first dimension.
				 */
				for (order = 1; order <= model.propertyDimensionCount(); order++) {
					dimension = model.propertyDimension( order );
					//if (dimension.type == ModelDimensionType.ENTITY_ID &&
					if (dimension.classificationID == _id) {
						//trace( "*** Linking " + model.id +":" + dimension.classificationID + " with " + _id);
						for each (entity in entities) {
							description = model.createDescription( entity.id );
							//if ( description.representsSomething) {
								entity.addDescription( description );
							//}
						}
					}
				}
			}
		}
		
		/**
		 * Creates a PropertyDimension (ModelDimension) from the model for use with an IDataModel.
		 * 
		 * @param	withLabels	Set true, when you need the entity names as code labels. Default is false.
		 * @return A ModelDimension or null, when the SpaceModel is not yet initialized.
		 */
		public function createPropertyDimension(withLabels:Boolean = false):ModelDimension {
			if (_complete) {
				var codes:Array = new Array();
				var labels:Array = null;
				var sme:SpaceModelEntity;
				var iterator:ISpaceModelIterator = iterator();
				
				while (iterator.hasNext()) {
					sme = iterator.next();
					codes.push(sme.id);
				}
				
				if (withLabels) {
					labels = new Array();
					iterator.reset();
					while (iterator.hasNext()) {
						sme = iterator.next();
						labels.push(sme.name);
					}
				}
				
				return new ModelDimension(  id,
											"Entities of " + id + " SpaceModel",
											"["+ModelDimensionType.ENTITY_ID+"]",
											ModelDimensionType.ENTITY_ID,
											codes,
											labels );
			} else {
				return null;
			}
		}

	}
}