// Generated by CoffeeScript 1.7.1
Game.Mixins = {};

Game.Mixins.PlayerActor = {
  name: 'PlayerActor',
  groupName: 'Actor',
  act: function(overkillMessage) {
    if (this.getHp() < 1) {
      Game.Screen.playScreen.setGameEnded(true);
      Game.sendMessage(this, overkillMessage + ' You have died... Press [Enter] to continue!');
    }
    Game.refresh();
    this.getMap().getEngine().lock();
    this.clearMessages();
  }
};

Game.Mixins.FungusActor = {
  name: 'FungusActor',
  groupName: 'Actor',
  act: function() {}
};

Game.Mixins.WanderActor = {
  name: 'WanderActor',
  groupName: 'Actor',
  act: function() {
    var moveOffset;
    moveOffset = (Math.round(Math.random()) === 1 ? 1 : -1);
    if (Math.round(Math.random()) === 1) {
      this.tryMove(this.getX() + moveOffset, this.getY(), this.getZ());
    } else {
      this.tryMove(this.getX(), this.getY() + moveOffset, this.getZ());
    }
  }
};

Game.Mixins.Attacker = {
  name: 'Attacker',
  groupName: 'Attacker',
  init: function(template) {
    this._attackValue = template['attackValue'] || 1;
  },
  getAttackValue: function() {
    return this._attackValue;
  },
  attack: function(target) {
    var attack, damage, defense, max;
    if (target.hasMixin('Destructible')) {
      attack = this.getAttackValue();
      defense = target.getDefenseValue();
      max = Math.max(0, attack - defense);
      damage = 1 + Math.floor(Math.random() * max);
      Game.sendMessage(this, 'You strike the %s for %d damage!', [target.getName(), damage]);
      Game.sendMessage(target, 'The %s strikes you for %d damage!', [this.getName(), damage]);
      target.takeDamage(this, damage);
    }
  }
};

Game.Mixins.Destructible = {
  name: 'Destructible',
  init: function(template) {
    this._maxHp = template['maxHp'] || 10;
    this._hp = template['hp'] || this._maxHp;
    this._defenseValue = template['defenseValue'] || 0;
  },
  getDefenseValue: function() {
    return this._defenseValue;
  },
  getHp: function() {
    return this._hp;
  },
  getMaxHp: function() {
    return this._maxHp;
  },
  takeDamage: function(attacker, damage) {
    var overkill, overkillMessage;
    this._hp -= damage;
    overkill = 0 - this._hp;
    if (overkill > 0) {
      overkillMessage = '%c{red}Overkill: ' + overkill + ' damage!';
    } else {
      overkillMessage = '';
    }
    if (this._hp <= 0) {
      Game.sendMessage(attacker, 'You kill the %s! %s', [this.getName(), overkillMessage]);
      if (this.hasMixin(Game.Mixins.PlayerActor)) {
        this.act(overkillMessage);
      } else {
        this.getMap().removeEntity(this);
      }
    }
  }
};

Game.Mixins.MessageRecipient = {
  name: 'MessageRecipient',
  init: function(template) {
    this._messages = [];
  },
  receiveMessage: function(message) {
    this._messages.push(message);
  },
  getMessages: function() {
    return this._messages;
  },
  clearMessages: function() {
    this._messages = [];
  }
};

Game.Mixins.Sight = {
  name: 'Sight',
  groupName: 'Sight',
  init: function(template) {
    this._sightRadius = template['sightRadius'] || 5;
  },
  getSightRadius: function() {
    return this._sightRadius;
  }
};

Game.sendMessage = function(recipient, message, args) {
  if (recipient.hasMixin(Game.Mixins.MessageRecipient)) {
    if (args) {
      message = vsprintf(message, args);
    }
    recipient.receiveMessage(message);
  }
};

Game.sendMessageNearby = function(map, centerX, centerY, centerZ, message, args) {
  var entities, i;
  if (args) {
    message = vsprintf(message, args);
  }
  entities = map.getEntitiesWithinRadius(centerX, centerY, centerZ, 5);
  i = 0;
  while (i < entities.length) {
    if (entities[i].hasMixin(Game.Mixins.MessageRecipient)) {
      entities[i].receiveMessage(message);
    }
    i++;
  }
};

Game.PlayerTemplate = {
  character: '',
  foreground: 'white',
  maxHp: 40,
  attackValue: 10,
  sightRadius: 6,
  mixins: [Game.Mixins.PlayerActor, Game.Mixins.Attacker, Game.Mixins.Destructible, Game.Mixins.MessageRecipient, Game.Mixins.Sight]
};

Game.EntityRepository = new Game.Repository('entities', Game.Entity);

Game.EntityRepository.define('fungus', {
  name: 'fungus',
  character: 'F',
  foreground: 'green',
  maxHp: 10,
  mixins: [Game.Mixins.FungusActor, Game.Mixins.Destructible]
});

Game.EntityRepository.define('bat', {
  name: 'bat',
  character: 'B',
  foreground: 'white',
  maxHp: 5,
  attackValue: 4,
  mixins: [Game.Mixins.WanderActor, Game.Mixins.Attacker, Game.Mixins.Destructible]
});

Game.EntityRepository.define('newt', {
  name: 'newt',
  character: ':',
  foreground: 'yellow',
  maxHp: 3,
  attackValue: 2,
  mixins: [Game.Mixins.WanderActor, Game.Mixins.Attacker, Game.Mixins.Destructible]
});

Game.BossRepository = new Game.Repository('entities', Game.Entity);

Game.BossRepository.define('plant', {
  name: 'plant',
  character: '',
  foreground: 'hotPink',
  maxHp: 10,
  mixins: [Game.Mixins.WanderActor]
});

Game.BossRepository.define('moon', {
  name: 'moon',
  character: '',
  foreground: 'hotPink',
  maxHp: 10,
  mixins: [Game.Mixins.WanderActor]
});

Game.BossRepository.define('cloud', {
  name: 'cloud',
  character: '',
  foreground: 'hotPink',
  maxHp: 10,
  mixins: [Game.Mixins.WanderActor]
});

Game.BossRepository.define('lock', {
  name: 'lock',
  character: '',
  foreground: 'hotPink',
  maxHp: 10,
  mixins: [Game.Mixins.WanderActor]
});

Game.BossRepository.define('fire', {
  name: 'fire',
  character: '',
  foreground: 'hotPink',
  maxHp: 10,
  mixins: [Game.Mixins.WanderActor]
});
