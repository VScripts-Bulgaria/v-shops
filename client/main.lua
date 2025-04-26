local QBCore = exports['qb-core']:GetCoreObject()
local playerData, currentShop = nil, nil
local pedSpawned = false
local ShopPeds = {}
local isShopOpen = false  -- Променлива за проследяване на състоянието на магазина

-- Функции

-- Създаване на блипове на картата
local function createBlips()
    for shopId, shopConfig in pairs(Config.Locations) do
        local groupData = Config.ShopGroups[shopConfig.group]
        if groupData and groupData.blip and groupData.blip.show then
            local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
            SetBlipSprite(blip, groupData.blip.sprite)
            SetBlipScale(blip, groupData.blip.scale)
            SetBlipDisplay(blip, 4)
            SetBlipColour(blip, groupData.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(groupData.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

-- Създаване на NPCs (pedove)
local function createPeds()
    if pedSpawned then return end

    for shopId, shopConfig in pairs(Config.Locations) do
        local current = type(shopConfig.ped) == 'number' and shopConfig.ped or joaat(shopConfig.ped)
        RequestModel(current)
        while not HasModelLoaded(current) do Wait(0) end
        
        ShopPeds[shopId] = CreatePed(0, current, shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z - 1, shopConfig.coords.w, false, false)
        TaskStartScenarioInPlace(ShopPeds[shopId], shopConfig.scenario, 0, true)
        FreezeEntityPosition(ShopPeds[shopId], true)
        SetEntityInvincible(ShopPeds[shopId], true)
        SetBlockingOfNonTemporaryEvents(ShopPeds[shopId], true)
        
        -- Добавяне на таргет към педа
        if Config.UseTarget then
            if Config.TargetSystem == 'qb-target' then
                exports['qb-target']:AddTargetEntity(ShopPeds[shopId], {
                    options = {
                        {
                            type = "client",
                            event = "v-shops:client:openShop",
                            icon = shopConfig.targetIcon,
                            label = shopConfig.targetLabel,
                            shopId = shopId
                        }
                    },
                    distance = 2.0
                })
            elseif Config.TargetSystem == 'ox_target' then
                exports.ox_target:addLocalEntity(ShopPeds[shopId], {
                    {
                        name = 'v-shops:open_' .. shopId,
                        icon = shopConfig.targetIcon,
                        label = shopConfig.targetLabel,
                        onSelect = function()
                            openShopMenu(shopId)
                        end,
                        distance = 2.0
                    }
                })
            end
        end
    end
    pedSpawned = true
end

-- Изтриване на NPCs (pedove)
local function deletePeds()
    if not pedSpawned then return end
    for _, v in pairs(ShopPeds) do
        DeletePed(v)
    end
    pedSpawned = false
end

-- Събиране на всички предмети от група магазини
local function getItemsForShop(shopId)
    local shopConfig = Config.Locations[shopId]
    if not shopConfig then return {} end
    
    local groupData = Config.ShopGroups[shopConfig.group]
    if not groupData then return {} end
    
    local allItems = {}
    for _, itemGroup in ipairs(groupData.items) do
        for _, item in pairs(Config.Products[itemGroup]) do
            table.insert(allItems, item)
        end
    end
    
    return allItems
end

-- Проверка за изисквания за достъп до магазина
local function hasRequiredAccess(shopId)
    local shopConfig = Config.Locations[shopId]
    if not shopConfig then return false end
    
    -- Проверка за работа
    if shopConfig.requiredJob then
        local hasJob = false
        if type(shopConfig.requiredJob) == 'table' then
            for job, grade in pairs(shopConfig.requiredJob) do
                if playerData.job.name == job and playerData.job.grade.level >= grade then
                    hasJob = true
                    break
                end
            end
        elseif playerData.job.name == shopConfig.requiredJob then
            hasJob = true
        end
        
        if not hasJob then
            QBCore.Functions.Notify(Lang:t('error.required_job'), 'error')
            return false
        end
    end
    
    -- Проверка за банда
    if shopConfig.requiredGang then
        local hasGang = false
        if type(shopConfig.requiredGang) == 'table' then
            for gang, grade in pairs(shopConfig.requiredGang) do
                if playerData.gang.name == gang and playerData.gang.grade.level >= grade then
                    hasGang = true
                    break
                end
            end
        elseif playerData.gang.name == shopConfig.requiredGang then
            hasGang = true
        end
        
        if not hasGang then
            QBCore.Functions.Notify(Lang:t('error.required_job'), 'error')
            return false
        end
    end
    
    -- Проверка за предмет
    if shopConfig.requiredItem then
        local hasItem = false
        if type(shopConfig.requiredItem) == 'table' then
            for _, item in ipairs(shopConfig.requiredItem) do
                if QBCore.Functions.HasItem(item) then
                    hasItem = true
                    break
                end
            end
        elseif QBCore.Functions.HasItem(shopConfig.requiredItem) then
            hasItem = true
        end
        
        if not hasItem then
            QBCore.Functions.Notify(Lang:t('error.required_item'), 'error')
            return false
        end
    end
    
    return true
end

-- Отваряне на меню за магазин
function openShopMenu(shopId)
    if not hasRequiredAccess(shopId) then return end
    
    currentShop = shopId
    local shopItems = getItemsForShop(shopId)
    local shopConfig = Config.Locations[shopId]
    local groupData = Config.ShopGroups[shopConfig.group]
    
    print("openShopMenu called for shop: " .. shopId)
    print("InventorySystem: " .. Config.InventorySystem)
    
    if Config.InventorySystem == 'qb' then
        print("Using QB inventory")
        TriggerServerEvent('v-shops:server:openShop', shopId)
    else
        -- Показване на NUI
        print("Using NUI interface")
        isShopOpen = true  -- Маркиране, че магазинът е отворен
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            shop = {
                name = shopId,
                label = groupData.label,
                items = shopItems
            }
        })
    end
