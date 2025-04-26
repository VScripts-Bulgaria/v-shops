local Translations = {
    success = {
        paid_with_cash = 'Платихте %{value}$ в брой',
        paid_with_bank = 'Платихте %{value}$ с карта',
        purchase_complete = 'Успешно направихте покупка за %{value}$',
    },
    error = {
        not_enough_cash = 'Нямате достатъчно пари в брой за тази покупка!',
        not_enough_bank = 'Нямате достатъчно пари в банката за тази покупка!',
        required_job = 'Нямате достъп до този магазин!',
        required_item = 'Нямате необходимия предмет за достъп до този магазин!',
        required_license = 'Нямате необходимия лиценз за този предмет!',
        payment_method_error = 'Неуспешно плащане. Моля, опитайте отново.',
    },
    info = {
        open_shop = 'Натиснете [E] за да отворите магазина',
        cash = 'Плащане в брой',
        card = 'Плащане с карта',
        cancel = 'Отказ',
        confirm = 'Потвърди',
        shop_menu = 'Магазин',
        choose_payment = 'Избор на плащане',
        total_price = 'Обща цена: %{value}$',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
}) 