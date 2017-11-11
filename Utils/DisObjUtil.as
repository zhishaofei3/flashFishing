package Utils{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.FrameLabel;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public class DisObjUtil {
        public static function toStageCenter(diso:DisplayObject):void {
            var rec:Rectangle = diso.getBounds(diso.stage);
            diso.x = -rec.x - rec.width / 2 + diso.stage.stageWidth / 2;
            diso.y = -rec.y - rec.height / 2 + diso.stage.stageHeight / 2;
        }

        public static function removeAllChildren(dc:DisplayObjectContainer):void {
            while (dc && dc.numChildren) {
                dc.removeChildAt(0);
            }
        }
    }

}
