import flash.geom.Point;

import crab.Coke;
import crab.CokeAnim;
import crab.AABB;

class Entity {
    public static var MOVE_UP:Int = 0x1;
    public static var MOVE_DOWN:Int = 0x2;
    public static var MOVE_RIGHT:Int = 0x4;
    public static var MOVE_LEFT:Int = 0x8;

    public static var STATE_NORMAL:Int = 0;
    public static var STATE_PORTAL:Int = 1;

    public static var TYPE_PLAYER:Int = 0;
    public static var TYPE_ENEMY:Int = 1;

    public static var CREATURE_SLIME:Int = 0;
    public static var CREATURE_SKELETON:Int = 1;
    public static var CREATURE_ZOMBIE:Int = 2;

    private static var SPEED:Float = 0.01;

    public var coke:Coke;
    public var aabb:AABB;
    public var entityType:Int;

    public var container:Array<Entity>;
    public var collideContainer:Array<Entity>;

    public var creatureType:Int;
    public var speed:Float;
    public var hp:Int;

    var _speed:Float;
    var _width:Float;
    var _height:Float;

    var _moveUp:Bool;
    var _moveDown:Bool;
    var _moveRight:Bool;
    var _moveLeft:Bool;

    public var _x:Int;
    public var _y:Int;
    public var _cx:Int;
    public var _cy:Int;
    var _xr:Float;  // 0-1.0
    var _yr:Float;
    public var _vx:Float;
    public var _vy:Float;

    var _state:Int;
    var _portalMoveList:Array<Point>;
    var _targetPointIndex:Int;
    var _moveTime:Float;
    var _deltaTime:Float;
    var _startX:Float;
    var _startY:Float;

    // For Enemy
    public var attackTarget:Entity;

    // Body collision.
    public var centerX:Float;
    public var centerY:Float;
    public var radius:Float;

    var _collideGroups:Map<String, Array<Entity>>;

    var _moveDirections:Int;
    var _game:Game;

    public function new(game:Game) {
        _speed = 80;

        _x = 0;
        _y = 0;
        _cx = 0;
        _cy = 0;
        _xr = 0;
        _yr = 0;
        _vx = 0;
        _vy = 0;

        hp = 5;
        creatureType = -1;

        speed = SPEED;

        _moveDirections = 0x0;
        attackTarget = null;
        _state = STATE_NORMAL;
        _portalMoveList = new Array<Point>();
        _game = game;
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
        centerX = coke.x;
        centerY = coke.y;
        radius = coke.getContentWidth() / 2;
    }

    public function moveUp() {
        _moveDirections |= MOVE_UP;
    }

    public function moveDown() {
        _moveDirections |= MOVE_DOWN;
    }

    public function moveRight() {
        _moveDirections |= MOVE_RIGHT;
    }

    public function moveLeft() {
        _moveDirections |= MOVE_LEFT;
    }

    public function setCrood(xx:Int, yy:Int) {
        _x = xx; //+ Std.int(coke.bitmap.width / 2);
        _y = yy; //+ Std.int(coke.bitmap.height / 2);
        _cx = Std.int(_x / Const.CELL_WIDTH);
        _cy = Std.int(_y / Const.CELL_HEIGHT);
        _xr = (_x - _cx * Const.CELL_WIDTH) / Const.CELL_WIDTH;
        _yr = (_y - _cy * Const.CELL_HEIGHT) / Const.CELL_HEIGHT;

        if (coke != null) {
            coke.x = _x;
            coke.y = _y;
        }
    }

    public inline function isCollide(cx:Int, cy:Int):Bool {
        if (Level.mapData[cx + cy * Level.col] == Level.MAP_BLOCK) {
            return true;
        }
        return false;
    }

    public inline function isInPortal(cx:Int, cy:Int):Bool {
        if (Level.mapData[cx + cy * Level.col] == Level.MAP_PORTAL) {
            return true;
        }
        return false;
    }

