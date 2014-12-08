import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;

import crab.Coke;
import crab.CokeAnim;
import crab.SpriteLib;
import crab.AABB;

@:bitmap("assets/images/ld31.png") class SpriteLibBitmapData extends flash.display.BitmapData {}
@:font("assets/04B_03__.TTF") class PixelFont extends flash.text.Font {}

class Game {
    public static var KEY_W:Int = 0;
    public static var KEY_A:Int = 1;
    public static var KEY_S:Int = 2;
    public static var KEY_D:Int = 3;

    public static var STATE_MENU:Int = 0;
    public static var STATE_RUNNING:Int = 1;
    public static var STATE_PAUSE:Int = 2;

    public static var EnemyData:Map<String, Array<Dynamic>> = [
        "Slime" => [30, 40, 20],
        "Skeleton" => [30, 40, 20],
        "Zombie" => [30, 10 , 20],
        "BullMonster" => [100, 200, 300],
    ];

    var _stage:flash.display.Stage;
    var _root:Coke;
    var _t:Float;
    var _screenScale:Float;

    public var gameState:Int;

    var _entities:Array<Entity>;
    var _controlKeys:Array<Bool>;    // WASD key State.
    var _sl:SpriteLib;
    var _isTriggerDown:Bool;
    var _lastTriggerTime:Float;
    var _triggerInterval:Float;
    var _groundLayer:Coke;
    var _objectLayer:Coke;
    var _topLayer:Coke;

    var _playerEntity:Entity;
    var _bullets:Array<Bullet>;
    var _bulletInterval:Float;
    var _blocks:Array<Block>;
    var _collideGroups:Map<String, Array<AABB>>;
    var _entityCollideGroups:Map<String, Array<Entity>>;
    var _portalA:Coke;
    var _portalB:Coke;

    var _lastOpenDoor:Float;
    var _doorDuration:Float;
    var _doorInterval:Float;

    var _mouseStageX:Float;
    var _mouseStageY:Float;

    var _hpTextField:flash.text.TextField;
    var _killTextField:flash.text.TextField;
    var _bestTextField:flash.text.TextField;
    var _gameOverTextField:flash.text.TextField;
    var _killNum:Int;
    var _best:Int;

    var _portals:Array<Point>;

