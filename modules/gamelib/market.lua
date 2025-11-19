MarketMaxAmount = 2000
MarketMaxAmountStackable = 64000
MarketMaxPrice = 999999999
MarketMaxOffers = 100

MarketAction = {
  Buy = 0,
  Sell = 1
}

MarketRequest = {
  MyOffers = 0xFFFE,
  MyHistory = 0xFFFF
}

MarketOfferState = {
  Active = 0,
  Cancelled = 1,
  Expired = 2,
  Accepted = 3,
  AcceptedEx = 255
}

MarketCategory = {
  All = 0,
  Helmets = 1,
  Armors = 2,
  Legs = 3,
  Boots = 4,
  Shields = 5,  
  Amulets = 6,
  Rings = 7,
  WandsAndRods = 8,
  Axes = 9,
  Clubs = 10,
  Swords = 11,
  Distance = 12,
  Ammunition = 13,
  Unknown1 = 14,
  TibiaCoins = 254,
  MetaWeapons = 255
}

MarketCategory.First = MarketCategory.Helmets
MarketCategory.Last = MarketCategory.TibiaCoins

MarketCategoryWeapons = {
  [MarketCategory.WandsAndRods] = { slots = {255} },
  [MarketCategory.Axes] = { slots = {255, InventorySlotOther, InventorySlotLeft} },
  [MarketCategory.Clubs] = { slots = {255, InventorySlotOther, InventorySlotLeft} },
  [MarketCategory.Swords] = { slots = {255, InventorySlotOther, InventorySlotLeft} },
  [MarketCategory.Distance] = { slots = {255, InventorySlotOther, InventorySlotLeft} },
  [MarketCategory.Ammunition] = { slots = {255, InventorySlotOther, InventorySlotLeft} }
}

MarketCategoryStrings = {
  [0] = 'All',
  [1] = 'Helmets',
  [2] = 'Armors',
  [3] = 'Legs',
  [4] = 'Boots',
  [5] = 'Shields',
  [6] = 'Amulets',
  [7] = 'Rings',
  [8] = 'Wands & Rods',
  [9] = 'Axes',
  [10] = 'Clubs',
  [11] = 'Swords',
  [12] = 'Distance',
  [13] = 'Ammunition',
  [14] = 'Unknown 1', 
  [254] = 'TibiaCoins', 
  [255] = 'Weapons'
}

function getMarketCategoryName(id)
  if table.haskey(MarketCategoryStrings, id) then
    return MarketCategoryStrings[id]
  end
end

function getMarketCategoryId(name)
  local id = table.find(MarketCategoryStrings, name)
  if id then
    return id
  end
end

MarketItemDescription = {
  Armor = 1,
  Attack = 2,
  Container = 3,
  Defense = 4,
  General = 5,
  DecayTime = 6,
  Combat = 7,
  MinLevel = 8,
  MinMagicLevel = 9,
  Vocation = 10,
  Rune = 11,
  Ability = 12,
  Charges = 13,
  WeaponName = 14,
  Weight = 15,
  Imbuements = 16
}

MarketItemDescription.First = MarketItemDescription.Armor
MarketItemDescription.Last = MarketItemDescription.Weight

MarketItemDescriptionStrings = {
  [1] = 'Armor',
  [2] = 'Attack',
  [3] = 'Container',
  [4] = 'Defense',
  [5] = 'Description',
  [6] = 'Use Time',
  [7] = 'Combat',
  [8] = 'Min Level',
  [9] = 'Min Magic Level',
  [10] = 'Vocation',
  [11] = 'Rune',
  [12] = 'Ability',
  [13] = 'Charges',
  [14] = 'Weapon Type',
  [15] = 'Weight',
  [16] = 'Imbuements'
}

function getMarketDescriptionName(id)
  if table.haskey(MarketItemDescriptionStrings, id) then
    return MarketItemDescriptionStrings[id]
  end
end

function getMarketDescriptionId(name)
  local id = table.find(MarketItemDescriptionStrings, name)
  if id then
    return id
  end
end

MarketSlotFilters = {
  [InventorySlotOther] = "Two-Handed",
  [InventorySlotLeft] = "One-Handed",
  [255] = "Any"
}

MarketFilters = {
  Vocation = 1,
  Level = 2,
  Depot = 3,
  SearchAll = 4
}

MarketFilters.First = MarketFilters.Vocation
MarketFilters.Last = MarketFilters.Depot

function getMarketSlotFilterId(name)
  local id = table.find(MarketSlotFilters, name)
  if id then
    return id
  end
end

function getMarketSlotFilterName(id)
  if table.haskey(MarketSlotFilters, id) then
    return MarketSlotFilters[id]
  end
end
