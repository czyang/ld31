package crab;

import flash.display.Bitmap;
import flash.display.BitmapData;

class CokeAnim extends Coke {
    private var _bitmapDataList:Array<BitmapData>;

    private var _isLoop:Bool;
    private var _isPlayback:Bool;
    private var _interval:Float;
    private var _maxFrame:Int;

    private var _frameIndex:Int;
    private var _duration:Float;
    private var _lastFrameTime:Float;

    private var _curAnim:String;
    private var _curAnimIndexList:Array<Int>;
    private var _animHash:Map<String, Array<Int>>;

    public function new() {
        super();

        _isLoop = true;
        _isPlayback = false;
        _frameIndex = 0;
        _duration = 0;
        _lastFrameTime = 0;
        _interval = 0.4;
        _maxFrame = 0;

        _curAnim = "";
        _curAnimIndexList = null;

        _animHash = new Map<String, Array<Int>>();
    }

    public function loadAnim(bds:Array<BitmapData>) {
        _bitmapDataList = bds;
        _maxFrame = _bitmapDataList.length;

        bitmap.bitmapData = _bitmapDataList[0];
    }

    public function setAnim(animId:String, indexList:Array<Int>) {
        _animHash.set(animId, indexList);
    }

    public function playAnim(animId:String) {
        _curAnimIndexList = _animHash.get(animId);
        if (_curAnimIndexList != null) {
            _curAnim = animId;
            _frameIndex = 0;
        }
    }

    public function getCurAnim():String {
        return _curAnim;
    }

    override public function update(dt:Float) {
        super.update(dt);

        if (_curAnim != "") {
            _duration += dt;
            if (_duration - _lastFrameTime >= _interval) {
                _lastFrameTime = _duration;
                _frameIndex++;

                var animMax:Int = _curAnimIndexList.length;
                if (_frameIndex >= animMax) {
                    if (_isLoop) {
                        _frameIndex = 0;
                    }
                }
                bitmap.bitmapData = _bitmapDataList[_curAnimIndexList[_frameIndex]];
            }
        }
    }
}
