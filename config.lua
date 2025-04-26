Config = {}
Config.UseTarget = true -- Използване на target system (true/false)

-- Поддържани систем: 'qb-target', 'ox_target'
Config.TargetSystem = 'qb-target'

-- Поддържани инвентарни системи: 'qb', 'ox'
Config.InventorySystem = 'nui'

-- Платежни методи
Config.PaymentMethods = {
    cash = true, -- Разрешаване на плащане в брой
    card = true  -- Разрешаване на плащане с карта
}

-- Зареждане на продуктите от items.lua
Config.Products = Items

-- Магазин групи
Config.ShopGroups = {
    ['247'] = {
        label = '24/7 Супермаркет',
        items = {
            'food',
            'drinks', 
            'alcohol'
        },
        blip = {
            sprite = 52,
            scale = 0.6,
            color = 0,
            show = true
        }
    },
    ['hardware'] = {
        label = 'Хардуер Магазин',
        items = {
            'hardware'
        },
        blip = {
            sprite = 402,
            scale = 0.6,
            color = 0,
            show = true
        }
    },
    ['liquor'] = {
        label = 'Алкохолен Магазин',
        items = {
            'alcohol'
        },
        blip = {
            sprite = 93,
            scale = 0.6,
            color = 0,
            show = true
        }
    },
    ['ammunation'] = {
        label = 'Ammunation',
        items = {
            'weapons'
        },
        blip = {
            sprite = 110,
            scale = 0.6,
            color = 0,
            show = true
        }
    },
    ['gas_station'] = {
        label = 'Бензиностанция',
        items = {
            'gas_station'
        },
        blip = {
            sprite = 361,
            scale = 0.6,
            color = 0,
            show = true
        }
    },
    ['phone_shop'] = {
        label = 'Магазин за телефони',
        items = {
            'electronics'
        },
        blip = {
            sprite = 521,
            scale = 0.6,
            color = 0,
            show = true
        }
    }
}

-- Локации на магазините
Config.Locations = {
    -- 24/7 локации
    ['247_1'] = {
        group = '247',
        coords = vector4(24.47, -1346.62, 29.5, 271.66),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_2'] = {
        group = '247',
        coords = vector4(-3039.54, 584.38, 7.91, 17.27),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_3'] = {
        group = '247',
        coords = vector4(-3242.97, 1000.01, 12.83, 357.57),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_4'] = {
        group = '247',
        coords = vector4(1728.07, 6415.63, 35.04, 242.95),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_5'] = {
        group = '247',
        coords = vector4(1697.8, 4923.17, 42.06, 325.19),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_6'] = {
        group = '247',
        coords = vector4(1959.89, 3740.3, 32.34, 296.38),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_7'] = {
        group = '247',
        coords = vector4(549.13, 2670.85, 42.16, 99.39),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_8'] = {
        group = '247',
        coords = vector4(2677.47, 3279.76, 55.24, 332.79),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_9'] = {
        group = '247',
        coords = vector4(2556.66, 380.84, 108.62, 356.67),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },
    ['247_10'] = {
        group = '247',
        coords = vector4(372.66, 326.98, 103.57, 253.73),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-shopping-basket',
        targetLabel = 'Отвори Магазин',
    },

    -- Хардуер локации
    ['hardware_1'] = {
        group = 'hardware',
        coords = vector4(45.68, -1749.04, 29.61, 53.13),
        ped = 's_m_m_gardener_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        radius = 1.5,
        targetIcon = 'fas fa-tools',
        targetLabel = 'Отвори Магазин',
    },
    ['hardware_2'] = {
        group = 'hardware',
        coords = vector4(2747.69, 3472.86, 55.67, 255.08),
        ped = 's_m_m_gardener_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        radius = 1.5,
        targetIcon = 'fas fa-tools',
        targetLabel = 'Отвори Магазин',
    },

    -- Алкохолен магазин локации
    ['liquor_1'] = {
        group = 'liquor',
        coords = vector4(-1221.58, -908.13, 12.33, 35.49),
        ped = 'a_m_y_hipster_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-wine-bottle',
        targetLabel = 'Отвори Магазин',
    },
    ['liquor_2'] = {
        group = 'liquor',
        coords = vector4(-1486.59, -377.68, 40.16, 139.51),
        ped = 'a_m_y_hipster_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-wine-bottle',
        targetLabel = 'Отвори Магазин',
    },

    -- Ammunation локации
    ['ammunation_1'] = {
        group = 'ammunation',
        coords = vector4(-661.96, -933.53, 21.83, 177.05),
        ped = 's_m_y_ammucity_01',
        scenario = 'WORLD_HUMAN_COP_IDLES',
        radius = 1.5,
        targetIcon = 'fas fa-gun',
        targetLabel = 'Отвори Магазин',
    },
    ['ammunation_2'] = {
        group = 'ammunation',
        coords = vector4(809.68, -2159.13, 29.62, 1.43),
        ped = 's_m_y_ammucity_01',
        scenario = 'WORLD_HUMAN_COP_IDLES',
        radius = 1.5,
        targetIcon = 'fas fa-gun',
        targetLabel = 'Отвори Магазин',
    },

    -- Бензиностанция локации
    ['gas_station_1'] = {
        group = 'gas_station',
        coords = vector4(-47.42, -1758.67, 29.42, 47.26),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-gas-pump',
        targetLabel = 'Отвори Магазин',
    },
    ['gas_station_2'] = {
        group = 'gas_station',
        coords = vector4(2678.02, 3279.45, 55.24, 332.79),
        ped = 'mp_m_shopkeep_01',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-gas-pump',
        targetLabel = 'Отвори Магазин',
    },

    -- Магазин за телефони локации
    ['phone_shop_1'] = {
        group = 'phone_shop',
        coords = vector4(-656.17, -858.5, 24.49, 350.83),
        ped = 'a_m_y_business_02',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        radius = 1.5,
        targetIcon = 'fas fa-mobile-alt',
        targetLabel = 'Отвори Магазин',
    },
} 