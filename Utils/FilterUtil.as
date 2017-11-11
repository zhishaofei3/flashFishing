package Utils{
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;	

	public class FilterUtil {
		/**
		 * 0-1
		 */
		public static function getContrastFilter(nLevel : Number) : ColorMatrixFilter {
			var Scale : Number = nLevel * 11;
			var Offset : Number = 63.5 - (nLevel * 698.5);
			var Contrast_Matrix : Array = [Scale , 0 , 0 , 0 , Offset , 0 , Scale , 0 , 0 , Offset , 0 , 0 , Scale , 0 , Offset , 0 , 0 , 0 , 1 , 0];
			var filter : ColorMatrixFilter = new ColorMatrixFilter(Contrast_Matrix);
			return filter;
		}

		/**
		 * 0-1
		 */
		public static function getGrayFilter(n : Number = 0.4) : BitmapFilter {
			var matrix : Array = new Array();
			matrix = matrix.concat([n, n, n, 0, 0]);
			matrix = matrix.concat([n, n, n, 0, 0]);
			matrix = matrix.concat([n, n, n, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			var filter : BitmapFilter = new ColorMatrixFilter(matrix);
			return filter;
		}
	}
}
