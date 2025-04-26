// Данни за магазина
let currentShop = null;
let shopItems = [];
let cartItems = [];
let selectedPaymentMethod = 'cash';
let filteredItems = [];

console.log("V-Shops script.js loaded");

// DOM елементи
const shopContainer = document.getElementById('shop-container');
const shopName = document.getElementById('shop-name');
const itemsContainer = document.getElementById('items-container');
const cartItemsContainer = document.getElementById('cart-items');
const totalPrice = document.getElementById('total-price');
const itemsCount = document.getElementById('items-count');
const closeBtn = document.getElementById('close-btn');
const purchaseBtn = document.getElementById('purchase-btn');
const paymentOptions = document.querySelectorAll('.payment-option');
const searchInput = document.getElementById('search-item');
const categoryButtons = document.querySelectorAll('.category-btn');

// Елементи за pop-up известие
const successPopup = document.getElementById('success-popup');
const popupItemsCount = document.getElementById('popup-items-count');
const popupTotal = document.getElementById('popup-total');
const popupPaymentMethod = document.getElementById('popup-payment-method');

// Слушатели за събития
document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM fully loaded");
    
    // Слушател за затваряне
    closeBtn.addEventListener('click', closeShop);
    
    // Слушател за плащане
    purchaseBtn.addEventListener('click', processPurchase);
    
    // Слушатели за методи на плащане
    paymentOptions.forEach(option => {
        option.addEventListener('click', () => {
            paymentOptions.forEach(opt => opt.classList.remove('selected'));
            option.classList.add('selected');
            selectedPaymentMethod = option.dataset.method;
        });
    });
    
    // Слушател за търсене
    searchInput.addEventListener('input', filterItems);
    
    // Слушатели за категории
    categoryButtons.forEach(button => {
        button.addEventListener('click', () => {
            categoryButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');
            filterItems();
        });
    });
    
    // Слушател за ESC клавиш за затваряне на магазина
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            if (!shopContainer.classList.contains('hidden')) {
                closeShop();
            }
        }
    });
    
    // Слушател за pop-up известие (при клик да се затвори)
    successPopup.addEventListener('click', () => {
        hideSuccessPopup();
    });
    
    // Слушател за съобщения от FiveM
    window.addEventListener('message', handleMessage);
    console.log("Message event listener added");
});

// Обработка на съобщения от играта
function handleMessage(event) {
    const data = event.data;
    console.log("Received message:", data);
    
    if (data.action === 'open') {
        console.log("Opening shop:", data.shop);
        openShop(data.shop);
    } else if (data.action === 'close') {
        closeShop();
    } else if (data.action === 'update') {
        updateCart();
    } else if (data.action === 'purchaseSuccess') {
        showSuccessPopup(data.itemsCount, data.total, data.paymentMethod);
    }
}

// Отваряне на магазина
function openShop(shop) {
    console.log("openShop called with:", shop);
    currentShop = shop;
    shopItems = shop.items;
    cartItems = [];
    filteredItems = [...shopItems];
    
    shopName.textContent = shop.label;
    
    // Изчистване на търсенето и избиране на първата категория (всички)
    searchInput.value = '';
    categoryButtons.forEach((btn, index) => {
        btn.classList.toggle('active', index === 0);
    });
    
    renderItems();
    updateCart();
    
    shopContainer.classList.remove('hidden');
    console.log("Shop UI shown");
}

// Затваряне на магазина
function closeShop() {
    console.log("closeShop called");
    shopContainer.classList.add('hidden');
    cartItems = [];
    hideSuccessPopup();
    
    // Изпрати съобщение към играта, че NUI е затворен
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(resp => {
        console.log("Close response:", resp);
    }).catch(error => {
        console.error("Close fetch error:", error);
    });
}