    public function new(m) {
    	_stage = m.stage;
        _stage.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
        _stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
        _stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
        _stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
        _stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
        _stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
        _t = flash.Lib.getTimer() / 1000;
        _root = new Coke();
        _stage.addChild(_root);

        gameState = STATE_RUNNING;

        _screenScale = 3;
        _root.scaleX = _screenScale;
        _root.scaleY = _screenScale;

        _root.y = 48;

        _controlKeys = new Array<Bool>();
        for (i in 0...4) {
            _controlKeys.push(false);
        }
        _isTriggerDown = false;
        _lastTriggerTime = 0;

        _collideGroups = new Map<String, Array<AABB>>();
        _entityCollideGroups = new Map<String, Array<Entity>>();
        _entities = new Array<Entity>();

        Level.init();
        _portals = new Array<Point>();

        var spriteLibBitmap:BitmapData = new SpriteLibBitmapData(0, 0);
        _sl = new SpriteLib();
        _sl.loadBitmapData(spriteLibBitmap);

        _sl.makeAnim("Player", 0, 0, 96, 16, 6, 1, 6);
        _sl.makeAnim("Slime", 48, 16, 48, 16, 3, 1, 3);
        _sl.makeAnim("Skeleton", 101, 16, 48, 16, 3, 1, 3);
        _sl.makeAnim("Zombie", 48, 32, 48, 16, 3, 1, 3);
        _sl.makeImage("Pipe", 0, 16, 16, 16);
        _sl.makeImage("Map", 0, 116, 16, 12);
        _sl.makeImage("Bullet1", 0, 114, 2, 2);
        _sl.makeImage("Portal", 0, 32, 25, 7);
        _sl.makeImage("Ground", 16, 16, 16, 16);
        _sl.makeImage("TubeTop", 32, 16, 16, 16);
        _sl.makeImage("Tube", 0, 44, 16, 16);
        _sl.makeImage("Blood", 0, 196, 71, 49);
        _sl.makeImage("Shadow", 48, 51, 13, 8);

        var myFont = new PixelFont();
        var format = new flash.text.TextFormat(myFont.fontName);
        format.size = 24;
        // HP
        _hpTextField = new flash.text.TextField();
        _hpTextField.defaultTextFormat = format;
        _hpTextField.text = "HP 200";
        _hpTextField.textColor = 0xffffffff;
        _stage.addChild(_hpTextField);
        _hpTextField.x = 10;
        _hpTextField.y = 10;
        // Kill
        _killTextField = new flash.text.TextField();
        _killTextField.defaultTextFormat = format;
        _killTextField.text = "Kill 0";
        _killTextField.textColor = 0xffffffff;
        _stage.addChild(_killTextField);
        _killTextField.x = 300;
        _killTextField.y = 10;
        // Best
        _bestTextField = new flash.text.TextField();
        _bestTextField.defaultTextFormat = format;
        _bestTextField.text = "Best 0";
        _bestTextField.textColor = 0xffffffff;
        _stage.addChild(_bestTextField);
        _bestTextField.x = 550;
        _bestTextField.y = 10;
        // Game Over
        var myFont = new PixelFont();
        var format = new flash.text.TextFormat(myFont.fontName);
        format.size = 36;
        format.align = flash.text.TextFormatAlign.CENTER;
        _gameOverTextField = new flash.text.TextField();
        _gameOverTextField.defaultTextFormat = format;
        _gameOverTextField.text = "Game Over";
        _gameOverTextField.textColor = 0xffffffff;
        _stage.addChild(_gameOverTextField);
        _gameOverTextField.x = 240;
        _gameOverTextField.y = 250;
        _gameOverTextField.width = 250;
        _gameOverTextField.height = 150;
        _gameOverTextField.selectable = false;
        _gameOverTextField.visible = false;

        _killNum = 0;

        _groundLayer = new Coke();
        _root.addChild(_groundLayer);

        _objectLayer = new Coke();
        _root.addChild(_objectLayer);

        _topLayer = new Coke();
        _root.addChild(_topLayer);

        setupMap(_root);

        var t:Coke = _sl.getCoke("Bullet1");
        //_root.addChild(t);
        t.x = 100;
        t.y = 50;

        /*
        var enemy:CokeAnim = _sl.getAnim("Player");
        enemy.setAnim("right", [0, 1, 2]);
        enemy.playAnim("right");
        enemy.setBitmapOffset(-Const.CELL_WIDTH / 2, -Const.CELL_HEIGHT / 2);
        _objectLayer.addChild(enemy);

        var enemyEntity:Entity = new Entity(this);
        enemyEntity.coke = enemy;
        enemyEntity.setCrood(120, 100);
        enemyEntity.setupAABB(_collideGroups);
        addToCollideGroup("Player", enemyEntity.aabb);
        enemyEntity.setupCollideBody(_entityCollideGroups);
        addToEntityCollideGroup("Enemy", enemyEntity);
        //*/

        var player:CokeAnim = _sl.getAnim("Player");
        player.setAnim("Right", [0, 1, 2]);
        player.setAnim("Up", [3, 4, 5]);
        player.playAnim("Right");
        player.setBitmapOffset(-Const.CELL_WIDTH / 2, -Const.CELL_HEIGHT / 2);
        _objectLayer.addChild(player);

        _playerEntity = new Entity(this);
        _playerEntity.coke = player;
        _playerEntity.setCrood(100, 100);
        _playerEntity.setupAABB(_collideGroups);
        _playerEntity.setupCollideBody(_entityCollideGroups);
        _playerEntity.entityType = Entity.TYPE_PLAYER;
        _playerEntity.hp = 200;
        addToCollideGroup("Player", _playerEntity.aabb);

        _bullets = new Array<Bullet>();

        _mouseStageX = 0;
        _mouseStageY = 0;
        _triggerInterval = 0.1;

        _portalA = _sl.getCoke("Portal");
        _portalB = _sl.getCoke("Portal");
        _topLayer.addChild(_portalA);
        _topLayer.addChild(_portalB);
        var colorTransform = new flash.geom.ColorTransform();
        colorTransform.color = 0xff0bf4f8;
        _portalA.transform.colorTransform = colorTransform;
        _portalB.transform.colorTransform = colorTransform;
        _portalA.blendMode = flash.display.BlendMode.ADD;
        _portalB.blendMode = flash.display.BlendMode.ADD;

        createPortal();
        _doorDuration = 0;
        _doorInterval = Math.random() * 10;

        spawnSlime(50, 50, 10);
    }

