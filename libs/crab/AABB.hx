package crab;

class AABB {
    public var attributiveGroup:Array<AABB>;
    public var targetGroups:Map<String, Array<AABB>>;
    public var bindCoke:Coke;

    public var AABBWidth:Int;
    public var AABBHeight:Int;

    var _screenWidth:Int;
    var _screenHeight:Int;

    public function new() {
        _screenWidth = flash.Lib.current.stage.stageWidth;
        _screenHeight = flash.Lib.current.stage.stageWidth;
    }

    public function isInScreen():Bool {
        var x:Int = Std.int(bindCoke.x);
        var y:Int = Std.int(bindCoke.y);

        if (x <= 0 || x >= _screenWidth * AABBWidth ||
            y <= 0 || y >= _screenHeight * AABBHeight) {
            return false;
        } else {
            return true;
        }
    }

    //
    public function update(dt:Float) {

    }

    public function isCollideWithGroup(groupId:String):Bool {
        var group:Array<AABB> = targetGroups.get(groupId);
        if (group == null) return false;

        for (i in 0...group.length) {
            var targetBox:AABB = group[i];

            var x:Float = bindCoke.x;
            var y:Float = bindCoke.y;
            var maxX:Float = x + AABBWidth;
            var maxY:Float = y + AABBHeight;
            var tx:Float = targetBox.bindCoke.x;
            var ty:Float = targetBox.bindCoke.y;
            var maxTX:Float = tx + targetBox.AABBWidth;
            var maxTY:Float = ty + targetBox.AABBHeight;

            if (x >= maxTX) continue;
            if (maxX <= tx) continue;
            if (y >= maxTY) continue;
            if (maxY <= ty) continue;

            return true;
        }
        return false;
    }

    /*
    public function collideWithGroup(groupId:String, collideCallback) {
        var group:Array<AABB> = targetGroups.get(groupId);
        if (group == null) return;

        for (i in 0...group.length) {
            var targetBox:AABB = group[i];

            var x:Float = bindCoke.x;
            var y:Float = bindCoke.y;
            var maxX:Float = x + AABBWidth;
            var maxY:Float = y + AABBHeight;
            var tx:Float = targetBox.bindCoke.x;
            var ty:Float = targetBox.bindCoke.y;
            var maxTX:Float = tx + targetBox.AABBWidth;
            var maxTY:Float = ty + targetBox.AABBHeight;

            if (x >= maxTX) continue;
            if (maxX <= tx) continue;
            if (y >= maxTY) continue;
            if (maxY <= ty) continue;

            collideCallback();
        }
    }
    */

    public function setSize(width:Int, height:Int) {
        AABBWidth = width;
        AABBHeight = height;
    }

    public function setGroup(group:Array<AABB>) {
        attributiveGroup = group;
    }

    public function setGroups(groups:Map<String, Array<AABB>>) {
        targetGroups = groups;
    }

    public function destory() {

    }
}
