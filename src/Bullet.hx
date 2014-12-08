import crab.Coke;
import crab.AABB;

class Bullet {
    public var container:Array<Bullet>;     // Update container
    public var coke:Coke;
    public var aabb:AABB;

    public var vx:Float;
    public var vy:Float;
    public var speed:Float;

    var _collideGroups:Map<String, Array<Entity>>;

    public function new() {
        speed = 150;
    }

    public function setupAABB(collideGroups:Map<String, Array<AABB>>) {
        if (coke == null) return;

        aabb = new AABB();
        aabb.bindCoke = coke;
        aabb.setSize(coke.getContentWidth(), coke.getContentHeight());
        aabb.targetGroups = collideGroups;
    }

    public function setupCollideBody(collideGroups:Map<String, Array<Entity>>) {
        if (coke == null) return;

        _collideGroups = collideGroups;
    }

    public function fire(ix:Float, iy:Float, atr:Float) {
        coke.x = ix;
        coke.y = iy;

        vx = speed * Math.cos(atr);
        vy = speed * Math.sin(atr);
    }

    public function update(dt:Float) {
        coke.x += vx * dt;
        coke.y += vy * dt;

        if(!aabb.isInScreen()) {
            destory();
            return;
        }

        // Collide with other entity.
        // Enemy
        var enemies:Array<Entity> = _collideGroups.get("Enemy");
        if (enemies != null) {
            var i:Int = enemies.length - 1;
            while(i >= 0) {
                if (collideWithEntity(enemies[i])) {
                    destory();
                    return;
                }
                i--;
            }
        }
    }

    public function collideWithEntity(e:Entity):Bool {
        var x:Float = coke.x;
        var y:Float = coke.y;
        var maxX:Float = x + coke.getContentWidth();
        var maxY:Float = y + coke.getContentHeight();
        var tx:Float = e._x;
        var ty:Float = e._y;
        var maxTX:Float = tx + e.coke.getContentWidth();
        var maxTY:Float = ty + e.coke.getContentHeight();


        tx -= coke.getContentWidth();
        ty -= coke.getContentWidth();
        maxTX -= coke.getContentWidth();
        maxTY -= coke.getContentWidth();

        if (x >= maxTX) return false;
        if (maxX <= tx) return false;
        if (y >= maxTY) return false;
        if (maxY <= ty) return false;

        e.hitByBullet(1);
        return true;
    }

    public function destory() {
        aabb.destory();
        container.remove(this);
        coke.parent.removeChild(coke);
        coke = null;
    }
}