    function onEnterFrame(_):Void {
        var s:Float = flash.Lib.getTimer() / 1000;
    	var dt:Float = s - _t;
        _t = s;
        _root.update(dt);

        _doorDuration += dt;

        if (_playerEntity != null) {
             if (_doorDuration >= _doorInterval) {
                if (_playerEntity.getState() != Entity.STATE_PORTAL) {
                    _doorDuration = 0;
                    _doorInterval = 5 + Math.random() * 10;
                    createPortal();
                }
            }

            if (_controlKeys[KEY_W]) {
                _playerEntity.moveUp();
            } else if (_controlKeys[KEY_S]) {
                _playerEntity.moveDown();
            }

            if (_controlKeys[KEY_A]) {
                _playerEntity.moveLeft();
            } else if (_controlKeys[KEY_D]) {
                _playerEntity.moveRight();
            }

            _playerEntity.update(dt);

             // Fire bullets
            if (_isTriggerDown && s - _lastTriggerTime >= _triggerInterval) {
                _lastTriggerTime = s;
                var playerX:Float = _playerEntity.coke.x;
                var playerY:Float = _playerEntity.coke.y;
                var atr:Float = Math.atan2(_mouseStageY - playerY, _mouseStageX - playerX);
                var bt:Bullet = new Bullet();
                bt.coke = _sl.getCoke("Bullet1");
                bt.setupAABB(_collideGroups);
                bt.setupCollideBody(_entityCollideGroups);
                addToCollideGroup("PlayerBullets", bt.aabb);
                bt.container = _bullets;
                bt.fire(playerX, playerY, atr);
                _root.addChild(bt.coke);
                _bullets.push(bt);
            }
        }

        var i:Int = _bullets.length - 1;
        while (i >= 0) {
            _bullets[i].update(dt);
            i--;
        }

        // Update Enemies
        var i:Int = _entities.length - 1;
        while (i >= 0) {
            _entities[i].update(dt);
            i--;
        }
        if (_entities.length <= 0) {
            var c:Int = Std.int(Math.random() * 3);
            switch(c) {
                case 0:
                    spawnZombie(80, 50, 5 + Std.int(Math.random() * 10));
                case 1:
                    spawnSkeleton(80, 50, 5 + Std.int(Math.random() * 10));
                case 2:
                    spawnZombie(80, 50, 5 + Std.int(Math.random() * 10));
            }
            
        }
    }

    function onKeyDown(event:flash.events.KeyboardEvent) {
        var keyCode:Int = event.keyCode;
        switch (keyCode) {
            case 87:
                // W
                _controlKeys[KEY_W] = true;
            case 65:
                // A
                _controlKeys[KEY_A] = true;
            case 83:
                // S
                _controlKeys[KEY_S] = true;
            case 68:
                // D
                _controlKeys[KEY_D] = true;
        }
    }

    function onKeyUp(event:flash.events.KeyboardEvent) {
        var keyCode:Int = event.keyCode;
        switch (keyCode) {
            case 87:
                // W
                _controlKeys[KEY_W] = false;
            case 65:
                // A
                _controlKeys[KEY_A] = false;
            case 83:
                // S
                _controlKeys[KEY_S] = false;
            case 68:
                // D
                _controlKeys[KEY_D] = false;
        }
    }

    function onMouseDown(event:MouseEvent) {
        _isTriggerDown = true;
        _mouseStageX = event.stageX / _screenScale;
        _mouseStageY = event.stageY / _screenScale;
    }

