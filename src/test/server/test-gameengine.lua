require 'gameengine'

describe["game engine"] = function()
  before = function()
    engine = GameEngine:new()

    a = Player:new()
    b = Player:new()
  end

  after = function()
    engine = nil
    a = nil
    b = nil
  end

  it["should be able to register multiple players"] = function()
    engine:register(a)
    engine:register(b)

    expect(engine.players[1]).should_be(a)
    expect(engine.players[2]).should_be(b)
  end

  describe["when a new game starts"] = function()
    before = function()
      engine:register(a)
      engine:register(b)

      engine:start()
    end

    it["can index into any phase"] = function()
      -- fail
    end

    it["should have player a as the active player"] = function()
      expect(engine.active_player).should_be(a)
    end

    it["should start on player a's draw step"] = function()
      expect(engine.current_phase.name).should_be(Phase.DRAW)
      expect(engine.current_phase.player).should_be(a)
    end
  end
end
