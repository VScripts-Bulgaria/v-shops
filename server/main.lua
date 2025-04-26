local QBCore = exports['qb-core']:GetCoreObject()

-- Функция за събиране на всички предмети за магазин
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

-- Функция за проверка на правата за достъп към предмет
local function canPlayerBuyItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local playerData = Player.PlayerData
    
    -- Проверка за работа
    if item.requiredJob then
        local hasJob = false
        if type(item.requiredJob) == 'table' then
            for job, grade in pairs(item.requiredJob) do
                if playerData.job.name == job and playerData.job.grade.level >= grade then
                    hasJob = true
                    break
                end
            end
        elseif playerData.job.name == item.requiredJob then
            hasJob = true
        end
        
        if not hasJob then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.required_job'), 'error')
            return false
        end
    end
    
    -- Проверка за банда
    if item.requiredGang then
        local hasGang = false
        if type(item.requiredGang) == 'table' then
            for gang, grade in pairs(item.requiredGang) do
                if playerData.gang.name == gang and playerData.gang.grade.level >= grade then
                    hasGang = true
                    break
                end
            end
        elseif playerData.gang.name == item.requiredGang then
            hasGang = true
        end
        
        if not hasGang then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.required_job'), 'error')
            return false
        end
    end
    
    -- Проверка за лиценз
    if item.requiredLicense then
        local hasLicense = false
        if type(item.requiredLicense) == 'table' then
            for _, license in ipairs(item.requiredLicense) do
                if playerData.metadata['licences'][license] then
                    hasLicense = true
                    break
                end
            end
        elseif playerData.metadata['licences'][item.requiredLicense] then
            hasLicense = true
        end
        
        if not hasLicense then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.required_license'), 'error')
            return false
        end
    end
    
    return true
end

-- Функция за извършване на плащане
local function processPayment(source, price, paymentMethod)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    if paymentMethod == 'cash' and Config.PaymentMethods.cash then
        if Player.Functions.RemoveMoney('cash', price, 'shop-payment') then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('success.paid_with_cash', { value = price }), 'success')
            return true
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_enough_cash'), 'error')
            return false
        end
    elseif paymentMethod == 'card' and Config.PaymentMethods.card then
        if Player.Functions.RemoveMoney('bank', price, 'shop-payment') then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('success.paid_with_bank', { value = price }), 'success')
            return true
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_enough_bank'), 'error')
            return false
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.payment_method_error'), 'error')
        return false
    end
end

-- Събития

