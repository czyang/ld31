import crab.Coke;
import crab.AABB;

class Block {
    public var coke:Coke;
    public var aabb:AABB;

    public function new() {

    }

    public function setupAABB(collideGroups:Map<String, Array<AABB>>) {
        if (coke == null) return;

        aabb = new AABB();
        aabb.bindCoke = coke;
        aabb.setSize(coke.getContentWidth(), coke.getContentHeight());
        aabb.targetGroups = collideGroups;
    }

    public function update(dt:Float) {

    }

    public function destory() {
        aabb.destory();
        coke.parent.removeChild(coke);
        coke = null;
    }
}