    public inline function collideWithEntity(targetEntity:Entity) {
        var dst:Float = Math.sqrt(Math.pow((targetEntity.centerX - centerX), 2) + Math.pow(targetEntity.centerY - centerY, 2));
        if (dst < radius + targetEntity.radius) {
            // Coliide.
            var angle:Float = Math.atan2(targetEntity.centerY - centerY, targetEntity.centerX - centerX);
            var repel:Float = 0.012;
            var repelX:Float = Math.cos(angle) * repel;
            var repelY:Float = Math.sin(angle) * repel;

            _vx -= repelX;
            _vy -= repelY;
            targetEntity._vx += repelX;
            targetEntity._vy += repelY;

            if (entityType == TYPE_PLAYER) {
                hp--;
                _game.setHP(hp);
            }
        }
    }

    private inline function searchPortalPath(scx:Int, scy:Int, mapData:Array<Int>) {
        var startDir:Int = Std.int(Math.random() * 4);
        var dir:Int = startDir;
        var col:Int = Level.col;
        var pcx:Int = scx;
        var pcy:Int = scy;
        var lastCX:Int = scx;
        var lastCY:Int = scy;
        var lastSucess:Bool = false;

        for (_ in 0..._portalMoveList.length) {
            _portalMoveList.pop();
        }
        _portalMoveList.push(new Point(scx, scy));

        while (true) {
            var offsetX:Int = 0;
            var offsetY:Int = 0;
            switch(dir) {
                case 0:
                    // Left.
                    offsetX--;
                case 1:
                    // Up.
                    offsetY++;
                case 2:
                    // Right.
                    offsetX++;
                case 3:
                    // Down.
                    offsetY--;
            }
            var mapDataType:Int = mapData[(pcx + offsetX) + (pcy + offsetY) * col];
            //if (mapDataType != Level.MAP_BLOCK && mapDataType != Level.MAP_PORTAL) {
            if (mapDataType == Level.MAP_EMPTY || pcx + offsetX >= Level.col || pcy + offsetY >= Level.row ||
                pcx + offsetX < 0 || pcy + offsetY < 0 ||
                (pcx + offsetX == lastCX && pcy + offsetY == lastCY)) {
                dir++;
                dir %= 4;
                if (lastSucess) {
                    _portalMoveList.push(new Point(pcx, pcy));
                }
                continue;
            } else if (mapDataType == Level.MAP_PORTAL) {
                // Find it!
                pcx += offsetX;
                pcy += offsetY;
                _portalMoveList.push(new Point(pcx, pcy));

                if(pcx == 0) _portalMoveList.push(new Point(1, pcy));
                else if (pcx == Level.col - 1) _portalMoveList.push(new Point(Level.col - 2, pcy));
                else if (pcy == 0) _portalMoveList.push(new Point(pcx, 1));
                else if (pcy == Level.row - 1) _portalMoveList.push(new Point(pcx, Level.row - 2));

                /*
                for (j in 0..._portalMoveList.length) {
                    trace("point", j, ":", _portalMoveList[j].x, _portalMoveList[j].y);
                }
                */
                break;
            }

            lastCX = pcx;
            lastCY = pcy;

            pcx += offsetX;
            pcy += offsetY;
            lastSucess = true;
        }
    }

    private inline function playAnimation(animId:String) {
        if (Std.is(coke, CokeAnim)) {
            var anim:CokeAnim = cast(coke, CokeAnim);
            if (anim.getCurAnim() != animId) {
                anim.playAnim(animId);
            }
        }
    }

    public function getPlayerFirePoint():Point {
        var rp:Point = new Point();
        if (Std.is(coke, CokeAnim)) {
            var anim:CokeAnim = cast(coke, CokeAnim);
            var curAnimId:String = anim.getCurAnim();
            switch(curAnimId) {
                case "Right":
                    if (coke.scaleX > 0) {
                        rp.x = 15;
                        rp.y = 10;
                    } else {
                        rp.x = 1;
                        rp.y = 10;
                    }
                case "Up":
                    if (coke.scaleX > 0) {
                        rp.x = 13;
                        rp.y = 10;
                    } else {
                        rp.x = 3;
                        rp.y = 10;
                    }
            }
            return rp;
        }
        return null;
    }

