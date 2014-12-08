package crab;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Matrix;

class Coke extends flash.display.Sprite implements Updatable {
	public var bitmap:Bitmap;

	var _updateList:Array<Updatable>;
	var _mat:Matrix;

	var _anchorX:Float;
	var _anchorY:Float;
	var _scaleX:Float;
	var _scaleY:Float;
	var _matRotate:Float;

	public function new() {
		super();

		bitmap = new Bitmap();
		_updateList = new Array<Updatable>();
		addChild(bitmap);
		_mat = new Matrix();

		_anchorX = 0;
		_anchorY = 0;
		_scaleX = 1;
		_scaleY = 1;
		_matRotate = 0;

		addEventListener(Event.ADDED, onAddChild);
		addEventListener(Event.REMOVED, onRemoveChild);
	}

	public function setBitmapOffset(ax:Float, ay:Float) {
		bitmap.x = ax;
		bitmap.y = ay;
	}

	public function onAddChild(e:Event) {
		var target:DisplayObject = e.target;
		if (Std.is(target, Updatable) && target != this) {
			_updateList.push(cast(target, Updatable));
		}
	}

	public function onRemoveChild(e:Event) {
		var target:DisplayObject = e.target;
		if (Std.is(target, Updatable) && target != this) {
			_updateList.remove(cast(target, Updatable));
		}
	}

	public function setBitmapData(bd:BitmapData) {
		bitmap.bitmapData = bd;
	}

	public function getContentWidth():Int {
		return Std.int(bitmap.width);
	}

	public function getContentHeight():Int {
		return Std.int(bitmap.height);
	}

	public function transformImage() {
		_mat.identity();
		_mat.translate(-_anchorX, -_anchorY);
		_mat.scale(_scaleX, _scaleY);
		_mat.rotate(_matRotate * 0.017453292519943295);
		//_mat.translate(_anchorX, _anchorY);
		_mat.translate(x, y);
		this.transform.matrix = _mat;
	}

	public function update(dt:Float) {
		var i:Int = 0;
		var length:Int = _updateList.length;
		while (i < length) {
			var up:Updatable = _updateList[i];
			up.update(dt);
			i++;
		}
	}
}