    function onMouseUp(event:MouseEvent) {
        _isTriggerDown = false;
    }

    function onMouseMove(event:MouseEvent) {
        if (!_isTriggerDown) return;

        _mouseStageX = event.stageX / _screenScale;
        _mouseStageY = event.stageY / _screenScale;
    }

    function setupMap(root:Coke) {
        //var pipe:Code = _sl.getCoke("Pipe");
        var mapData:BitmapData = _sl.getBitmapData("Map");
        var width:Int = mapData.width;
        var height:Int = mapData.height;
        Level.col = width;
        Level.row = height;
        for (r in 0...height) {
            for (c in 0...width) {
                var pixel:Int = mapData.getPixel(c, r);
                switch(pixel) {
                    case 0x08f8df:
                        var pipeCoke:Coke;
                        if (r == 0 && c >= 1 && c < width - 1)
                            pipeCoke = _sl.getCoke("Tube");
                        else
                            pipeCoke = _sl.getCoke("TubeTop");
                        var ground:Coke = _sl.getCoke("Ground");
                        ground.x = Const.CELL_WIDTH * c;
                        ground.y = Const.CELL_HEIGHT * r;
                        _groundLayer.addChild(ground);
                        pipeCoke.x = Const.CELL_WIDTH * c;
                        pipeCoke.y = Const.CELL_HEIGHT * r;
                        _topLayer.addChild(pipeCoke);
                        var block:Block = new Block();
                        block.coke = pipeCoke;
                        block.setupAABB(_collideGroups);
                        addToCollideGroup("Block", block.aabb);
                        Level.mapData.push(Level.MAP_BLOCK);
                    default:
                        var ground:Coke = _sl.getCoke("Ground");
                        ground.x = Const.CELL_WIDTH * c;
                        ground.y = Const.CELL_HEIGHT * r;
                        _groundLayer.addChild(ground);
                        Level.mapData.push(Level.MAP_EMPTY);
                }
            }
        }
        //Level.mapData[1] = Level.MAP_PORTAL;
        //Level.mapData[Level.mapData.length - 3] = Level.MAP_PORTAL;
    }

    function addToCollideGroup(groupId:String, aabb:AABB) {
        var collideGroup:Array<AABB> = _collideGroups.get(groupId);
        if (collideGroup == null) {
            collideGroup = new Array<AABB>();
            _collideGroups.set(groupId, collideGroup);
        }

        collideGroup.push(aabb);
    }

    function addToEntityCollideGroup(groupId:String, entity:Entity) {
        var collideGroup:Array<Entity> = _entityCollideGroups.get(groupId);
        if (collideGroup == null) {
            collideGroup = new Array<Entity>();
            _entityCollideGroups.set(groupId, collideGroup);
        }
        entity.collideContainer = collideGroup;
        collideGroup.push(entity);
    }

