package;


import lime.math.Rectangle;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.Assets;
import openfl.ui.Keyboard;
import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Back;
import motion.easing.Bounce;


class Main extends Sprite {
	public var hash : Map<String, Int> = new Map();
	public var rails: Map<Int, Array<Tile>> = new Map();
	public var spinning = false;
	public function new () {
		super ();
		var tileset = new Tileset(Assets.getBitmapData("assets/symbols.png"));
		var symbols = ['apple', 'grape', 'lemon', 'cherry', 'banana', 'watermelon', 'orange', 'bar'];
		var symbolId = 0;
		var symbolWidth = 150;
		var symbolHeight = 140;
		var symbolSpace = 0;
		var tilemap = new Tilemap (symbolWidth * 3 + symbolSpace * 2, symbolHeight * 3 + symbolSpace * 2, tileset);
		tilemap.x = stage.stageWidth / 2 - tilemap.width / 2;
		tilemap.y = stage.stageHeight / 2 - tilemap.height / 2;
		
		addChild(tilemap);
		
		for (symbol in symbols) {
			var id = tileset.addRect(new Rectangle(Std.int(symbolId % 4) * symbolWidth, Std.int(symbolId / 4) * symbolHeight, symbolWidth, symbolHeight));
			hash.set(symbol, id);
			symbolId += 1;
		}
		
		var tiles: Array<Tile> = [];
		var id = 0;
		
		for (i in 0...3) {
			for (j in 0...4) {
				var randomIndex = Math.floor(Math.random() * symbols.length);
				var tile = getTileFromSymbol(symbols[randomIndex]);
				tile.x = i * (symbolWidth + symbolSpace);
				tile.y = (j - 1) * (symbolHeight + symbolSpace);
				id += 1;
				tilemap.addTile(tile);
				if (rails.exists(i) == false) rails.set(i, []);
				rails.get(i).push(tile);
			}
		}
		
		var rails1 = {y : 0, lastY: 0}
		var rails2 = {y : 0, lastY: 0}
		var rails3 = {y : 0, lastY: 0}

		function updateTiles(deltaY, railId) {
			for (tile in rails.get(railId)) {
				tile.y += deltaY;
				if (tile.y >= tilemap.height) {
					var dy = tile.y - tilemap.height;
					tile.y = - symbolHeight - symbolSpace + dy;
					var randomIndex = Math.floor(Math.random() * symbols.length);
					tile.id = hash.get(symbols[randomIndex]);
				}
			}
		}

		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) {
			if (isSpinning()) return;
			if (e.keyCode == Keyboard.SPACE) {
				trace('Spin!');
				spinning = true;
				Actuate.tween(rails1, 2, { y: tilemap.height * 15}).ease(Back.easeOutWith(0.4)).onUpdate(function() {
					trace(rails1.y);
					var deltaY = rails1.y - rails1.lastY;
					rails1.lastY = rails1.y;
					updateTiles(deltaY, 0);
				}).onComplete(function(){
					trace('Complelte 1');
					rails1.y = 0;
					rails1.lastY = 0;
				});
				Actuate.tween(rails2, 2.25, { y: tilemap.height * 15}).ease(Back.easeOutWith(0.4)).onUpdate(function(){
					var deltaY = rails2.y - rails2.lastY;
					rails2.lastY = rails2.y;
					updateTiles(deltaY, 1);
				}).onComplete(function(){
					trace('Complelte 2');
					rails2.y = 0;
					rails2.lastY = 0;
				});
				Actuate.tween(rails3, 2.5, { y: tilemap.height * 15}).ease(Back.easeOutWith(0.4)).onUpdate(function(){
					var deltaY = rails3.y - rails3.lastY;
					rails3.lastY = rails3.y;
					updateTiles(deltaY, 2);
				}).onComplete(function(){
					spinning = false;
					trace('Complelte 3');
					rails3.y = 0;
					rails3.lastY = 0;
				});
			}
		});
		
		addEventListener(Event.ENTER_FRAME, function(e) {
			// Do something here
		});
		
	}
	
	public function isSpinning() {
		return spinning;
	}
	
	public function getTileFromSymbol(symbol) {
		return new Tile(hash.get(symbol));
	}
	
	
}