
function init()
  print("game_itemduration module started")
  connect(g_game, { onUse = onUse })
end

function terminate()
  disconnect(g_game, { onUse = onUse })
end

function onUse(location, item, subType, target)
  if item:getDurationTime() > 0 then
    print(string.format("Item %s has a duration of %d seconds.", item:getName(), item:getDurationTime()))
  end
end