end

-- Регистриране на събитие за отваряне на магазин (за qb-target)
RegisterNetEvent('v-shops:client:openShop', function(data)
    local shopId = data.shopId
    if shopId then
        openShopMenu(shopId)
    end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    print("NUI close callback triggered")
    isShopOpen = false  -- Маркиране, че магазинът е затворен
    SetNuiFocus(false, false)
    cb({status = 'ok'})
end)

RegisterNUICallback('buyItem', function(data, cb)
    print("NUI buyItem callback triggered with data: " .. json.encode(data))
    
    local success = false
    local total = 0
    local itemsCount = 0
    
    -- Изчисляване на общото и количеството преди заявката
    for _, item in ipairs(data.items) do
        total = total + (item.price * item.quantity)
        itemsCount = itemsCount + item.quantity
    end
    
    -- Изпращане на заявката за покупка към сървъра
    TriggerServerEvent('v-shops:server:buyItems', currentShop, data.items, data.paymentMethod)
    
    -- Изпращане на успешен отговор към NUI
    cb({status = 'ok'})
end)

-- Регистриране на събитие за обработка на успешна покупка
RegisterNetEvent('v-shops:client:purchaseSuccess', function(itemsCount, total, paymentMethod)
    SendNUIMessage({
        action = 'purchaseSuccess',
        itemsCount = itemsCount,
        total = total,
        paymentMethod = paymentMethod
    })
end)

-- Регистриране на събитие за обработка на неуспешна покупка
RegisterNetEvent('v-shops:client:purchaseFailed', function(reason)
    -- Тук можете да добавите код за показване на съобщение за грешка в NUI
    QBCore.Functions.Notify(reason, 'error')
end)

-- Събития

-- Първоначално зареждане на играча
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerData = QBCore.Functions.GetPlayerData()
    createBlips()
    createPeds()
end)

-- При излизане на играча
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerData = {}
    deletePeds()
end)

-- При смяна на работата на играча
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    playerData.job = jobInfo
end)

-- При смяна на бандата на играча
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gangInfo)
    playerData.gang = gangInfo
end)

-- При стартиране на ресурса
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    playerData = QBCore.Functions.GetPlayerData()
    createBlips()
    createPeds()
end)

-- При спиране на ресурса
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deletePeds()
    SetNuiFocus(false, false)
end)

-- Слушатели за клавиши
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isShopOpen then
            DisableControlAction(0, 1, true) -- Look left/right
            DisableControlAction(0, 2, true) -- Look up/down
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end
end) 