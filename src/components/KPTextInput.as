package components
{
	import flash.events.FocusEvent;
	
	import spark.components.TextInput;
	
	//Declare the Additional SkinStates
	[SkinState("focused")]
	public class KPTextInput extends TextInput
	{
		[Bindable]
		public var borderWeight:Number = 1;
		[Bindable]
		public var backgroundAlpha:Number = 1;
	
		private var bfocused:Boolean;
		
		public function KPTextInput()
		{
			super();
		}
		
		//Add EventListeners to the textview for FocusEvent
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == this.textDisplay) {
				this.textDisplay.addEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
				this.textDisplay.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
			}
		}
		
		//Clean up EventListeners and stuff...
		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			if (instance == this.textDisplay) {
				this.textDisplay.removeEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
				this.textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
			}
		}
		
		//Leverage the new SkinState
		override protected function getCurrentSkinState():String {
			if (bfocused) {
				return "focused";
			} else {
				return super.getCurrentSkinState();
			}
		}
		
		//Handler for FocusIn Event
		private function onFocusInHandler(event:FocusEvent):void {
			bfocused = true;
			this.textDisplay.selectAll();
			invalidateSkinState();
		}
		
		//Handler for FocusOut
		private function onFocusOutHandler(event:FocusEvent):void {
			bfocused = false;
			invalidateSkinState();
		}
	}
}