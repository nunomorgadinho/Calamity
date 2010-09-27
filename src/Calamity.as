package
{
	import caurina.transitions.Tweener;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;
	
	[SWF(backgroundColor = "0xFFFFFF", frameRate="120")]
	
	public class Calamity extends BasicView
	{
		[Embed(source="assets/blueMarble_med.jpg")]
		private var textureImage:Class;
		private var sphere:Sphere;
		private var container : DisplayObject3D;
		
		private var previousMousePoint : Point = new Point();
		private var targetScale : Number = 1;
		
		private static const FORWARD:Number3D = new Number3D(0, 0, 1);

		
		public function Calamity()
		{
			super();
			
			var bmp:Bitmap = new textureImage() as Bitmap;
			var bmpMaterial:BitmapMaterial = new BitmapMaterial( bmp.bitmapData );
			
			sphere = new Sphere(bmpMaterial, 600, 64, 64);
			
			sphere.alpha = .5
			sphere.rotationX = 0;
			sphere.rotationY = 180;
			sphere.rotationZ = 0;
			
			container = new DisplayObject3D();
			container.addChild( sphere, "sphere" );
			
			scene.addChild(container);
			singleRender();
			
			this.stage.doubleClickEnabled = true;
			this.stage.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			this.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			this.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			
			var text : TextField = new TextField();
			text.width = 200;
			text.text = "Use the mouse to drag/pan\nUse the mouse wheel to zoom\nR - reset to default view\n+/- to zoom in/out";
			this.stage.addChild( text );
			
			resetView();
		}
		
		private function onKeyDown( event : KeyboardEvent ) : void
		{
			trace( event.keyCode );
			switch ( event.keyCode ) 
			{
				case 187: // +
				case 107: // +
					zoom( 3 );
					break;    
				case 189: // -
				case 109: // -
					zoom( -3 );
					break;
				case 82: // r (reset)  
					resetView();
					break;  
			}
		}
		
		private function onMouseWheel( event : MouseEvent ) : void
		{
			zoom( event.delta );
		}
		
		private function onDoubleClick( event : MouseEvent ) : void
		{
			zoom( 10 );
		}
		
		private function onMouseDown( event : Event ) : void
		{
			Tweener.removeAllTweens();
			this.startRendering();
			previousMousePoint = new Point(viewport.containerSprite.mouseX, viewport.containerSprite.mouseY);
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		private function onMouseUp( event : Event ) : void
		{
			this.stopRendering();
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		private function onMouseMove( event : Event ) : void
		{  
			var currentMousePoint:Point = new Point(viewport.containerSprite.mouseX, viewport.containerSprite.mouseY);
			
			var difference:Point = currentMousePoint.subtract(previousMousePoint);
			var vector:Number3D = new Number3D(difference.x, difference.y, 0);
			
			var rotationAxis:Number3D = Number3D.cross(vector, FORWARD);
			rotationAxis.normalize();
			
			var distance:Number = Point.distance(currentMousePoint, previousMousePoint);
			var rotationMatrix:Matrix3D = Matrix3D.rotationMatrix(rotationAxis.x, -rotationAxis.y, rotationAxis.z, distance/(600*Math.pow(container.scale, 5)));
			
			container.transform.calculateMultiply3x3(rotationMatrix, container.transform);
			
			//this line used to apply transform to actual rotation values, so that if you change scale, the changes are persisted
			container.copyTransform(container);
			
			previousMousePoint = currentMousePoint
			
			trace( container.rotationX, container.rotationY, container.rotationZ, container.scale ); 
		}
		
		private function zoom( delta : Number ) : void
		{
			targetScale = targetScale + (delta * .01);
			targetScale = Math.max( targetScale, .5  );
			targetScale = Math.min( targetScale, 1.6 );
			Tweener.addTween( this, {sceneScale:targetScale, time:1, transition:"easeOutQuart"} )
		}
		
		public function resetView() : void
		{
			Tweener.addTween( container, {time:3, rotationX:-45, rotationY:0, rotationZ:0, transition:"easeOutQuart"} )
			Tweener.addTween( this, {sceneScale:1, time:3, transition:"easeOutQuart"} )
		}
		
		public function set sceneScale( value : Number ) : void
		{
			container.scale = value;
			singleRender();
		}
		
		public function get sceneScale() : Number
		{
			return container.scale;
		}
		
	}
}