    function createPortal() {
        if (_portals.length > 0) {
            for (i in 0..._portals.length) {
                var op:Point = _portals.pop();
                Level.mapData[Std.int(op.x) + Std.int(op.y) * Level.col] = Level.MAP_BLOCK;
                op = null;
            }
        }

        var cx:Int = Std.int((Level.col - 2) * Math.random());
        var cy:Int = Std.int((Level.row - 2) * Math.random());
        if (cx < cy) cx = 0;
        else cy = 0;

        if (cx == cy && cx == 0) cx = 1;
        else if (cx == Level.col - 1 && cy == 0) cy = 1;
        else if (cy == Level.row - 1 && cx == 0) cx = 1;
        else if (cx == Level.col - 1 && cy == Level.row) cx = Level.col - 2;

        _portals.push(new Point(cx, cy));
        var offsetX:Int = 0;
        var offsetY:Int = 0;
        if (cx == 0) {
            _portalA.rotation = -90;
            offsetX = Const.CELL_WIDTH;
            offsetY = Const.CELL_HEIGHT + 4;
        } else if (cx == Level.col - 1) {
            offsetY = -4;
            _portalA.rotation = 90;
        } else if (cy == 0) {
            offsetX = -4;
            offsetY = Std.int(Const.CELL_HEIGHT / 2);
            _portalA.rotation = 0;
        }else if (cy == Level.row - 1) {
            _portalA.rotation = 180;
            offsetX = Const.CELL_WIDTH + 4;
        }
        _portalA.x = Std.int(cx * Const.CELL_WIDTH) + offsetX;
        _portalA.y = Std.int(cy * Const.CELL_HEIGHT) + offsetY;
        Level.mapData[cx + cy * Level.col] = Level.MAP_PORTAL;

        cx = Std.int((Level.col - 2) * Math.random());
        cy = Std.int((Level.row - 2) * Math.random());
        if (cx > cy) cx = Level.col - 1;
        else cy = Level.row - 1;

        if (cx == cy && cx == 0) cx = 1;
        else if (cx == Level.col - 1 && cy == 0) cy = 1;
        else if (cy == Level.row - 1 && cx == 0) cx = 1;
        else if (cx == Level.col - 1 && cy == Level.row) cx = Level.col - 2;

        _portals.push(new Point(cx, cy));
        var offsetX:Int = 0;
        var offsetY:Int = 0;
        if (cx == 0) {
            _portalB.rotation = -90;
            offsetX = Const.CELL_WIDTH;
            offsetY = Const.CELL_HEIGHT + 4;
        } else if (cx == Level.col - 1) {
            offsetY = -4;
            _portalB.rotation = 90;
        } else if (cy == 0) {
            offsetX = -4;
            offsetY = Std.int(Const.CELL_HEIGHT / 2);
            _portalB.rotation = 0;
        }else if (cy == Level.row - 1) {
            _portalB.rotation = 180;
            offsetX = Const.CELL_WIDTH + 4;
        }
        _portalB.x = Std.int(cx * Const.CELL_WIDTH) + offsetX;
        _portalB.y = Std.int(cy * Const.CELL_HEIGHT) + offsetY;
        Level.mapData[cx + cy * Level.col] = Level.MAP_PORTAL;
    }

    function spawnSlime(x:Int, y:Int, number:Int) {
        for (i in 0...number) {
            var enemy:CokeAnim = _sl.getAnim("Slime");
            enemy.setAnim("Normal", [0, 1, 2]);
            enemy.playAnim("Normal");
            enemy.setBitmapOffset(-Const.CELL_WIDTH / 2, -Const.CELL_HEIGHT / 2);
            _objectLayer.addChild(enemy);

            var enemyEntity:Entity = new Entity(this);
            enemyEntity.coke = enemy;
            enemyEntity.setCrood(x, y);
            enemyEntity.setupAABB(_collideGroups);
            enemyEntity.setupCollideBody(_entityCollideGroups);
            enemyEntity.entityType = Entity.TYPE_ENEMY;
            enemyEntity.attackTarget = _playerEntity;
            enemyEntity.creatureType = Entity.CREATURE_SLIME;
            enemyEntity.speed = 0.003;
            enemyEntity.hp = 5;
            enemyEntity.container = _entities;
            addToEntityCollideGroup("Enemy", enemyEntity);
            _entities.push(enemyEntity);
        }
    }

    function spawnSkeleton(x:Int, y:Int, number:Int) {
        for (i in 0...number) {
            var enemy:CokeAnim = _sl.getAnim("Skeleton");
            enemy.setAnim("Normal", [0, 1, 2]);
            enemy.playAnim("Normal");
            enemy.setBitmapOffset(-Const.CELL_WIDTH / 2, -Const.CELL_HEIGHT / 2);
            _objectLayer.addChild(enemy);

            var enemyEntity:Entity = new Entity(this);
            enemyEntity.coke = enemy;
            enemyEntity.setCrood(x, y);
            enemyEntity.setupAABB(_collideGroups);
            enemyEntity.setupCollideBody(_entityCollideGroups);
            enemyEntity.entityType = Entity.TYPE_ENEMY;
            enemyEntity.attackTarget = _playerEntity;
            enemyEntity.creatureType = Entity.CREATURE_SKELETON;
            enemyEntity.speed = 0.006;
            enemyEntity.hp = 8;
            enemyEntity.container = _entities;
            addToEntityCollideGroup("Enemy", enemyEntity);
            _entities.push(enemyEntity);
        }
    }

