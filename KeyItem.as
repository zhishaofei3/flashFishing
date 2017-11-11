package{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	public class KeyItem extends Sprite{
		public function KeyItem(i:int,p:DisplayObject,b:Boolean,s:String):void{
			itemId_txt.text = String(i);
			addChild(p);
			p.width = 80;
			p.height = 80;
			p.x = 50;
			p.y = 0;
			if(b){
				true_mc.gotoAndStop(1);
			}else{
				true_mc.gotoAndStop(2);
			}
			itemTrueText_txt.text = s;
		}
	}
}