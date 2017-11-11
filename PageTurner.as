package {
    import flash.display.InteractiveObject;
    import flash.events.MouseEvent;
    import flash.text.TextField;


    public class PageTurner {
        private var curpage:int;
        private var items:Array;
        private var prevBtn:InteractiveObject;
        private var nextBtn:InteractiveObject;
        private var showFunc:Function;
        private var con:int;
        private var txt:TextField;

        public function PageTurner(shf:Function, con:int, pb:InteractiveObject, nb:InteractiveObject, txt:TextField = null) {
            this.txt = txt;
            this.con = con;
            this.prevBtn = pb;
            this.nextBtn = nb;
            this.showFunc = shf;
            this.prevBtn.addEventListener(MouseEvent.CLICK, prevPage, false, 0, true);
            this.nextBtn.addEventListener(MouseEvent.CLICK, nextPage, false, 0, true);
        }

        public function destroy():void {
            this.showFunc = null;
            this.items = null;
            this.prevBtn.removeEventListener(MouseEvent.CLICK, prevPage);
            this.nextBtn.removeEventListener(MouseEvent.CLICK, nextPage);
        }

        private function nextPage(event:MouseEvent):void {
            curpage++;
            showItems();
        }

        private function prevPage(event:MouseEvent):void {
            curpage--;
            showItems();
        }

        public function get totalPages():int {
            return Math.ceil(this.items.length / con);
        }

        public function update(ar:Array, staypage:Boolean = false):void {
            this.items = ar;
            if (!staypage) {
                curpage = 0;
            }else{
                if(curpage>totalPages) {
                    curpage=totalPages-1;
                }
            }
            showItems();
        }

        private function showItems():void {
            this.prevBtn.visible = curpage > 0;
            this.nextBtn.visible = curpage < totalPages - 1;
            if (this.txt != null) {
                this.txt.text = (curpage + 1) + "/" + (totalPages==0?1:totalPages);
            }
            var ta:Array = this.items.slice(curpage * con, Math.min(this.items.length, (curpage + 1) * con));
            this.showFunc.apply(null, [ta]);
        }

        public function get curPage():int {
            return this.curpage;
        }
    }
}
