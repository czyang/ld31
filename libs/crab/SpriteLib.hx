package crab;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

class SpriteLib  {
	private var _bitmapData:BitmapData;
	private var _group:Map<String, Dynamic>;

	private var _zeroPoint:Point;

	public function new() {
		_group = new Map<String, Dynamic>();
		_zeroPoint = new Point(0, 0);
	}

	public function loadBitmapData(bd:BitmapData) {
		_bitmapData = bd;
	}

	// Make image from the sprite image.
	public function makeImage(id:String, x:Int, y:Int, w:Int, h:Int):Bool {
		if (_group.exists(id)) {
			trace(id, "is already exists.");
			return false;
		} else {
			var bitmapData:BitmapData = new BitmapData(w, h);
			bitmapData.copyPixels(_bitmapData, new Rectangle(x, y, w, h), _zeroPoint);
			_group.set(id, bitmapData);
			return true;
		}
	}

	// c is coloumn number, r is row number, f is frame number.
	public function makeAnim(id:String, x:Int, y:Int, w:Int, h:Int, c:Int, r:Int, f:Int):Bool {
		if (_group.exists(id)) {
			trace(id, "is already exists.");
			return false;
		} else {
			var bds:Array<BitmapData> = new Array<BitmapData>();
			var tileWidth:Int = Std.int(w / c);
			var tileHeight:Int = Std.int(h / r);
			var offsetX:Int = 0;
			var offsetY:Int = 0;
			var frameCount:Int = 0;
			for (_ in 0...r) {
				offsetX = 0;
				for(_ in 0...c) {
					if (frameCount >= f) {
						_group.set(id, bds);
						return true;
					}
					frameCount++;

					var bitmapData:BitmapData = new BitmapData(tileWidth, tileHeight);
					bitmapData.copyPixels(_bitmapData, new Rectangle(x + offsetX, y + offsetY, tileWidth, tileHeight), _zeroPoint);
					bds.push(bitmapData);
					offsetX += tileWidth;
				}
				offsetY += tileHeight;
			}
			_group.set(id, bds);
			return true;
		}
	}

	public function makeTilemap(id:String, x:Int, y:Int, w:Int, h:Int, c:Int, r:Int):Bool {
		if (_group.exists(id)) {
			trace(id, "is already exists.");
			return false;
		} else {
			var bds:Array<BitmapData> = new Array<BitmapData>();
			var tileWidth:Int = Std.int(w / c);
			var tileHeight:Int = Std.int(h / r);
			var offsetX:Int = 0;
			var offsetY:Int = 0;
			for (_ in 0...r) {
				offsetX = 0;
				for (_ in 0...c) {
					var bitmapData:BitmapData = new BitmapData(tileWidth, tileHeight);
					bitmapData.copyPixels(_bitmapData, new Rectangle(x + offsetX, y + offsetY, tileWidth, tileHeight), _zeroPoint);
					bds.push(bitmapData);
					offsetX += tileWidth;
				}
				offsetY += tileHeight;
			}
			_group.set(id, bds);
			return true;
		}
	}

	public function getCoke(id:String):Coke {
		if (_group.exists(id) == false) {
			trace(id, "is null.");
			return null;
		} else {
			var bd:BitmapData = _group.get(id);
			var img:Coke = new Coke();
			img.setBitmapData(bd);
			return img;
		}
	}

	public function getBitmapData(id:String):BitmapData {
		if (_group.exists(id) == false) {
			trace(id, "is null.");
			return null;
		} else {
			var bd:BitmapData = _group.get(id);
			return bd;
		}
	}

	public function getAnim(id:String):CokeAnim {
		if (_group.exists(id) == false) {
			trace(id, "is null.");
			return null;
		} else {
			var bds:Array<BitmapData> = _group.get(id);
			var anim:CokeAnim = new CokeAnim();
			anim.loadAnim(bds);
			return anim;
		}
	}
}
