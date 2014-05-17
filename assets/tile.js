// Generated by CoffeeScript 1.7.1
Game.Tile = function(properties) {
  properties = properties || {};
  Game.Glyph.call(this, properties);
  this._walkable = properties['walkable'] || false;
  this._blocksLight = (properties["blocksLight"] !== undefined ? properties["blocksLight"] : true);
};

Game.Tile.extend(Game.Glyph);

Game.Tile.prototype.isWalkable = function() {
  return this._walkable;
};

Game.Tile.prototype.isBlockingLight = function() {
  return this._blocksLight;
};

Game.Tile.nullTile = new Game.Tile({});

Game.Tile.floorTile = new Game.Tile({
  background: 'indigo',
  walkable: true,
  blocksLight: false
});

Game.Tile.wallTile = new Game.Tile({
  background: 'black'
});

Game.Tile.stairsUpTile = new Game.Tile({
  character: '',
  foreground: 'goldenrod',
  walkable: true,
  blocksLight: true
});

Game.Tile.stairsDownTile = new Game.Tile({
  character: '',
  foreground: 'goldenrod',
  walkable: true,
  blocksLight: false
});

Game.getNeighborPositions = function(x, y) {
  var dX, dY, tiles;
  tiles = [];
  dX = -1;
  while (dX < 2) {
    dY = -1;
    while (dY < 2) {
      if (dX === 0 && dY === 0) {
        continue;
      }
      tiles.push({
        x: x + dX,
        y: y + dY
      });
      dY++;
    }
    dX++;
  }
  return tiles.randomize();
};
