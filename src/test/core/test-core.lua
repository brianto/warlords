describe["derp"] = function()
  before = function()
    card = 0
  end

  it["should be zero"] = function()
    expect(card).should_be(1) -- fail
  end
end