-- Отваряне на магазин с QB инвентар
RegisterNetEvent('v-shops:server:openShop', function(shopId)
    local src = source
    if not shopId then return end
    
    local shopConfig = Config.Locations[shopId]
    if not shopConfig then return end
    
    local groupData = Config.ShopGroups[shopConfig.group]
    if not groupData then return end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local items = getItemsForShop(shopId)
    local shopItems = {}
    
    for i = 1, #items do
        local item = items[i]
        
        -- Проверка на правата за предмета
        if canPlayerBuyItem(src, item) then
            item.slot = #shopItems + 1
            shopItems[#shopItems + 1] = item
        end
    end
    
    -- Отваряне на магазин с QB инвентар
    if Config.InventorySystem == 'qb' then
        exports['qb-inventory']:CreateShop({
            name = shopId,
            label = groupData.label,
            items = shopItems,
            onBuy = function(source, data)
                processPayment(source, data.price * data.amount, 'cash')
            end
        })
        exports['qb-inventory']:OpenShop(src, shopId)
    end
end)

-- Закупуване на предмет (за OX инвентар или NUI)
RegisterNetEvent('v-shops:server:buyItem', function(shopId, item, amount, paymentMethod)
    local src = source
    if not shopId or not item or not amount or amount < 1 then return end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Проверка дали предметът съществува в магазина
    local shopItems = getItemsForShop(shopId)
    local foundItem = nil
    
    for i = 1, #shopItems do
        if shopItems[i].name == item.name then
            foundItem = shopItems[i]
            break
        end
    end
    
    if not foundItem then return end
    
    -- Проверка дали играчът може да купи предмета
    if not canPlayerBuyItem(src, foundItem) then return end
    
    -- Обработка на плащането
    local totalPrice = foundItem.price * amount
    if not processPayment(src, totalPrice, paymentMethod) then return end
    
    -- Даване на предмета
    if Config.InventorySystem == 'ox' then
        exports.ox_inventory:AddItem(src, foundItem.name, amount)
    else
        Player.Functions.AddItem(foundItem.name, amount)
    end
    
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchase_complete', { value = totalPrice }), 'success')
end)

-- Callback за проверка на плащане
QBCore.Functions.CreateCallback('v-shops:server:canAfford', function(source, cb, price, paymentMethod)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    
    if paymentMethod == 'cash' and Config.PaymentMethods.cash then
        cb(Player.Functions.GetMoney('cash') >= price)
    elseif paymentMethod == 'card' and Config.PaymentMethods.card then
        cb(Player.Functions.GetMoney('bank') >= price)
    else
        cb(false)
    end
end)

-- Обработка на покупка на артикули
RegisterNetEvent('v-shops:server:buyItems', function(shopId, items, paymentMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopConfig = Config.Locations[shopId]
    if not shopConfig then return end
    
    -- Изчисляване на общата сума
    local totalPrice = 0
    local totalItems = 0
    
    for _, item in ipairs(items) do
        totalPrice = totalPrice + (item.price * item.quantity)
        totalItems = totalItems + item.quantity
    end
    
    -- Проверка дали играчът има достатъчно пари
    local hasMoney = false
    
    if paymentMethod == 'cash' and Config.PaymentMethods.cash then
        hasMoney = Player.Functions.RemoveMoney('cash', totalPrice, "shop-items")
    elseif paymentMethod == 'card' and Config.PaymentMethods.card then
        hasMoney = Player.Functions.RemoveMoney('bank', totalPrice, "shop-items")
    end
    
    if not hasMoney then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_money'), 'error')
        TriggerClientEvent('v-shops:client:purchaseFailed', src, Lang:t('error.no_money'))
        return
    end
    
    -- Добавяне на артикулите в инвентара
    local success = true
    for _, item in ipairs(items) do
        for i = 1, item.quantity do
            local info = {}
            if string.match(item.name, "weapon_") then
                info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
            end
            
            local giveItem = Player.Functions.AddItem(item.name, 1, false, info)
            if not giveItem then
                success = false
                break
            end
        end
        
        if not success then break end
    end
    
    if not success then
        -- Връщане на парите, ако има проблем с добавянето на артикули
        if paymentMethod == 'cash' and Config.PaymentMethods.cash then
            Player.Functions.AddMoney('cash', totalPrice, "shop-items-refund")
        elseif paymentMethod == 'card' and Config.PaymentMethods.card then
            Player.Functions.AddMoney('bank', totalPrice, "shop-items-refund")
        end
        
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.cant_give'), 'error')
        TriggerClientEvent('v-shops:client:purchaseFailed', src, Lang:t('error.cant_give'))
        return
    end
    
    -- Обновяване на инвентара
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items[1].name], 'add')
    
    -- Изпращане на съобщение за успех
    local paymentMethodText = paymentMethod == 'cash' and Lang:t('info.paid_cash') or Lang:t('info.paid_card')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchased') .. ' ' .. paymentMethodText, 'success')
    
    -- Трябва да се съобрази с превода
    local paymentMethodForPopup = paymentMethod == 'cash' and 'В брой' or 'Карта'
    TriggerClientEvent('v-shops:client:purchaseSuccess', src, totalItems, totalPrice, paymentMethodForPopup)
end)

-- Оригинален код за обработка на единичен артикул (запазен за съвместимост)
RegisterNetEvent('v-shops:server:buyItem', function(shopId, item, amount, paymentMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopConfig = Config.Locations[shopId]
    if not shopConfig then return end
    
    -- Създаване на съвместимост с новия формат
    TriggerEvent('v-shops:server:buyItems', shopId, {{name = item.name, price = item.price, quantity = amount}}, paymentMethod)
end) 