// Филтриране на артикули по търсене и категория
function filterItems() {
    const searchTerm = searchInput.value.toLowerCase();
    const selectedCategory = document.querySelector('.category-btn.active').dataset.category;
    
    filteredItems = shopItems.filter(item => {
        const matchesSearch = item.name.toLowerCase().includes(searchTerm);
        const matchesCategory = selectedCategory === 'all' || getItemCategory(item.name) === selectedCategory;
        return matchesSearch && matchesCategory;
    });
    
    renderItems();
}

// Определяне на категорията на артикул по име
function getItemCategory(itemName) {
    // Опростена логика - може да се разшири според нуждите
    if (itemName.includes('water') || itemName.includes('cola') || itemName.includes('coffee')) {
        return 'drinks';
    } else if (itemName.includes('tosti') || itemName.includes('sandwich')) {
        return 'food';
    } else {
        return 'other';
    }
}

// Визуализация на предметите
function renderItems() {
    console.log("Rendering items:", filteredItems);
    itemsContainer.innerHTML = '';
    
    if (filteredItems.length === 0) {
        itemsContainer.innerHTML = `
            <div class="no-items">
                <i class="fas fa-search"></i>
                <p>Няма намерени артикули</p>
            </div>
        `;
        return;
    }
    
    filteredItems.forEach(item => {
        const itemCard = document.createElement('div');
        itemCard.className = 'item-card';
        itemCard.innerHTML = `
            <div class="item-img-container">
                <img src="nui://qb-inventory/html/images/${item.name}.png" onerror="this.src='img/default.png'" class="item-img">
            </div>
            <div class="item-details">
                <div>
                    <div class="item-name">${formatItemName(item.name)}</div>
                    <div class="item-description">${getItemDescription(item.name)}</div>
                </div>
                <div class="item-price-btn">
                    <div class="item-price">${item.price}$</div>
                    <button class="add-to-cart-btn"><i class="fas fa-plus"></i></button>
                </div>
            </div>
        `;
        
        const addBtn = itemCard.querySelector('.add-to-cart-btn');
        addBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            addToCart(item);
        });
        
        itemCard.addEventListener('click', () => addToCart(item));
        itemsContainer.appendChild(itemCard);
    });
}

// Форматиране на имената на предметите за по-добър изглед
function formatItemName(name) {
    return name
        .replace(/_/g, ' ')
        .replace(/\b\w/g, l => l.toUpperCase());
}

// Вземане на описание за предмет (мок данни, може да се разшири)
function getItemDescription(name) {
    const descriptions = {
        'tosti': 'Вкусен препечен сандвич',
        'water_bottle': 'Бутилка прясна вода',
        'kurkakola': 'Газирана напитка',
        'sandwich': 'Хранителен сандвич',
        'beer': 'Бутилка бира',
        'whiskey': 'Бутилка уиски',
        'vodka': 'Бутилка водка',
        'coffee': 'Чаша горещо кафе',
        'lockpick': 'Инструмент за отключване',
        'phone': 'Смартфон устройство',
        'radio': 'Комуникационно устройство',
        'weapon_knife': 'Нож за общо ползване',
        'weapon_bat': 'Бейзболна бухалка',
        'pistol_ammo': 'Боеприпаси за пистолет'
    };
    
    return descriptions[name] || 'Стандартен артикул';
}

// Добавяне към количката
function addToCart(item) {
    // Провери дали предметът вече е в количката
    const existingItem = cartItems.find(cartItem => cartItem.name === item.name);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cartItems.push({
            name: item.name,
            price: item.price,
            quantity: 1
        });
    }
    
    updateCart();
}

// Премахване от количката
function removeFromCart(itemName) {
    cartItems = cartItems.filter(item => item.name !== itemName);
    updateCart();
}

// Промяна на количеството
function changeQuantity(itemName, delta) {
    const item = cartItems.find(item => item.name === itemName);
    if (item) {
        item.quantity += delta;
        
        if (item.quantity <= 0) {
            removeFromCart(itemName);
        } else {
            updateCart();
        }
    }
}

