-- Продукти за магазините
-- Този файл съдържа всички групи от продукти, които могат да се продават в магазините

Items = {}

-- Храна
Items.food = {
    { name = 'tosti', price = 2, amount = 50 },
    { name = 'water_bottle', price = 2, amount = 50 },
    { name = 'kurkakola', price = 2, amount = 50 },
    { name = 'sandwich', price = 2, amount = 50 },
}

-- Напитки
Items.drinks = {
    { name = 'water_bottle', price = 2, amount = 50 },
    { name = 'kurkakola', price = 2, amount = 50 },
    { name = 'coffee', price = 3, amount = 50 },
}

-- Алкохол
Items.alcohol = {
    { name = 'beer', price = 7, amount = 50 },
    { name = 'whiskey', price = 10, amount = 50 },
    { name = 'vodka', price = 12, amount = 50 },
}

-- Хардуер
Items.hardware = {
    { name = 'lockpick', price = 200, amount = 50 },
    { name = 'weapon_wrench', price = 250, amount = 50 },
    { name = 'weapon_hammer', price = 250, amount = 50 },
    { name = 'repairkit', price = 250, amount = 50, requiredJob = { 'mechanic', 'police' } },
    { name = 'screwdriverset', price = 350, amount = 50 },
    { name = 'cleaningkit', price = 150, amount = 50 },
}

-- Електроника
Items.electronics = {
    { name = 'phone', price = 850, amount = 50 },
    { name = 'radio', price = 250, amount = 50 },
    { name = 'fitbit', price = 400, amount = 50 },
    { name = 'tablet', price = 1000, amount = 50 },
}

-- Оръжия
Items.weapons = {
    { name = 'weapon_knife', price = 250, amount = 10 },
    { name = 'weapon_bat', price = 250, amount = 10 },
    { name = 'pistol_ammo', price = 250, amount = 50, requiredLicense = 'weapon' },
    { name = 'weapon_pistol', price = 2500, amount = 5, requiredLicense = 'weapon' },
}

-- Бензиностанция
Items.gas_station = {
    { name = 'tosti', price = 2, amount = 50 },
    { name = 'water_bottle', price = 2, amount = 50 },
    { name = 'kurkakola', price = 2, amount = 50 },
    { name = 'sandwich', price = 2, amount = 50 },
    { name = 'beer', price = 7, amount = 50 },
    { name = 'lighter', price = 2, amount = 50 },
    { name = 'rolling_paper', price = 2, amount = 50 },
}

return Items 