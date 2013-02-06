class = require '30log'

Player = class {
}

GameEngine = class {
}

Phase = class {
  DRAW = 0, MAIN = 1, END = 2
}

function Phase:__init(player, name)
  self.name = name
  self.player = player
end

function GameEngine:__init()
  self.players = {}
  self.phases = {}
end

function GameEngine:start()
  self.active_player = self.players[1]

  for index, player in ipairs(self.players) do
    player.id = index

    table.insert(self.phases, Phase:new(player, Phase.DRAW))
    table.insert(self.phases, Phase:new(player, Phase.MAIN))
    table.insert(self.phases, Phase:new(player, Phase.END))
  end

  self.current_phase = self.phases[1]
end

function GameEngine:register(player)
  table.insert(self.players, player)
end

function GameEngine:next_phase()
  self.phase.after(self)
  self.phase = self.phase.next_phase
end