// Обновяване на количката
function updateCart() {
    cartItemsContainer.innerHTML = '';
    
    if (cartItems.length === 0) {
        cartItemsContainer.innerHTML = `
            <div class="cart-empty">
                <i class="fas fa-shopping-basket"></i>
                <p>Количката ви е празна</p>
            </div>
        `;
        totalPrice.textContent = '0$';
        itemsCount.textContent = '0';
        return;
    }
    
    let total = 0;
    let count = 0;
    
    cartItems.forEach(item => {
        total += item.price * item.quantity;
        count += item.quantity;
        
        const cartItem = document.createElement('div');
        cartItem.className = 'cart-item';
        cartItem.innerHTML = `
            <img src="nui://qb-inventory/html/images/${item.name}.png" onerror="this.src='img/default.png'" class="cart-item-img">
            <div class="cart-item-details">
                <div class="cart-item-name">${formatItemName(item.name)}</div>
                <div class="cart-item-price">${item.price}$</div>
            </div>
            <div class="cart-item-quantity">
                <button class="quantity-btn minus-btn"><i class="fas fa-minus"></i></button>
                <span class="quantity-value">${item.quantity}</span>
                <button class="quantity-btn plus-btn"><i class="fas fa-plus"></i></button>
            </div>
            <div class="cart-item-remove"><i class="fas fa-trash"></i></div>
        `;
        
        // Добавяне на слушатели
        const minusBtn = cartItem.querySelector('.minus-btn');
        const plusBtn = cartItem.querySelector('.plus-btn');
        const removeBtn = cartItem.querySelector('.cart-item-remove');
        
        minusBtn.addEventListener('click', () => changeQuantity(item.name, -1));
        plusBtn.addEventListener('click', () => changeQuantity(item.name, 1));
        removeBtn.addEventListener('click', () => removeFromCart(item.name));
        
        cartItemsContainer.appendChild(cartItem);
    });
    
    totalPrice.textContent = `${total}$`;
    itemsCount.textContent = count;
}

// Обработка на покупка
function processPurchase() {
    if (cartItems.length === 0) return;
    console.log("Processing purchase with payment method:", selectedPaymentMethod);
    
    const total = calculateTotal();
    const count = calculateItemsCount();
    const paymentMethodText = selectedPaymentMethod === 'cash' ? 'В брой' : 'Карта';
    
    // Изпрати всички артикули наведнъж
    fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            items: cartItems,
            paymentMethod: selectedPaymentMethod
        })
    }).then(resp => {
        console.log("Buy response:", resp);
        
        // Покажи известие за успешно плащане
        showSuccessPopup(count, total, paymentMethodText);
        
        // Изчисти количката
        cartItems = [];
        updateCart();
    }).catch(error => {
        console.error("Buy fetch error:", error);
    });
}

// Изчисляване на общата сума
function calculateTotal() {
    return cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
}

// Изчисляване на общия брой артикули
function calculateItemsCount() {
    return cartItems.reduce((count, item) => count + item.quantity, 0);
}

// Показване на pop-up за успешно плащане
function showSuccessPopup(count, total, method) {
    // Задаване на стойностите
    popupItemsCount.textContent = count;
    popupTotal.textContent = `${total}$`;
    popupPaymentMethod.textContent = method;
    
    // Показване на pop-up
    successPopup.classList.remove('hidden');
    
    // Добавяне на анимация
    const popupContent = successPopup.querySelector('.popup-content');
    animateElement(popupContent, 'success-animation');
    
    // Автоматично скриване след известно време
    setTimeout(() => {
        hideSuccessPopup();
    }, 3000);
}

// Скриване на pop-up за успешно плащане
function hideSuccessPopup() {
    successPopup.classList.add('hidden');
}

// Спомагателна функция за анимирания на артикули
function animateElement(element, animation) {
    element.classList.add(animation);
    element.addEventListener('animationend', () => {
        element.classList.remove(animation);
    }, { once: true });
} 