    public function update(dt:Float) {
        if (_state == STATE_PORTAL) {
            var tunnelSpeed:Int = 150;
            var tp:Point = _portalMoveList[_targetPointIndex];
            var tx:Int = Std.int(tp.x * Const.CELL_WIDTH);
            var ty:Int = Std.int(tp.y * Const.CELL_HEIGHT);

            if (_moveTime == 0) {
                // First Move
                var dst:Float = Math.sqrt((tx - _x) * (tx - _x) + (ty - _y) * (ty - _y));
                _moveTime = dst / tunnelSpeed;
                _startX = _x;
                _startY = _y;
            }
            _deltaTime += dt;
            var rate:Float = _deltaTime / _moveTime; //0-1.0
            rate = rate * Math.sin(Math.PI / 2);
            rate = rate > 1 ? 1 : rate;
            if (rate == 1) {
                _x = tx;
                _y = ty;
            } else {
                _x = Std.int(_startX + (tx - _startX) * rate);
                _y = Std.int(_startY + (ty - _startY) * rate);
            }
            if (rate == 1) {
                _targetPointIndex ++;
                if (_targetPointIndex >= _portalMoveList.length) {
                    // Tunnel move end.
                    _state = STATE_NORMAL;
                    setCrood(Std.int(_x), Std.int(_y));
                    return;
                }

                _deltaTime = 0;
                var tp:Point = _portalMoveList[_targetPointIndex];
                var tx:Int = Std.int(tp.x * Const.CELL_WIDTH);
                var ty:Int = Std.int(tp.y * Const.CELL_HEIGHT);
                var dst:Float = Math.sqrt((tx - _x) * (tx - _x) + (ty - _y) * (ty - _y));
                _startX = _x;
                _startY = _y;
                _moveTime = dst / tunnelSpeed;
            }

            setCrood(Std.int(_x + coke.bitmap.width / 2), Std.int(_y + coke.bitmap.height / 2));
            return;
        }


        if (entityType == TYPE_PLAYER) {
            // Keyboard input.
            if (_moveDirections & MOVE_UP == MOVE_UP) {
                _vy -= speed;
                playAnimation("Up");

            } else if (_moveDirections & MOVE_DOWN == MOVE_DOWN) {
                _vy += speed;
                playAnimation("Right");
            }

            if (_moveDirections & MOVE_RIGHT == MOVE_RIGHT) {
                _vx += speed;
                playAnimation("Right");
                if (coke.scaleX < 0) {
                    //coke.x -= Std.int(Const.CELL_WIDTH / 2);
                    coke.scaleX = 1;
                    //setCrood(Std.int(coke.x), Std.int(coke.y));
                }
            } else if (_moveDirections & MOVE_LEFT == MOVE_LEFT) {
                _vx -= speed;
                playAnimation("Right");

                if (coke.scaleX > 0) {
                    //coke.x += Std.int(Const.CELL_WIDTH / 2);
                    coke.scaleX = -1;
                    //setCrood(Std.int(coke.x), Std.int(coke.y));
                }
            }

            // Collide with Enemey
            if (_collideGroups != null) {
                var group:Array<Entity> = _collideGroups.get("Enemy");
                if (group != null) {
                    for (i in 0...group.length) {
                        collideWithEntity(group[i]);
                    }
                }
            }
        } else if (entityType == TYPE_ENEMY) {
            if (attackTarget != null) {
                var acx:Int = attackTarget._cx;
                var acy:Int = attackTarget._cy;

                if (_cx > acx) {
                    _vx -= speed;
                } else {
                    _vx += speed;
                }

                if (_cy > acy) {
                    _vy -= speed;
                } else {
                    _vy += speed;
                }
            }

            // Collide with Enemey
            if (_collideGroups != null) {
                var group:Array<Entity> = _collideGroups.get("Enemy");
                if (group != null) {
                    for (i in 0...group.length) {
                        collideWithEntity(group[i]);
                    }
                }
            }
        }

        // Cell Collision.
        var lastXR:Float = _xr;
        _xr += _vx;
        if (isCollide(_cx + 1, _cy) && _xr >= 0) {
            _vx = 0;
            _xr = 0;
        } else if (isCollide(_cx - 1, _cy) && _xr <= 0) {
            _vx = 0;
            _xr = 0;
        }
        if (_yr > 0.2) {
            if (isCollide(_cx + 1, _cy + 1) && _xr >= 0) {
                _vx = 0;
                _xr = lastXR;
            } else if (isCollide(_cx - 1, _cy + 1) && _xr <= 0) {
                _vx = 0;
                _xr = lastXR;
            }
        }
        if (_cx < 1 && _xr <= 0) {
            _xr = 0;
            _vx = 0;
        } else if (_cx > Level.col - 2 && _xr >= 0) {
            _xr = 0;
            _vx = 0;
        }
        while(_xr < 0) {
            _cx--;
            _xr++;
        }
        while(_xr > 1) {
            _cx++;
            _xr--;
        }

        var lastYR:Float = _yr;
        _yr += _vy;
        if (isCollide(_cx, _cy - 1) && _yr <= 0) {
            _vy = 0;
            _yr = 0;
        } else if (isCollide(_cx, _cy + 1) && _yr >= 0) {
            _vy = 0;
            _yr = 0;
        }
        if (_xr > 0.2) {
            if (isCollide(_cx + 1, _cy - 1) && _yr <= 0) {
                _vy = 0;
                _yr = lastYR;
            } else if (isCollide(_cx + 1, _cy + 1) && _yr >= 0) {
                _vy = 0;
                _yr = lastYR;
            }
        }
        if (_cy < 1 && _yr <= 0) {
            _yr = 0;
            _vy = 0;
        } else if (_cy > Level.row - 2 && _yr >= 0) {
            _yr = 0;
            _vy = 0;
        }
        while (_yr < 0) {
            _cy--;
            _yr++;
        }
        while (_yr > 1) {
            _cy++;
            _yr--;
        }

        _x = Std.int((_xr + _cx) * Const.CELL_WIDTH + coke.bitmap.width / 2) ;
        _y = Std.int((_yr + _cy) * Const.CELL_HEIGHT + coke.bitmap.height / 2);
        //_x = Std.int((_xr + _cx) * Const.CELL_WIDTH) ;
        //_y = Std.int((_yr + _cy) * Const.CELL_HEIGHT);

        centerX = _x;
        centerY = _y;

        coke.x = _x;
        coke.y = _y;

        _moveDirections = 0x0;

        // Portal
        var ccx:Int = Std.int(centerX / Const.CELL_WIDTH);
        var ccy:Int = Std.int(centerY / Const.CELL_HEIGHT);
        if (isInPortal(ccx, ccy)) {
            _state = STATE_PORTAL;
            _targetPointIndex = 0;
            _moveTime = 0;
            _deltaTime = 0;

            var mapData:Array<Int> = Level.mapData;
            // Find other portal
            for (i in 0...mapData.length) {
                if (mapData[i] == Level.MAP_PORTAL) {
                    var icx:Int = Std.int(i / Level.col);
                    var icy:Int = Std.int(i % Level.col);
                    if (ccy != icx || ccx != i % icy) {
                        // Get the other portal position.
                        searchPortalPath(ccx, ccy, mapData);
                        break;
                    }
                }
            }
        }

        // Firction.
        _vx *= 0.85;
        _vy *= 0.85;

        if (hp <= 0 && entityType == TYPE_PLAYER && _game.gameState == Game.STATE_RUNNING) {
             //destory();
             _game.setGameOver();
        }
    }

    public function getState():Int {
        return _state;
    }

    public function hitByBullet(v:Int) {
        hp -= v;
        if (hp <= 0) {
            _game.addBlood(creatureType, coke.x, coke.y);
            _game.plusKill();
            destory();
        }
    }

    public function destory() {
        //trace(aabb, container, collideContainer, coke);
        if (aabb != null)
            aabb.destory();
        if (container != null)
            container.remove(this);
        if (collideContainer != null)
            collideContainer.remove(this);

        if (coke != null) {
            coke.parent.removeChild(coke);
            coke = null;
        }
    }
}
