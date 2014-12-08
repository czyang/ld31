class Level {
    public static var MAP_EMPTY:Int = 0;
    public static var MAP_BLOCK:Int = 1;
    public static var MAP_PORTAL:Int = 2;

    public static var col:Int;
    public static var row:Int;

    public static var mapData:Array<Int>;

    public function new() {
        mapData = new Array<Int>();
    }

    public static function init() {
        mapData = new Array<Int>();
    }
}