    function spawnZombie(x:Int, y:Int, number:Int) {
        for (i in 0...number) {
            var enemy:CokeAnim = _sl.getAnim("Zombie");
            enemy.setAnim("Normal", [0, 1, 2]);
            enemy.playAnim("Normal");
            enemy.setBitmapOffset(-Const.CELL_WIDTH / 2, -Const.CELL_HEIGHT / 2);
            _objectLayer.addChild(enemy);

            var enemyEntity:Entity = new Entity(this);
            enemyEntity.coke = enemy;
            enemyEntity.setCrood(x, y);
            enemyEntity.setupAABB(_collideGroups);
            enemyEntity.setupCollideBody(_entityCollideGroups);
            enemyEntity.entityType = Entity.TYPE_ENEMY;
            enemyEntity.attackTarget = _playerEntity;
            enemyEntity.creatureType = Entity.CREATURE_ZOMBIE;
            enemyEntity.speed = 0.008;
            enemyEntity.hp = 10;
            enemyEntity.container = _entities;
            addToEntityCollideGroup("Enemy", enemyEntity);
            _entities.push(enemyEntity);
        }
    }

    public function addBlood(creatureType:Int, bx, by) {
        switch(creatureType) {
            case Entity.CREATURE_SLIME:
                var b:Coke = _sl.getCoke("Blood");
                var colorTransform = new flash.geom.ColorTransform();
                colorTransform.color = 0xff44891a;
                b.transform.colorTransform = colorTransform;
                b.blendMode = flash.display.BlendMode.NORMAL;
                b.x = bx;
                b.y = by;
                b.rotation = 360 * Math.random();
                _groundLayer.addChild(b);
                haxe.Timer.delay(function () {
                    //func(arg1, arg2);
                    _groundLayer.removeChild(b);
                }, 10000);
            case Entity.CREATURE_ZOMBIE:
            var b:Coke = _sl.getCoke("Blood");
                var colorTransform = new flash.geom.ColorTransform();
                colorTransform.color = 0x5a2d34;
                b.transform.colorTransform = colorTransform;
                b.blendMode = flash.display.BlendMode.NORMAL;
                b.x = bx;
                b.y = by;
                b.rotation = 360 * Math.random();
                _groundLayer.addChild(b);
                haxe.Timer.delay(function () {
                    //func(arg1, arg2);
                    _groundLayer.removeChild(b);
                }, 20000);
        }
    }

    public function setHP(hp:Int) {
        hp = hp < 0 ? 0 : hp;
        _hpTextField.text = "HP " + hp;
    }

    public function setKill(kill:Int) {
        _killNum = kill;
        _killTextField.text = "Kill " + _killNum;

        if (_best < _killNum) _best = _killNum;
        _bestTextField.text = "Best " + _best;
    }   

    public function plusKill() {
        _killNum++;
        _killTextField.text = "Kill " + _killNum;

        if (_best < _killNum) _best = _killNum;
        _bestTextField.text = "Best " + _best;
    }

    public function setGameOver() {
        _gameOverTextField.visible = true;
        _gameOverTextField.text = "Game Over\n" + "You Kill " + _killNum;

        _playerEntity.coke.visible = false;

        gameState = STATE_PAUSE;

        haxe.Timer.delay(function () {
                    //func(arg1, arg2);
                    _gameOverTextField.visible = false;
                    _playerEntity.coke.visible = true;
                    _playerEntity.setCrood(100, 100);
                    _playerEntity.hp = 200;
                    setHP(_playerEntity.hp);
                    _killNum = 0;
                    setKill(_killNum);

                    var i:Int = _entities.length - 1;
                    while (i >= 0) {
                        var e:Entity = _entities.pop();
                        e.destory();
                        i--;
                    }

                    gameState = STATE_RUNNING;
                }, 5000);
    }
}
