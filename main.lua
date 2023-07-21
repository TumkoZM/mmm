local com = require("component")
local computer = require("computer")
local internet = require("internet")
local unicode = require("unicode")
local string = require("string")
local md5 = require "md5"
local event = require("event")
local tunnel = com.tunnel
local me_interface = com.me_interface
local pim = com.pim
local gpu = com.gpu

event.shouldInterrupt = function() return false end


gpu.setResolution(80, 25)

_G.ProductList = {}
_G.Searcher = {}
_G.SettingMain = {}
_G.BuffTableSizeListMe = {}
_G.NowSettingShop = nil
_G.BuffTableItemList = {}
_G.BuffTableItemBalance = {}

_G.SettingMain = {
    loginShop = '6dg23frdgdrg43f34f4fsdfsd43fdgg',
    passShop = '8437812831298fg9g8fd9g8dfg943678',
    version = '0.0.1',
    http = "http://34.69.120.67/",
    ProxyTerminal = computer.address(),
    AdminShop = "Tumko",
    AdminDiscord = "tumko",
    ResMain = { gpu.getResolution() },
    color = { pattern = "%[0x(%x%x%x%x%x%x)]", background = 0x000000, pim = 0x46c8e3, gray = 0x303030,
        lightGray = 0x606060, blackGray = 0x1a1a1a, lime = 0x68f029, red = 0xff0000, green = 0x00cc00, orange = 0xf2b233,
        white = 0xffffff, blue = 0x4260f5 },
    statusUser = { user = "0x00cc00", vip = "0x46c8e3", admin = "0xff0000" }
}


_G.selectorSet = function(status, itemid, itemdmg, itemhash)
    local cl = "no"
    if tunnel ~= nil then
        if status then
            tunnel.send("ERASE")
        else
            if itemhash == '' then itemhash = 0 else cl = "yes" end
            tunnel.send(tostring("return {'" .. itemid .. "', '" .. itemdmg .. "', '" .. itemhash .. "', '" .. cl .. "'}"))
        end
    end
end
_G.clear = function(w, h) fill(1, 1, w, h, " ", SettingMain.color.background) end
_G.fill = function(x, y, w, h, symbol, background, foreground)
    if background and gpu.getBackground() ~= background then gpu.setBackground(background) end
    if foreground and gpu.getForeground() ~= foreground then gpu.setForeground(foreground) end
    gpu.fill(x, y, w, h, symbol)
end
_G.set = function(x, y, str, background, foreground)
    if background and gpu.getBackground() ~= background then gpu.setBackground(background) end
    if foreground and gpu.getForeground() ~= foreground then gpu.setForeground(foreground) end
    gpu.set(x or math.floor((SettingMain.ResMain[1] / 2) + 1 - unicode.len(tostring(str)) / 2), y, str)
end
_G.setColorText = function(x, y, str, background)
    gpu.setBackground(background)
    if not x then x = math.floor((SettingMain.ResMain[1] / 2) + 1 - unicode.len(str:gsub("%[%w+]", "")) / 2) end
    local begin = 1
    while true do
        local b, e, color = str:find(SettingMain.color.pattern, begin)
        local precedingString = str:sub(begin, b and (b - 1))
        if precedingString then
            gpu.set(x, y, precedingString)
            x = x + unicode.len(precedingString)
        end
        if not color then break end
        gpu.setForeground(tonumber(color, 16))
        begin = e + 1
    end
end
_G.Button = function(xDraw, yDraw, wB, hB, bg, fgT, textButton, textButton2, fgT2)
    local textButton = tostring(textButton)
    local posCentredText = math.floor(xDraw + (wB / 2) - (unicode.len(textButton) / 2))
    local function ifButtonxDrawNotNil(xDraw, wB)
        if xDraw == nil then
            return math.abs(43 - (wB / 2))
        else
            return xDraw
        end
    end
    fill(ifButtonxDrawNotNil(xDraw, wB), yDraw, wB, hB, " ", bg, bg)
    set(posCentredText, yDraw + 1, textButton, bg, fgT)
    if textButton2 ~= nil and fgT2 ~= nil then
        local posCentredText2 = math.floor(xDraw + (wB / 2) - (unicode.len(textButton2) / 2))
        set(posCentredText2, yDraw + 2, textButton2, bg, fgT2)
    end
end
_G.exitPim = function()
    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
    end
end
_G.LoadBaseProduct = function()
    _G.ProductList = {}
    _G.BuffTableItemBalance = {}
    BuffTableSizeListMe = {}

    local getItemErr, getItemToSell = pcall(function() return sendGET(SettingMain.http ..
        "getproduct.php?proxy=" .. computer.address()) end)
    if getItemErr and (getItemToSell ~= "error-emptytoken" or getItemToSell ~= "error-token") then
        _G.ProductList = load("return {" .. getItemToSell .. "}")()

        os.sleep(0.3)
        local getItemErr2, getItemToSell2 = pcall(function() return sendGET(SettingMain.http ..
            "itembalance.php?proxy=" .. computer.address()) end)
        if getItemErr2 and (getItemToSell2 ~= "error-emptytoken" or getItemToSell2 ~= "error-token") then
            _G.BuffTableItemBalance = load("return {" .. getItemToSell2 .. "}")()
            os.sleep(0.3)
            local getItemErr1, getItemToSell1 = pcall(function() return sendGET(SettingMain.http ..
                "needupdate.php?proxy=" .. computer.address()) end)
            if getItemErr1 == false or getItemToSell1 ~= 'success' then logDiscord(
                "(LoadBaseProduct) needupdate.php: Не смог обновить статус") end
            getItemToSell, getItemToSell1, getItemToSell2 = nil, nil, nil
        else
            logDiscord("(LoadBaseProduct) itembalance.php: Не смог получить данные")
        end
    else
        logDiscord("(LoadBaseProduct) getproduct.php: Не смог получить данные  ")
        getItemToSell = nil
    end
end
_G.UserLogin = function()
    if SettingMain.AdminShop ~= PlayerPIM then local userr, useadd = pcall(function() return computer.addUser(PlayerPIM) end) end
    _G.BuffTableSizeListM = {}
end
_G.UserLogout = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
    setColorText(nil, 13, "[0xffffff]До новых встреч, [0xf2b233]" .. PlayerPIM .. "[0xffffff]",
        SettingMain.color.gray)
    setColorText(nil, 15, "[0x46c8e3]Ждем вас снова в нашем магазине![0xffffff]",
        SettingMain.color.gray)
    local action = { "Очищаю селектор", "Завершаю сессию",
        "Обновляю список и информацию о товарах", "Очищаю временные переменные",
        "Выхожу" }
    if SettingMain.AdminShop ~= PlayerPIM then local userr, useadd = pcall(function() return computer.removeUser(
            PlayerPIM) end) end
    for o = 1, #action do
        fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
        setColorText(nil, SettingMain.ResMain[2], "[0xf2b233]" .. action[o] .. "[0xffffff]", SettingMain.color.blackGray)
        if o == 1 then selectorSet(true) end
        if o == 2 then
            local authErr1, auth1 = pcall(function() return sendGET(SettingMain.http ..
                "logout.php?TokenAuth=" ..
                NowSettingShop.TokenAuth .. "&session=" .. tostring(NowSettingShop.UserInfo.sessionID)) end)
            if authErr1 and auth1 ~= 'success' then logDiscord(auth1) end
        end
        if o == 3 and (tonumber(NowSettingShop.UpdateItemsFlag) == 1 or ProductList == nil or #ProductList == 0) then
            LoadBaseProduct() end
        if o == 4 then _G.NowSettingShop, _G.Searcher, _G.BuffTableSizeListMe = nil, {}, {} end
        os.sleep(0.1)
    end
end

_G.giveItem = function(itemName, itemDamage, itemQty, hash)
    local itemQtyGive = 0
    local itemQtyGiveReturned = 0

    local function moveItemByQty(maxAmount)
        local err, exec = pcall(function()
            if type(hash) == "string" then
                return me_interface.exportItem({
                    id = itemName,
                    dmg = itemDamage,
                    nbt_hash = hash
                }, "UP", maxAmount).size
            else
                return me_interface.exportItem(
                        { id = itemName, dmg = itemDamage }, "UP", maxAmount)
                    .size
            end
        end)
        local pimErrStatus, name = pcall(pim.getInventoryName)
        if name ~= PlayerPIM then err = false end
        if err == true then
            return exec
        else
            return 0
        end
    end

    itemQtyGive = itemQty
    while itemQtyGive > 0 do
        local numberReturn = moveItemByQty(itemQtyGive)
        if numberReturn ~= 0 then
            itemQtyGive = itemQtyGive - numberReturn
            itemQtyGiveReturned = itemQtyGiveReturned + numberReturn
        else
            return itemQtyGiveReturned
        end
    end
    return itemQtyGiveReturned
end

_G.takeItem = function(id, dmg, count)
    if (count == 0) then return 0 end
    local sum = 0
    for i = 1, 36 do
        local err, item = pcall(pim.getStackInSlot, i)
        if err == false then break end
        if item ~= nil and item.id == id and item.dmg == dmg then
            local errExec, res = pcall(function()
                return pim.pushItem("DOWN", i, count - sum)
            end)
            if errExec == false or res == nil then break end
            sum = sum + res
        end
        if (count == sum) then return sum end
    end
    return sum
end

_G.sendGET = function(path)
    local handle, data, chunk = internet.request(path), ""
    while true do
        chunk = handle.read(math.huge)
        if chunk then
            data = data .. chunk
        else
            break
        end
    end
    return data
end
_G.postRequest = function(link, msg)
    local handle, data, chunk = internet.request(SettingMain.http .. link, '{"content": "' .. msg .. '"}',
        { ["User-Agent"] = "OpenComputers", ["Content-Type"] = "application/json" }, "POST"), ""
    while true do
        chunk = handle.read(math.huge)
        if chunk then
            data = data .. chunk
        else
            break
        end
    end
    if data then return data end
    return false
end
_G.logDiscord = function(msg)
    local headers = { ["User-Agent"] = "OpenComputers", ["Content-Type"] = "application/json" }
    local err, req = pcall(function() return internet.request(
        "https://discord.com/api/webhooks/1131893092082008155/rBX1kUMLFTf0aJl04xPX2lCmlqOC2Ale5sUzuGeDC5p5w_ItnOFsOLDpiZOMLx1uVdeh",
            '{"content": "' .. string.gsub(tostring(msg), '"', '//') .. '"}', headers, "POST") end)
end

_G.logShop = function(buff)
    local logERR, SendLog = pcall(function() return postRequest('logs_shop_v2.php',
            "" .. NowSettingShop.TokenAuth .. "," .. NowSettingShop.UserInfo.sessionID .. " | " .. buff .. "") end)
    if logERR and SendLog ~= 'success' then logDiscord(SendLog) end
end

_G.AuthUsers = function()
    os.sleep(0.1)
    local pimErrStatus, name = pcall(pim.getInventoryName)
    if name == PlayerPIM then
        if _G.NowSettingShop == nil then _G.NowSettingShop = {} end
        local MyShopErr, MyShop = pcall(function() return postRequest('authshop_v2.php',
                "" ..
                SettingMain.ProxyTerminal ..
                "," .. SettingMain.loginShop .. "," .. SettingMain.passShop ..
                "," .. PlayerPIM .. "," .. SettingMain.version .. "") end)
        if MyShopErr and (MyShop ~= 'error-nodata' or MyShop ~= 'error-nodataline' or MyShop ~= 'error-notcreate') then
            _G.NowSettingShop = load("return {" .. MyShop .. "}")()
            MyShop = nil
            if tostring(NowSettingShop.StatusShop) == "open" or PlayerPIM == 'Tumko' then
                if tonumber(NowSettingShop.UserInfo.isbanned) == 0 then
                    UserLogin()
                    UpdateItemsList()
                    NewMainSceenPI()
                else
                    banned(NowSettingShop.UserInfo.textbanned)
                end
            else
                isCloseTo()
            end
        else
            ErrSend("(AuthUsers) authshop_v2.php ERROR!")
        end
    else
        os.sleep(0.3)
        mainScreenShop()
    end
end


_G.UpdateItemsList = function()
    BuffTableSizeListMe = {}
    local err5, MEitems = pcall(function() return me_interface.getAvailableItems("none") end)
    if err5 and #MEitems > 0 then
        for o = 1, #MEitems do
            table.insert(BuffTableSizeListMe, { item = MEitems[o].fingerprint, size = MEitems[o].size })
        end
    end
    MEitems = nil
end

_G.UpdateBalanceList = function()
    _G.BuffTableItemBalance = {}
    local getItemErr2, getItemToSell2 = pcall(function() return sendGET(SettingMain.http ..
        "itembalance.php?proxy=" .. computer.address()) end)
    if getItemErr2 and (getItemToSell2 ~= "error-emptytoken" or getItemToSell2 ~= "error-token") then
        _G.BuffTableItemBalance = load("return {" .. getItemToSell2 .. "}")()
    else
        logDiscord("(LoadBaseProduct) itembalance.php: Не смог получить данные")
    end
    getItemToSell2 = nil
end

_G.CountBalanceList = function()
    local countList
    local CountErr, CountBalance = pcall(function() return sendGET(SettingMain.http ..
        "itembalancecount.php?TokenAuth=" .. NowSettingShop.TokenAuth) end)
    if CountErr and (CountBalance ~= "error-emptytoken" or CountBalance ~= "error-token") then
        countList = tonumber(CountBalance)
    else
        logDiscord("(CountBalanceList) itembalancecount.php: Не смог получить данные")
    end
    CountBalance = nil
    return countList
end


_G.headerScreen = function(bal)
    if bal == nil then bal = NowSettingShop.UserInfo.balance end
    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    local UserBalance = tonumber(string.format("%.3f", tonumber(bal)))
    setColorText(3, 2, "[0xf2b233]Баланс: [0x46c8e3]" .. UserBalance .. "[0xf2b233] эм.[0xffffff]",
        SettingMain.color.blackGray)
end

_G.updateBaseItem = function()
    local itemInMeNowErr, itemInMeNow = pcall(function() return me_interface.getAvailableItems("all") end)
    if itemInMeNowErr and #itemInMeNow > 0 then
        local arr = ''
        for all = 1, #itemInMeNow do
            local itemhash, dop = '', '';
            if itemInMeNow[all].fingerprint.nbt_hash ~= nil then itemhash = itemInMeNow[all].fingerprint.nbt_hash end
            if all ~= #itemInMeNow then dop = " | " end
            arr = arr ..
            '' ..
            itemInMeNow[all].fingerprint.id ..
            ',' ..
            itemInMeNow[all].fingerprint.dmg ..
            ',' .. itemhash .. ',' .. itemInMeNow[all].item.max_size .. ',' ..
            itemInMeNow[all].item.display_name .. '' .. dop
        end
        os.sleep(0.2)

        local msg = arr
        local headers = { ["User-Agent"] = "OpenComputers", ["Content-Type"] = "application/json" }
        msg = string.gsub(msg, '"', '//"')
        local errSend, Send = pcall(function() return postRequest(
            "loadbase.php?page=load&TokenAuth=" .. NowSettingShop.TokenAuth, arr) end)
        if Send == 'error-token' or Send == 'error-emptytoken' then logDiscord("(updateBaseItem) loadbase.php: " ..
            tostring(Send)) end
    else
        logDiscord("Proxy: " .. SettingMain.ProxyTerminal .. ", что то случилось с мэ во время обновления товаров")
    end
end


_G.banned = function(text)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.blackGray)
    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.gray)
    setColorText(nil, 2, "[0xf2b233]Вы заблокированы в магазине![0xffffff]",
        SettingMain.color.gray)
    setColorText(nil, 12, "[0xf2b233]Уважаемый пользователь![0xffffff]", SettingMain.color
    .blackGray)
    setColorText(nil, 14, "[0x46c8e3]Ваш аккаунт заблокирован администрацией магазина![0xffffff]",
        SettingMain.color.blackGray)
    setColorText(nil, 15, "[0x46c8e3]Для получения остатка баланса, если он был, пишите в DS![0xffffff]",
        SettingMain.color.blackGray)
    if text ~= nil and text ~= '' then
        setColorText(nil, 17, "[0xf2b233]Причина блокировки:[0xffffff]", SettingMain.color.blackGray)
        setColorText(nil, 18, "[0xff0000]" .. text .. "[0xffffff]", SettingMain.color.blackGray)
    end
    setColorText(2, SettingMain.ResMain[2] - 1,
        "[0x606060]Crafted with by [0xf2b233]" ..
        SettingMain.AdminShop .. "[0x46c8e3] [0x00cc00] Discord: [0xf2b233]" .. SettingMain.AdminDiscord .. "[0xffffff] ",
        SettingMain.color.blackGray)
    exitPim()
end

_G.ErrSend = function(textErr)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.blackGray)
    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.gray)
    setColorText(nil, 2, "[0xf2b233]Произошла ошибка![0xffffff]", SettingMain.color.gray)
    setColorText(nil, 13, "[0xf2b233]Произошел сбой в работе магазина[0xffffff]",
        SettingMain.color.blackGray)
    setColorText(nil, 15, "[0x46c8e3]Администрация магазина уже получила текст ошибки[0xffffff]",
        SettingMain.color.blackGray)
    setColorText(nil, 16, "[0x46c8e3]Мы постараемся устранить ее в самое ближайшее время![0xffffff]",
        SettingMain.color.blackGray)

    set(2, 27, "" .. textErr .. "", SettingMain.color.blackGray)
    logDiscord(textErr)
    exitPim()
end


_G.LoaditemAfterBoot = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(34, 2, "[0xf2b233]Обновление магазина![0xffffff]", SettingMain.color.blackGray)
    setColorText(23, 13, "[0xf2b233]В данный момент идет обновление магазина![0xffffff]",
        SettingMain.color.gray)
    setColorText(26, 15, "[0x46c8e3]Просим вас подождать или зайти позже[0xffffff]",
        SettingMain.color.gray)
    setColorText(17, 16, "[0x46c8e3]Приносим свои извинения за предоставленные неудобства[0xffffff]",
        SettingMain.color.gray)

    local function loadPersent(timeSleep, Steps, perForStep)
        local Start = 0
        setColorText(82, 27, "[0xf2b233]" .. Start .. "%[0xffffff]", SettingMain.color.blackGray)
        for h = 1, Steps do
            fill(82, 27, 4, 1, " ", 0x1a1a1a)
            if h < Steps then setColorText(82, 27, "[0xf2b233]" .. Start .. "%[0xffffff]", SettingMain.color.blackGray) else
                setColorText(82, 27, "[0xf2b233]100%[0xffffff]", SettingMain.color.blackGray) end
            os.sleep(timeSleep)
            Start = Start + perForStep
        end
    end

    fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
    setColorText(2, 27, "[0xf2b233]Загружаю список товаров[0xffffff]", SettingMain.color.blackGray)
    LoadBaseProduct()
    fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
    setColorText(2, 27, "[0xf2b233]Запускаю магазин[0xffffff]", SettingMain.color.blackGray)
    loadPersent(0.2, 7, 15)
    os.sleep(0.5)
    mainScreenShop()
end


_G.isCloseTo = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(nil, 2, "[0xf2b233]Магазин закрыт![0xffffff]", SettingMain.color.blackGray)
    setColorText(nil, 12, "[0x46c8e3]Уважаемый покупатель![0xffffff]", SettingMain.color.gray)
    set(nil, 14, "По техническим причинам магазин временно закрыт!",
        SettingMain.color.gray)
    set(nil, 15, "Заходите к нам позднее", SettingMain.color.gray)
    setColorText(nil, 18, "[0xf2b233]Приносим свои извинения![0xffffff]", SettingMain.color.gray)
    exitPim()
end

_G.mainScreenShop = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, 80, 25, " ", SettingMain.color.blackGray)
    setColorText(18, 25, "[0x7D7D7D]По любым проблемам пишите в Discord: [0x42c8e3]" .. SettingMain.AdminDiscord .. "", SettingMain.color.blackGray)
    setColorText(SettingMain.ResMain[1] - 6, SettingMain.ResMain[2], "[0xf2b233]v" .. SettingMain.version .. "[0xffffff] ", SettingMain.color.blackGray)
		
	setColorText(30, 22, "[0xc49029]Валюта: [0xFFFFFF]Osaka Coins", SettingMain.color.blackGray)
    setColorText(21, 11, "[0x7D7D7D]Встаньте на [0x64c8ff]PIM[0x7D7D7D], и нажмите пкм по экрану", SettingMain.color.blackGray)			
	setColorText(4, 3, "[0xFFFFFF] ██████╗  ██████   ██   ██╗  ██╗   ██      ██████╗██╗  ██╗ █████╗ ██████╗ ", SettingMain.color.blackGray)
	setColorText(4, 4, "[0xFFFFFF]██╔═══██╗██╔════╝ ████  ██║ ██╔╝  ████    ██╔════╝██║  ██║██╔══██╗██╔══██╗", SettingMain.color.blackGray)
	setColorText(4, 5, "[0xFFFFFF]██║   ██║╚█████╗ ██  ██ █████╔╝  ██  ██   ╚█████╗ ███████║██║  ██║██████╔╝", SettingMain.color.blackGray)
	setColorText(4, 6, "[0xFFFFFF]██║   ██║ ╚═══██╗██████ ██╔═██╗  ██████    ╚═══██╗██╔══██║██║  ██║██╔═══╝ ", SettingMain.color.blackGray)
	setColorText(4, 7, "[0xFFFFFF]╚██████╔╝██████╔╝██  ██ ██║  ██╗ ██  ██   ██████╔╝██║  ██║╚█████╔╝██║     ", SettingMain.color.blackGray)
	setColorText(4, 8, "[0xFFFFFF] ╚═════╝ ╚═════╝ ╚╝  ╚╝ ╚═╝  ╚═╝ ╚╝  ╚╝   ╚═════╝ ╚═╝  ╚═╝ ╚════╝ ╚═╝     ", SettingMain.color.blackGray)

			computer.beep(444, 0.1)
			selector.setSlot(1, { ["id"] = "minecraft:blaze_powder",["dmg"] = 0 })
local pimGeometry = {
    x = 11,
    y = 12,

    "                     ⡏⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹                      ",
    "                     ⡇ ⡏⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹ ⢸                      ",
    "                     ⡇ ⡇          ⢸ ⢸                      ",
    "                     ⡇ ⡇          ⢸ ⢸                      ",
    "                     ⡇ ⡇          ⢸ ⢸                      ",
    "                     ⡇ ⡇          ⢸ ⢸                      ",
    "                     ⡇ ⣇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣸ ⢸                     ",
    "                     ⣇⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣸                      "

}
    local function drawPim()
        for str = 1, #pimGeometry do
            set(pimGeometry.x, pimGeometry.y + str, pimGeometry[str], SettingMain.color.blackGray, SettingMain.color.pim)
        end
    end
    drawPim()
    PlayerPIM = nil
    while true do
        local s = { computer.pullSignal(0) }
        if s[1] ~= "player_on" and s[1] ~= "player_off" then
            errPlayerPIM, PlayerPIM = pcall(pim.getInventoryName)
            if math.modf(me_interface.getStoredPower()) <= 0 then
                setColorText(27, 23, "[0xf2b233]Не доступна МЭ сеть, зайди позже[0xffffff]",
                    SettingMain.color.blackGray)
            elseif PlayerPIM ~= "pim" then
                setColorText(27, 23, "[0xf2b233]Идет загрузка магазина, подождите![0xffffff]",
                    SettingMain.color.blackGray)
                AuthUsers()
            end
        end
        os.sleep(0);
    end
end

_G.NewMainSceenPI = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    local UserInfo = NowSettingShop.UserInfo
    if UserInfo.agreement == 0 and UserInfo.status ~= 'admin' then UserAgreement() end
    headerScreen()
    fill(1, 4, SettingMain.ResMain[1], 24, " ", SettingMain.color.gray)

    set(69, 2, " Личный кабинет ", SettingMain.color.lightGray)
    setColorText(73, SettingMain.ResMain[2] - 1, "[0x46c8e3][ ПОМОЩЬ ][0xf2b233]", SettingMain.color.lightGray)

    setColorText(nil, 7, "[0x46c8e3] Добро пожаловать [0xf2b233]" ..
    PlayerPIM .. "[0x46c8e3] в магазин![0xffffff]", SettingMain.color.gray)
    Button(28, 10, 32, 4, SettingMain.color.blackGray, SettingMain.color.orange, ' Купить товары',
        'за валюту магазина', SettingMain.color.pim)
    Button(28, 16, 32, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Пополнить баланс',
        'за игровые ресурсы', SettingMain.color.pim)

    setColorText(2, SettingMain.ResMain[2] - 1,
        "[0xffffff]Crafted with by [0xf2b233]" ..
        SettingMain.AdminShop .. "[0x46c8e3] [0x00cc00] Discord: [0xf2b233]" .. SettingMain.AdminDiscord .. "[0xffffff] ",
        SettingMain.color.gray)


    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
        if s and s[1] == "key_down" and UserInfo.status == 'admin' then
            if (s[3] == 0 and s[4] == 63) then UPDATECODENOW() end
            if (s[3] == 0 and s[4] == 64) then
                _G.BuffTableSizeListMe, _G.BuffTableItemList = {}, {}
                LoadBaseProduct()
                mainScreenProduct()
            end
            if (s[3] == 0 and s[4] == 65) then
                fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
                setColorText(nil, SettingMain.ResMain[2],
                    "[0xf2b233]Отправляю базу товаров на сервер, подождите![0xffffff]",
                    SettingMain.color.blackGray)
                updateBaseItem()
                fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.background)
            end
        end
        if s and s[1] == "touch" then
            if (s[3] >= 69 and s[3] <= 85) and (s[4] == 2) then PersonalArea() end
            if (s[3] >= 73 and s[3] <= 85) and (s[4] == SettingMain.ResMain[2] - 1) then UserAgreement() end
            if (s[3] >= 28 and s[3] <= 60) and (s[4] >= 10 and s[4] <= 14) then mainScreenProduct() end
            if (s[3] >= 28 and s[3] <= 60) and (s[4] >= 16 and s[4] <= 20) then balance() end
        end
    end
end

_G.PersonalArea = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)

    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(nil, 2,
        "[[" ..
        SettingMain.statusUser[NowSettingShop.UserInfo.status] ..
        "]" .. NowSettingShop.UserInfo.status .. "[0xffffff]] [0xf2b233]" .. PlayerPIM .. "[0xffffff]",
        SettingMain.color.blackGray)

    Button(2, 4, 20, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Ваш баланс',
        "" .. NowSettingShop.UserInfo.balance .. "", SettingMain.color.pim)
    Button(23, 4, 20, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Визиты',
        "" .. NowSettingShop.UserStatic.visit .. "", SettingMain.color.pim)
    Button(44, 4, 20, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Потрачено',
        "" .. NowSettingShop.UserStatic.buy .. "", SettingMain.color.pim)
    Button(65, 4, 20, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Пополнено',
        "" .. NowSettingShop.UserStatic.balance .. "", SettingMain.color.pim)



    fill(1, 4, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
    fill(1, 7, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)


    fill(1, 25, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(3, 26, "[0xf2b233] < В меню [0xffffff]", SettingMain.color.lightGray)
    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end

        if s and s[1] == "touch" then
            if (s[3] >= 3 and s[3] <= 13) and (s[4] == 26) then NewMainSceenPI() end
        end
    end
end

_G.UserAgreement = function()
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)

    fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(nil, 2, "[0xf2b233]Пользовательское соглашение[0xffffff]",
        SettingMain.color.blackGray)
    local agreement = NowSettingShop.UserInfo.agreement

setColorText(nil, 5, "Добро пожаловать в [0xf2b233]ПК МАГАЗИН![0xffffff]. Наша основная валюта - [0x64c8ff] Osaka Coins. ", SettingMain.color.gray)
setColorText(2, 7, "[0x64c8ff]Osaka Coins[0xffffff] является внутренней валютой магазина, предназначенной для покупок.", SettingMain.color.gray)
setColorText(2, 8, "Однако, учтите, что она не имеет статуса валюты сервера![0xffffff] Для совершения", SettingMain.color.gray)
setColorText(2, 10, "покупок вам необходимо пополнить баланс [0xf2b233]ресурсами[0xffffff] Запомните, что ", SettingMain.color.gray)
setColorText(2, 11, "нарушение правил может привести к бану в магазине Вы будете забанены, если", SettingMain.color.gray)
set(2, 12, "попытаетесь нарушить работу магазина в своих корыстных целях.Это означает, что если", SettingMain.color.gray)
set(2, 13, "вы умышленно пытаетесь 'крашнуть' магазин или обойти его ограничения и запреты", SettingMain.color.gray)
set(2, 15, "с целью получения выгоды, такой как переобогащение товарами,вы будете подвержены", SettingMain.color.gray)
set(2, 16, "бану. В случае бана аккаунта в магазине, остаток вашего баланса будет возвращен ", SettingMain.color.gray)
set(2, 17, "в удобных для администрации магазина игровых ресурсах. Мы вернем ваш остаток", SettingMain.color.gray)
set(2, 18, "в виде булыжника, пчелиного воска, угля и других подобных предметов.", SettingMain.color.gray)
setColorText(nil, 19, "[0xf2b233]Магазин [0xff0000]НЕ принимает[0xf2b233] обратно купленные товары и [0xff0000]НЕ делает[0xf2b233] откаты по сделкам[0xffffff]", SettingMain.color.gray)


    function agreementSend(player)
        fill(1, 22, SettingMain.ResMain[1], 5, " ", SettingMain.color.gray)
        fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
        setColorText(nil, SettingMain.ResMain[2], "[0xf2b233]Идет подпись пользовательского соглашения[0xffffff]",
            SettingMain.color.blackGray)
        local loadBufferr, loadBuff = pcall(function() return sendGET(SettingMain.http ..
            "agreement.php?TokenAuth=" .. NowSettingShop.TokenAuth .. "&player=" .. player) end)
        if loadBufferr and loadBuff == 'success' then
            NowSettingShop.UserInfo.agreement = 1
            fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.blackGray)
            setColorText(nil, SettingMain.ResMain[2], "[0xf2b233]Готово! Удачных покупок в нашем магазине![0xffffff]",
                SettingMain.color.blackGray)
            os.sleep(1)
            NewMainSceenPI()
        else
            fill(1, SettingMain.ResMain[2], SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
            setColorText(nil, SettingMain.ResMain[2],
                "[0xf2b233]Произошла ошибка! Попробуйте еще раз! (" ..
                loadBuff .. ")[0xffffff]", SettingMain.color.blackGray)
            os.sleep(1)
            UserAgreement()
        end
    end

    if agreement == 0 then
        setColorText(nil, 22,
            "[0xf2b233]Нажав кнопку [0x46c8e3]<Принять>[0xf2b233], Вы принимаете условия Пользовательского соглашения[0xffffff]",
            SettingMain.color.gray)
        Button(28, 24, 31, 3, SettingMain.color.lightGray, SettingMain.color.pim, 'Принять')
    else
        setColorText(nil, 22, "[0xf2b233]Вы уже приняли Пользовательское соглашение, соблюдайте правила![0xffffff]",
            SettingMain.color.gray)
        Button(28, 24, 31, 3, SettingMain.color.lightGray, SettingMain.color.pim, 'В меню')
    end

    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end

        if s and s[1] == "touch" then
            if agreement == 0 then
                if (s[3] >= 28 and s[3] <= 59) and (s[4] >= 24 and s[4] <= 26) then agreementSend(PlayerPIM) end
            else
                if (s[3] >= 28 and s[3] <= 59) and (s[4] >= 24 and s[4] <= 26) then NewMainSceenPI() end
            end
        end
    end
end


_G.mainScreenProduct = function(GoToPage)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    headerScreen()
    fill(1, 4, SettingMain.ResMain[1], 24, " ", SettingMain.color.gray)
    fill(1, 4, SettingMain.ResMain[1], 1, " ", SettingMain.color.lightGray)
    setColorText(4, 4, "[0xf2b233]Наименование товара[0xffffff]", SettingMain.color.lightGray)
    setColorText(72, 4, "[0xf2b233]Цена за 1 шт[0xffffff]", SettingMain.color.lightGray)
    fill(1, SettingMain.ResMain[2] - 2, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(2, SettingMain.ResMain[2] - 1, "[0xf2b233] < В меню [0xffffff]", SettingMain.color.gray)
    if #ProductList == 0 then
        setColorText(nil, 14, "[0xf2b233]Список товаров, пуст![0xffffff]", SettingMain.color.gray)
    else
        CurrentPage, MaxItemToPage, StartDrawLine = 1, 18, 6
        if GoToPage ~= nil then CurrentPage = GoToPage end
        BuffTableItemList = {}
        BuffTableItemList = ProductList
        BuffFuncResult = {}

        function navigationTable(CurrentPage, MaxItemToPage, CountAllItemInList)
            local maxPage = math.ceil(CountAllItemInList / MaxItemToPage)
            if CurrentPage == nil or CurrentPage < 1 then CurrentPage = 1 end
            if CurrentPage >= maxPage then CurrentPage = maxPage end
            return { CurrentPage, maxPage, CountAllItemInList }
        end

        function getParamForItem(navigationTableResult)
            local result = {}
            if navigationTableResult[2] == 1 then
                result = { 1, navigationTableResult[3] }
            else
                if #BuffFuncResult == 0 then
                    local StartNav = 0
                    for v = 1, navigationTableResult[2] do
                        if v == 1 then
                            table.insert(BuffFuncResult, { 1, MaxItemToPage })
                        elseif v > 1 and v < navigationTableResult[2] then
                            table.insert(BuffFuncResult, { (StartNav + 1), ((StartNav) + MaxItemToPage) })
                        elseif v == navigationTableResult[2] then
                            table.insert(BuffFuncResult, { (StartNav + 1), navigationTableResult[3] })
                        end
                        StartNav = StartNav + MaxItemToPage
                    end

                    result = { BuffFuncResult[navigationTableResult[1]][1], BuffFuncResult[navigationTableResult[1]][2] }
                else
                    result = { BuffFuncResult[navigationTableResult[1]][1], BuffFuncResult[navigationTableResult[1]][2] }
                end
            end
            return result
        end

        function DrawItemList()
            listOnClick = {}
            fill(1, StartDrawLine, SettingMain.ResMain[1], MaxItemToPage, " ", SettingMain.color.gray)
            local buffLineDraw = StartDrawLine
            local navigation = navigationTable(CurrentPage, MaxItemToPage, #BuffTableItemList)
            local ParamForItem = getParamForItem(navigation)

            local zebra, coloravailabilityFlag = '', ''
            for i = ParamForItem[1], ParamForItem[2] do
                local availabilityFlag, SizeItemToMe = false, 0
                local z1, z2 = math.modf(i / 2)
                if z2 > 0 then zebra = "[0xcfcfcf]" else zebra = "[0x3D9797]" end



                if #BuffTableSizeListMe > 0 then
                    for p = 1, #BuffTableSizeListMe do
                        if BuffTableSizeListMe[p].item.nbt_hash == nil then
                            if BuffTableSizeListMe[p].item.id == tostring(BuffTableItemList[i].itemid) and BuffTableSizeListMe[p].item.dmg == tonumber(BuffTableItemList[i].itemdmg) then SizeItemToMe =
                                BuffTableSizeListMe[p].size end
                        else
                            if BuffTableSizeListMe[p].item.id == tostring(BuffTableItemList[i].itemid) and BuffTableSizeListMe[p].item.dmg == tonumber(BuffTableItemList[i].itemdmg) and BuffTableSizeListMe[p].item.nbt_hash == tostring(BuffTableItemList[i].itemhash) then SizeItemToMe =
                                BuffTableSizeListMe[p].size end
                        end
                    end
                end

                if SizeItemToMe >= 1 then availabilityFlag = true else availabilityFlag = false end
                if availabilityFlag then coloravailabilityFlag = "[0x00cc00]" else coloravailabilityFlag = "[0xff0000]" end

                setColorText(2, buffLineDraw, coloravailabilityFlag .. "*[0xffffff]", SettingMain.color.gray)
                setColorText(4, buffLineDraw, zebra .. tostring(BuffTableItemList[i].name) .. "[0xffffff]",
                    SettingMain.color.gray)
                setColorText(75, buffLineDraw,
                    zebra .. tonumber(string.format("%.3f", tonumber(BuffTableItemList[i].price_m))) .. "[0xffffff]",
                    SettingMain.color.gray)
                table.insert(listOnClick, { buffLineDraw, BuffTableItemList[i].searchid })
                buffLineDraw = buffLineDraw + 1
            end

            setColorText(43, SettingMain.ResMain[2] - 1, "[0xf2b233]" .. navigation[1] .. " [0xffffff]",
                SettingMain.color.blackGray)

            set(29, SettingMain.ResMain[2] - 1, " ", SettingMain.color.blackGray)
            set(58, SettingMain.ResMain[2] - 1, " ", SettingMain.color.blackGray)
            if navigation[1] > 1 then setColorText(29, SettingMain.ResMain[2] - 1, "[0x46c8e3]<[0xffffff]",
                    SettingMain.color.blackGray) end
            if navigation[1] ~= navigation[2] then setColorText(58, SettingMain.ResMain[2] - 1, "[0x46c8e3]>[0xffffff]",
                    SettingMain.color.blackGray) end
        end

        DrawItemList()
        fieldSearch = {}
        function fieldSearch:new(x, y, lengthSearchField, cursorSymbol, tableToSearch, elementToSearch)
            local obj = {}
            obj.debugStatus = false
            obj.x = x
            obj.y = y
            obj.lengthSearchField = lengthSearchField
            obj.cursorSymbol = cursorSymbol
            obj.savedSearchText = ""
            obj.xPosC = obj.x + 1

            obj.tableToSearch = tableToSearch
            obj.elementToSearch = elementToSearch
            obj.xPosLastEditSearchText = 0

            local privateVar = {}

            privateVar.xPosC = obj.x + 1
            privateVar.xWithLengthSearchField = obj.x + obj.lengthSearchField

            function obj:drawCrossButton()
                set(self.x + self.lengthSearchField + 2, self.y, " × ", 0x343a40, 0xffc107)
            end

            function obj:drawInit()
                fill(self.x, self.y, 2 + self.lengthSearchField, 1, " ", 0xf8f9fa)
                set(1 + self.x, self.y, "Поиск...", 0xf8f9fa, 0xc2c2c2)
                self:drawCrossButton()
            end

            obj:drawInit()

            function obj:resetSearchfieldAndDrawInit()
                self.savedSearchText = ""
                privateVar.xPosC = self.x + 1
                self.xPosC = self.x + 1
                self:drawInit()
            end

            function obj:blinkCrossButton()
                set((3) + (self.lengthSearchField) + self.x, self.y, "×", 0x343a40, SettingMain.color.background)
                os.sleep(0.0000001)
                set((3) + (self.lengthSearchField) + self.x, self.y, "×", 0x343a40, SettingMain.color.pim)
            end

            function obj:drawCursor()
                set(self.xPosC, self.y, self.cursorSymbol, 0xf8f9fa, 0xffc107)
            end

            function obj:reDrawSearchTextWithCursor(text)
                fill(self.x, self.y, 2 + self.lengthSearchField, 1, " ", 0xf8f9fa)
                set(self.x + 1, self.y, tostring(text), 0xf8f9fa, 0x212529)
                self:drawCursor()
            end

            function obj:reDrawSearchTextWithCursorAndCross(text)
                self:reDrawSearchTextWithCursor(text)
                self:drawCrossButton()
            end

            function obj:lenSavedSearchText()
                return unicode.len(self.savedSearchText)
            end

            function obj:setNewTableToSearch(tableToSearch)
                self.tableToSearch = tableToSearch
            end

            function obj:searchByKeyWordInTable()
                local tblTobufferData = {}
                local savedSearchTextLower = unicode.lower(self.savedSearchText):gsub("ё", "е")
                local tableToSearch = self.tableToSearch

                for i = 1, #tableToSearch do
                    if unicode.lower(tableToSearch[i][self.elementToSearch]):find(savedSearchTextLower) ~= nil then
                        table.insert(tblTobufferData, tableToSearch[i])
                    end
                end
                return #tblTobufferData == 0 and "searchReturnEmpty" or tblTobufferData
            end

            function obj:eventTrap(signal)
                if signal[1] == "touch" and signal[4] == self.y then
                    if signal[3] >= 2 + privateVar.xWithLengthSearchField and signal[3] <= 4 + privateVar.xWithLengthSearchField then
                        obj:blinkCrossButton()
                        self.xPosC = self.x + 1
                        self.savedSearchText = ""
                        self:reDrawSearchTextWithCursor("")

                        return "erase"
                    elseif signal[3] >= 1 + self.x and signal[3] <= self:lenSavedSearchText() + self.x + 1 and self.xPosC ~= 1 + self.x + self.lengthSearchField then
                        self.xPosC = signal[3]
                        self:reDrawSearchTextWithCursor(self.savedSearchText)
                    end
                elseif signal[1] == "key_up" and signal[1] ~= "key_down" then
                    local char, sChar = signal[3], signal[4]
                    local searchTextLen = self:lenSavedSearchText()
                    local symbol = unicode.char(char)

                    if signal[3] == 127 or signal[4] == 211 then
                        self:blinkCrossButton()
                        self.xPosC = self.x + 1
                        self.savedSearchText = ""
                        self:reDrawSearchTextWithCursor("")

                        return "erase"
                    end
                    if symbol:match('^[A-Za-z0-9А-Я-а-я ]') ~= nil and searchTextLen ~= self.lengthSearchField then
                        if self.xPosC == 1 + self.x then
                            local afterCur = unicode.sub(self.savedSearchText, 1 + self.x - self.xPosC, searchTextLen)

                            self.xPosC = self.xPosC + 1
                            self.savedSearchText = symbol .. afterCur
                            self:reDrawSearchTextWithCursor(self.savedSearchText)

                            return true
                        elseif self.xPosC ~= self.x and 1 + self.xPosC >= 1 + self.x + unicode.len(self.savedSearchText) then
                            self.xPosC = self.xPosC + 1
                            self.savedSearchText = self.savedSearchText .. unicode.char(signal[3])
                            self:reDrawSearchTextWithCursor(self.savedSearchText)
                            return true
                        elseif self.xPosC >= 1 + self.x and self.xPosC <= 1 + self.x + searchTextLen then
                            self.savedSearchText = unicode.sub(self.savedSearchText, 1, self.xPosC - 1 - self.x) ..
                            symbol .. unicode.sub(self.savedSearchText, self.xPosC - self.x, searchTextLen)

                            self.xPosC = self.xPosC + 1
                            self:reDrawSearchTextWithCursor(self.savedSearchText)
                            return true
                        end
                    end
                elseif signal[1] ~= "key_up" and signal[1] == "key_down" then
                    if signal[4] == 205 and self.xPosC <= self:lenSavedSearchText() + self.x and self.xPosC ~= 1 + self.x + self.lengthSearchField then
                        self.xPosC = self.xPosC + 1
                        self:reDrawSearchTextWithCursor(self.savedSearchText)
                    elseif signal[4] == 203 and self.xPosC >= 2 + self.x then
                        self.xPosC = self.xPosC - 1
                        self:reDrawSearchTextWithCursor(self.savedSearchText)
                    end
                    if signal[3] and signal[4] == 14 then
                        if self.xPosC >= 1 + self.x then
                            local searchTextLen = self:lenSavedSearchText()
                            if self.xPosC == 1 + self.x + searchTextLen and searchTextLen > 0 then
                                if self.xPosC ~= 1 + self.x then self.xPosC = self.xPosC - 1 end
                                self.savedSearchText = unicode.sub(self.savedSearchText, 1, searchTextLen - 1)
                                self:reDrawSearchTextWithCursor(self.savedSearchText)
                                if self.savedSearchText == "" then return "savedSearchText_erase" end
                                return true
                            elseif self.xPosC >= 3 + self.x and self.xPosC <= self.x + searchTextLen then
                                self.savedSearchText = unicode.sub(self.savedSearchText, 1, self.xPosC - 2 - self.x) ..
                                unicode.sub(self.savedSearchText, self.xPosC - self.x, searchTextLen)
                                self.xPosC = self.xPosC - 1

                                self:reDrawSearchTextWithCursor(self.savedSearchText)
                                if self.savedSearchText == "" then return "savedSearchText_erase" end
                                return true
                            elseif self.xPosC == 2 + self.x then
                                self.savedSearchText = unicode.sub(self.savedSearchText, 2, searchTextLen)
                                self.xPosC = self.xPosC - 1

                                self:reDrawSearchTextWithCursor(self.savedSearchText)
                                return true
                            end
                            return false
                        end
                    end
                end
            end

            function obj:onEvent(signal)
                local result = self:eventTrap(signal)
                if self.savedSearchText ~= "" then
                    if result == true or type(result) == "table" then return self:searchByKeyWordInTable() end
                end
                if result then
                    return result
                end
            end

            function obj:debug(signal)
                if self.debugStatus then
                    local x = 41
                    fill(abs(x - 1), 1, 50, 8, " ", 0xf8f9fa)
                    set(x, 2, tostring(signal[3]), SettingMain.color.white, SettingMain.color.pim)
                    set(x, 3, tostring(signal[4]), SettingMain.color.white, SettingMain.color.pim)
                    set(x, 4, "xPosC: " .. tostring(self.xPosC), SettingMain.color.background, SettingMain.color.pim)
                    set(x, 5, "searchTextLen: " .. tostring(unicode.len(self.savedSearchText)),
                        SettingMain.color.background, SettingMain.color.red)
                    set(x, 6, "savedSearchText: " .. self.savedSearchText, SettingMain.color.background,
                        SettingMain.color.red)
                end
            end

            setmetatable(obj, self)
            self.__index = self
            return obj
        end

        Searcher = fieldSearch:new(49, 2, 30, '<', BuffTableItemList, 'name')
    end


    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
        if #ProductList > 0 and s then
            local result = Searcher:onEvent(s)
            if result == "erase" then
                if #ProductList ~= #BuffTableItemList then
                    BuffFuncResult = {}
                    CurrentPage = 1
                    BuffTableItemList = ProductList
                    DrawItemList()
                end
                Searcher:resetSearchfieldAndDrawInit()
            elseif result == "savedSearchText_erase" then
                BuffFuncResult = {}
                CurrentPage = 1
                BuffTableItemList = ProductList
                DrawItemList()
                Searcher:resetSearchfieldAndDrawInit()
            elseif result == "searchReturnEmpty" then
                BuffTableItemList, BuffFuncResult, listOnClick = {}, {}, {}
                fill(1, StartDrawLine, SettingMain.ResMain[1], MaxItemToPage, " ", SettingMain.color.gray)
                setColorText(nil, 14, "[0xf2b233]Товары не найдены![0xffffff]", SettingMain.color.gray)
                set(nil, 16, "Попробуй поискать что нибудь другое или смени раскадку!",
                    SettingMain.color.gray)
            elseif type(result) == "table" then
                BuffTableItemList = result
                BuffFuncResult = {}

                DrawItemList()
            end

            if s and s[1] == "touch" then
                if #listOnClick > 0 then
                    for t = 1, #listOnClick do
                        if (s[3] >= 1 and s[3] <= SettingMain.ResMain[1]) and (s[4] == listOnClick[t][1]) then
                            mainScreenProductInfo(listOnClick[t][2], CurrentPage, 0) end
                    end
                end
            end
        end

        if s and (s[1] == "touch" or s[1] == "scroll") and #BuffTableItemList > 0 then
            if CurrentPage > 1 then if ((s[3] >= 28 and s[3] <= 30) and s[4] == SettingMain.ResMain[2] - 1) or s[5] == 1 then
                    os.sleep(0.000000000001)
                    CurrentPage = CurrentPage - 1
                    DrawItemList()
                end end
            if navigationTable(CurrentPage, MaxItemToPage, #BuffTableItemList)[2] > CurrentPage then if ((s[3] >= 57 and s[3] <= 59) and s[4] == SettingMain.ResMain[2] - 1) or s[5] == -1 then
                    os.sleep(0.000000000001)
                    CurrentPage = CurrentPage + 1
                    DrawItemList()
                end end
        end
        if s and s[1] == "touch" then if (s[3] >= 2 and s[3] <= 12) and (s[4] == SettingMain.ResMain[2] - 1) then
                NewMainSceenPI() end end
    end
end


_G.mainScreenProductInfo = function(id, lastPage, FlagToLogs)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
    if FlagToLogs == nil then FlagToLogs = 0 end
    local err5, MEitems = pcall(function() return me_interface.getItemsInNetwork({ name = ProductList[id].itemid,
            damage = ProductList[id].itemdmg })[1].size end)
    countInMe = 0
    if err5 and MEitems ~= nil then countInMe = MEitems end
    if countInMe >= 1 then
        if FlagToLogs == 0 or FlagToLogs == nil then logShop("viewitem,success," ..
            md5.sumhexa(ProductList[id].itemid .. ProductList[id].itemdmg .. ProductList[id].itemhash) .. ",0,0") end
        if tonumber(NowSettingShop.UserInfo.balance) >= tonumber(ProductList[id].price_m) then
            selectorSet(false, ProductList[id].itemid, ProductList[id].itemdmg, ProductList[id].itemhash)
            fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
            setColorText(nil, 2, "[0xf2b233]Вы выбрали: [0x46c8e3]" .. ProductList[id].name .. "[0xffffff]",
                SettingMain.color.blackGray)
            STnewNum = ''
            newBalance = 0

            function PushNum(num, flag)
                local tbal = ProductList[id].price_m
                local ct = tonumber(countInMe)
                if num == 0 and (STnewNum == nil or STnewNum == '') then
                    fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                    setColorText(3, SettingMain.ResMain[2] - 3,
                        "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                        SettingMain.color.gray)
                    STnewNum = ''
                    newBalance = 0
                else
                    STnewNum = STnewNum .. num
                    if flag then STnewNum = num end
                    local baseMonitor = tonumber(STnewNum)
                    if baseMonitor > ct then
                        fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                        setColorText(3, SettingMain.ResMain[2] - 3,
                            "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                            SettingMain.color.gray)
                        STnewNum, newBalance = '', 0

                        Button(3, SettingMain.ResMain[2] - 12, 57, 4, SettingMain.color.blackGray, SettingMain.color.red,
                            'Обратите внимание!', 'В магазине нет такого кол-ва товаров!',
                            SettingMain.color.orange)

                        Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                            "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> ?",
                            SettingMain.color.pim)
                        fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                        fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                        fill(64, 9, 18, 1, " ", SettingMain.color.white)
                        setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
                    else
                        newBalance = tonumber(string.format("%.3f", tonumber(baseMonitor * tbal)))

                        if newBalance > tonumber(NowSettingShop.UserInfo.balance) then
                            fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                            setColorText(3, SettingMain.ResMain[2] - 3,
                                "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                                SettingMain.color.gray)
                            STnewNum, newBalance = '', 0

                            setColorText(3, SettingMain.ResMain[2] - 10,
                                "[0xf2b233]У вас не достаточно средств![0xffffff]",
                                SettingMain.color.gray)
                            setColorText(3, SettingMain.ResMain[2] - 9, "[0xf2b233]Укажите меньшее кол-во![0xffffff]",
                                SettingMain.color.gray)
                            Button(3, SettingMain.ResMain[2] - 12, 57, 4, SettingMain.color.blackGray,
                                SettingMain.color.red, 'Обратите внимание!',
                                'У вас не достаточно средств на данное кол-во товаров!',
                                SettingMain.color.orange)


                            Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange,
                                'Изменения в балансе',
                                "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) ..
                                " -> ?", SettingMain.color.pim)
                            fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                            fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                            fill(64, 9, 18, 1, " ", SettingMain.color.white)
                            setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
                        else
                            fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                            setColorText(3, SettingMain.ResMain[2] - 3,
                                "[0xf2b233]ИТОГО: [0x46c8e3]" ..
                                baseMonitor .. " шт.[0xf2b233], на сумму [0x46c8e3]" ..
                                newBalance .. " эм.[0xffffff]", SettingMain.color.gray)
                            fill(3, SettingMain.ResMain[2] - 12, 57, 4, " ", SettingMain.color.gray)
                            local mils = tonumber(string.format("%.3f",
                                tonumber(NowSettingShop.UserInfo.balance - newBalance)))
                            Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange,
                                'Изменения в балансе',
                                "" ..
                                tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) ..
                                " -> " .. mils .. "", SettingMain.color.pim)
                            fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                            fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                            fill(64, 9, 18, 1, " ", SettingMain.color.white)
                            setColorText(66, 9, "[0x303030]" .. tostring(baseMonitor) .. "<[0xffffff]",
                                SettingMain.color.white)
                        end
                    end
                end
            end

            function resetNum()
                if STnewNum ~= '' then
                    STnewNum = ''
                    newBalance = 0


                    fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                    setColorText(3, SettingMain.ResMain[2] - 3,
                        "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                        SettingMain.color.gray)
                    Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                        "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> ?",
                        SettingMain.color.pim)
                    fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 9, 18, 1, " ", SettingMain.color.white)
                    setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
                end
            end

            function backspace()
                local getString = STnewNum
                local countLen = getString:len()
                if countLen > 1 then
                    local deletNum = string.sub(getString, 1, countLen - 1)
                    STnewNum = deletNum
                    PushNum(STnewNum, true)
                else
                    resetNum()
                end
                return
            end

            Button(5, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Ваш баланс',
                "" .. tostring(NowSettingShop.UserInfo.balance) .. "", SettingMain.color.pim)
            Button(23, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'В наличии',
                "" .. tostring(countInMe) .. "", SettingMain.color.pim)
            Button(41, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Цена за 1 шт',
                "" .. tonumber(string.format("%.3f", tonumber(ProductList[id].price_m))) .. "", SettingMain.color.pim)
            fill(SettingMain.ResMain[1] - 24, 4, 26, SettingMain.ResMain[1] - 3, " ", SettingMain.color.lightGray)
            Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                "" .. tostring(NowSettingShop.UserInfo.balance) .. " -> ?", SettingMain.color.pim)
            fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
            fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)

            fill(64, 9, 18, 1, " ", SettingMain.color.white)
            setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
            setColorText(82, 9, "[0xf2b233] × [0xffffff]", SettingMain.color.blackGray)

            Button(64, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '1')
            Button(72, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '2')
            Button(80, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '3')
            Button(64, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '4')
            Button(72, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '5')
            Button(80, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '6')
            Button(64, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '7')
            Button(72, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '8')
            Button(80, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '9')
            Button(64, 23, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '0')
            Button(71, 23, 14, 3, SettingMain.color.blackGray, SettingMain.color.pim, 'Купить')

            local function scanPlayerForNilSt()
                local setCount = 0
                local err, invPl = pcall(function() return pim.getStackInSlot end)
                for i = 1, 36 do if invPl(i) == nil then setCount = setCount + 1 end end
                return setCount
            end

            local ToGetStart = 0
            local ToGetStart2 = 0
            local ForBalance = math.modf(tonumber(NowSettingShop.UserInfo.balance) / tonumber(ProductList[id].price_m))
            local ForInv = scanPlayerForNilSt() * ProductList[id].itemsize
            if ForBalance > ForInv then ToGetStart = ForInv else ToGetStart = ForBalance end
            if ToGetStart > countInMe then ToGetStart = countInMe end
            if (ForBalance > countInMe) then ToGetStart2 = countInMe else ToGetStart2 = ForBalance end
            local newText = ""
            if ToGetStart == ToGetStart2 then newText = "[0x46c8e3]" .. ToGetStart .. " шт. [0xffffff]" else newText =
                "[0x46c8e3]" ..
                ToGetStart .. " шт. [0xf2b233](по балансу: [0x46c8e3]" ..
                ToGetStart2 .. " шт.[0xf2b233])[0xffffff]" end
            setColorText(3, SettingMain.ResMain[2] - 5, "[0xf2b233]Можно купить: " .. newText .. "",
                SettingMain.color.gray)
            setColorText(3, SettingMain.ResMain[2] - 4,
                "[0x46c8e3]- - - - - - - - - - - - - - - - - - - - - - - - - - -[0xffffff]", SettingMain.color.gray)
            setColorText(3, SettingMain.ResMain[2] - 3,
                "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                SettingMain.color.gray)
            setColorText(3, SettingMain.ResMain[2] - 1, "[0xf2b233] Назад к списку [0xffffff]",
                SettingMain.color.lightGray)
        else
            setColorText(nil, SettingMain.ResMain[2] - 1,
                "[0xf2b233]Возникли вопросы или трудности? Пишите в Discord: [0x46c8e3]" ..
                SettingMain.AdminDiscord .. "[0xffffff]", SettingMain.color.gray)
            setColorText(nil, 10, "[0xf2b233]Вы выбрали: [0x46c8e3]" .. ProductList[id].name .. "[0xffffff]",
                SettingMain.color.gray)
            setColorText(nil, 12, "[0xf2b233]У вас недостаточно средств, чтобы купить хотябы 1 товар[0xffffff]",
                SettingMain.color.gray)
            set(nil, 14, "Для начала пополните баланс, через вкладку <Управление балансом>",
                SettingMain.color.gray)
            Button(20, 18, 23, 3, SettingMain.color.lightGray, SettingMain.color.orange, 'Управление балансом')
            Button(45, 18, 24, 3, SettingMain.color.lightGray, SettingMain.color.orange, 'Вернуться к списку')
            os.sleep(0.5)
        end
    else
        setColorText(nil, SettingMain.ResMain[2] - 1,
            "[0xf2b233]Возникли вопросы или трудности? Пишите в Discord: [0x46c8e3]" ..
            SettingMain.AdminDiscord .. "[0xffffff]", SettingMain.color.gray)
        setColorText(nil, 10, "[0xf2b233]Вы выбрали: [0x46c8e3]" .. ProductList[id].name .. "[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 12, "[0xf2b233]Товара сейчас нет в наличии. Зайдите позже![0xffffff]",
            SettingMain.color.gray)
        if ProductList[id].craft == 1 then
            set(nil, 14, "У нас работает автопополнение, попробуйте зайти через 5-15 минут.",
                SettingMain.color.gray)
        else
            set(nil, 14, "На данный товар нет поддержки автокрафта, обратитесь к владельцу магазина",
                SettingMain.color.gray)
        end
        Button(20, 18, 23, 3, SettingMain.color.lightGray, SettingMain.color.orange, 'Управление балансом')
        Button(45, 18, 24, 3, SettingMain.color.lightGray, SettingMain.color.orange, 'Вернуться к списку')
        logShop("viewitem,errornotavalible," ..
        md5.sumhexa(ProductList[id].itemid .. ProductList[id].itemdmg .. ProductList[id].itemhash) .. ",0,0")
        os.sleep(0.5)
    end
    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
        if tonumber(NowSettingShop.UserInfo.balance) >= tonumber(ProductList[id].price_m) and countInMe >= 1 then
            if s and (s[1] == "touch" or s[1] == "key_down") then
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 23 and s[4] <= 25)) or (s[1] == "key_down" and (s[3] == 48 and s[4] == 82) or (s[3] == 48 and s[4] == 11)) then
                    PushNum(0, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 49 and s[4] == 79) or (s[3] == 49 and s[4] == 2)) then
                    PushNum(1, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 50 and s[4] == 80) or (s[3] == 50 and s[4] == 3)) then
                    PushNum(2, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 51 and s[4] == 81) or (s[3] == 51 and s[4] == 4)) then
                    PushNum(3, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 52 and s[4] == 75) or (s[3] == 52 and s[4] == 5)) then
                    PushNum(4, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 53 and s[4] == 76) or (s[3] == 53 and s[4] == 6)) then
                    PushNum(5, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 54 and s[4] == 77) or (s[3] == 54 and s[4] == 7)) then
                    PushNum(6, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 55 and s[4] == 71) or (s[3] == 55 and s[4] == 8)) then
                    PushNum(7, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 56 and s[4] == 72) or (s[3] == 56 and s[4] == 9)) then
                    PushNum(8, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 57 and s[4] == 73) or (s[3] == 57 and s[4] == 10)) then
                    PushNum(9, false) end
                if (s[1] == "touch" and (s[3] >= 82 and s[3] <= 84) and (s[4] == 9)) then resetNum() end
                if (s[1] == "key_down" and (s[3] == 8 and s[4] == 14)) then backspace() end
                if tonumber(newBalance) > 0 and (STnewNum ~= nil or STnewNum ~= '') then
                    if (s[1] == "touch" and (s[3] >= 71 and s[3] <= 84) and (s[4] >= 23 and s[4] <= 25)) or (s[1] == "key_down" and (s[3] == 13 and s[4] == 28)) then
                        selectorSet(true)
                        goToBuyItemNew(id, STnewNum, lastPage)
                    end
                end
            end
            if s and s[1] == "touch" then
                if (s[3] >= 3 and s[3] <= 18) and (s[4] == SettingMain.ResMain[2] - 1) then
                    selectorSet(true)
                    mainScreenProduct(lastPage)
                end
            end
        else
            if s and s[1] == "touch" then
                if (s[3] >= 20 and s[3] <= 43) and (s[4] >= 18 and s[4] <= 21) then
                    selectorSet(true)
                    balance()
                end
                if (s[3] >= 45 and s[3] <= 69) and (s[4] >= 18 and s[4] <= 21) then
                    selectorSet(true)
                    mainScreenProduct(lastPage)
                end
            end
        end
    end
end


_G.goToBuyItemNew = function(id, num, lastpage)
    local function scanPlayerForNilSt()
        local setCount = 0
        local err, invPl = pcall(function() return pim.getStackInSlot end)
        for i = 1, 36 do if invPl(i) == nil then setCount = setCount + 1 end end
        return setCount
    end

    local statusBuy = ''
    local CountToBuy = tonumber(num)
    local userToHold = PlayerPIM
    local selectedItem = ProductList[id]
    local FullMoney = tonumber(string.format("%.3f", tonumber(CountToBuy * selectedItem.price_m)))
    local CountFreeInvPlayer = scanPlayerForNilSt()
    local usItemHash = md5.sumhexa(selectedItem.itemid .. selectedItem.itemdmg .. selectedItem.itemhash)
    if selectedItem.itemhash == nil or selectedItem.itemhash == '' then nbtHashItem = 0 else nbtHashItem = tostring(
        selectedItem.itemhash) end
    local err5, CountSelectedItemToME = pcall(function() return me_interface.getItemsInNetwork({
            name = selectedItem.itemid, damage = selectedItem.itemdmg })[1].size end)
    if err5 == false or CountSelectedItemToME == nil then CountSelectedItemToME = 0 end
    local NeedFreeInv, itemN = math.modf(CountToBuy / tonumber(selectedItem.itemsize))
    if itemN > 0 then NeedFreeInv = NeedFreeInv + 1 end


    if CountSelectedItemToME >= CountToBuy and tonumber(NowSettingShop.UserInfo.balance) >= FullMoney and (CountToBuy ~= 0 or CountToBuy ~= nil or CountToBuy ~= '') then
        clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
        fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
        setColorText(nil, 12, "[0x00cc00]Происходит процесс покупки[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 13, "[0xffffff]Товар: [0x46c8e3]" .. selectedItem.name .. "[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 15, "[0xf2b233]Не покидайте PIM до завершения процесса[0xffffff]",
            SettingMain.color.gray)


        if CountFreeInvPlayer < NeedFreeInv then
            CountToBuy = CountFreeInvPlayer * tonumber(selectedItem.itemsize)
            FullMoney = tonumber(string.format("%.3f", tonumber(CountToBuy * selectedItem.price_m)))
        end


        local gift = giveItem(tostring(selectedItem.itemid), tonumber(selectedItem.itemdmg), CountToBuy, nbtHashItem)
        if gift == CountToBuy and CountFreeInvPlayer >= NeedFreeInv then
            fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
            fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
            setColorText(nil, 12, "[0x00cc00]Процесс покупки завершен[0xffffff]",
                SettingMain.color.gray)
            setColorText(nil, 15, "[0xf2b233]Товар успешно выдан![0xffffff]", SettingMain.color.gray)
            statusBuy = 'success'
        else
            CountToBuy = gift
            FullMoney = tonumber(string.format("%.3f", tonumber(CountToBuy * selectedItem.price_m)))
            if CountToBuy == 0 then
                fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                setColorText(nil, 12, "[0xff0000]Процесс покупки завершен[0xffffff]",
                    SettingMain.color.gray)
                setColorText(nil, 15, "[0xf2b233]Товар не выдан, ваш баланс не был изменен![0xffffff]",
                    SettingMain.color.gray)
                statusBuy = 'errorgive'
            else
                fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                setColorText(nil, 12, "[0x00cc00]Процесс покупки завершен[0xffffff]",
                    SettingMain.color.gray)
                setColorText(nil, 15,
                    "[0xf2b233]Товар выдан частично! Выдали: " ..
                    CountToBuy .. " шт., на сумму: " .. FullMoney .. " [0xffffff]", SettingMain.color.gray)
                statusBuy = 'minisucces'
            end
        end


        if CountToBuy > 0 then
            local SendMoneyErr, SendMoney = pcall(function() return sendGET(SettingMain.http ..
                "balance.php?TokenAuth=" ..
                NowSettingShop.TokenAuth .. "&player=" .. userToHold .. "&type=4&balance=" .. FullMoney .. "") end)
            if SendMoneyErr == false or SendMoney ~= "success" then
                logDiscord("(goToBuyItemNew) balance.php: Не смог списать баланс игрока (" ..
                userToHold .. ") Покупал: " .. selectedItem.name ..
                " (" .. CountToBuy .. " шт.) (" .. FullMoney .. " эм)  ")
                logShop("buy,emerrorserver," .. usItemHash .. "," .. FullMoney .. "," .. CountToBuy .. "")
            end
            NowSettingShop.UserInfo.balance = tonumber(string.format("%.3f",
                tonumber(NowSettingShop.UserInfo.balance - FullMoney)))
            SendMoney = nil
            UpdateItemsList()
        end
        nbtHashItem = nil
        logShop("buy," .. statusBuy .. "," .. usItemHash .. "," .. FullMoney .. "," .. CountToBuy .. "")
        os.sleep(0.5)
        local pimErrStatus, name = pcall(pim.getInventoryName)
        if name ~= PlayerPIM then
            UserLogout()
            mainScreenShop()
        end
        mainScreenProductInfo(id, lastpage, 1)
    else
        local pimErrStatus, name = pcall(pim.getInventoryName)
        if name ~= PlayerPIM then
            UserLogout()
            mainScreenShop()
        end
        mainScreenProductInfo(id, lastpage, 1)
    end
end


_G.balance = function(GoToPage)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    headerScreen()
    fill(1, 4, SettingMain.ResMain[1], 24, " ", SettingMain.color.gray)
    fill(1, 4, SettingMain.ResMain[1], 1, " ", SettingMain.color.lightGray)
    setColorText(2, 4, "[0xf2b233]Магазин покупает[0xffffff]", SettingMain.color.lightGray)
    setColorText(60, 4, "[0xf2b233]В инвентаре[0xffffff]", SettingMain.color.lightGray)
    setColorText(74, 4, "[0xf2b233]Цена за 1 шт[0xffffff]", SettingMain.color.lightGray)
    setColorText(66, 2, "[0xf2b233] Обновить страницу [0xffffff]", SettingMain.color.gray)

    local function scanInvPlayer(itemToTake_Name, itemToTake_damage)
        local count = 0
        local err, allStacks = pcall(pim.getAllStacks)
        for i = 1, 36 do
            if allStacks[i] ~= nil and allStacks[i].all() ~= nil then
                if allStacks[i].all().id ~= nil and allStacks[i].all().dmg ~= nil then
                    if allStacks[i].all().id == itemToTake_Name and allStacks[i].all().dmg == itemToTake_damage then
                        count = count + allStacks[i].all().qty
                    end
                end
            end
        end
        return err == true and tonumber(count) or 0
    end


    CurrentPage, MaxItemToPage, StartDrawLine = 1, 18, 6
    if GoToPage ~= nil then CurrentPage = GoToPage end
    local ListItemTable = _G.BuffTableItemBalance

    function navigationTable(CurrentPage, MaxItemToPage, CountAllItemInList)
        local maxPage = math.ceil(CountAllItemInList / MaxItemToPage)
        if CurrentPage == nil or CurrentPage < 1 then CurrentPage = 1 end
        if CurrentPage >= maxPage then CurrentPage = maxPage end
        return { CurrentPage, maxPage, CountAllItemInList }
    end

    function getParamForItem(navigationTableResult)
        local result = {}
        if navigationTableResult[2] == 1 then
            result = { 1, navigationTableResult[3] }
        else
            local StartNav = 0
            for v = 1, navigationTableResult[2] do
                if v == 1 then
                    table.insert(BuffFuncResult, { 1, MaxItemToPage })
                elseif v > 1 and v < navigationTableResult[2] then
                    table.insert(BuffFuncResult, { (StartNav + 1), ((StartNav) + MaxItemToPage) })
                elseif v == navigationTableResult[2] then
                    table.insert(BuffFuncResult, { (StartNav + 1), navigationTableResult[3] })
                end
                StartNav = StartNav + MaxItemToPage
            end

            result = { BuffFuncResult[navigationTableResult[1]][1], BuffFuncResult[navigationTableResult[1]][2] }
        end
        return result
    end

    function DrawItemListBalance()
        fill(1, StartDrawLine, SettingMain.ResMain[1], MaxItemToPage, " ", SettingMain.color.gray)
        local buffLineDraw = StartDrawLine
        local navigation = navigationTable(CurrentPage, MaxItemToPage, #ListItemTable)
        local ParamForItem = getParamForItem(navigation)

        local zebra = ''
        for i = ParamForItem[1], ParamForItem[2] do
            local z1, z2 = math.modf(i / 2)
            if z2 > 0 then zebra = "[0xcfcfcf]" else zebra = "[0x3D9797]" end
            local countItemInInv = scanInvPlayer(ListItemTable[i].id, ListItemTable[i].dmg)

            setColorText(2, buffLineDraw, zebra .. ListItemTable[i].name .. "[0xffffff]", SettingMain.color.gray)
            setColorText(65, buffLineDraw, zebra .. countItemInInv .. "     [0xffffff]", SettingMain.color.gray)
            setColorText(78, buffLineDraw,
                zebra .. tonumber(string.format("%.3f", tonumber(ListItemTable[i].balance))) .. "[0xffffff]",
                SettingMain.color.gray)
            buffLineDraw = buffLineDraw + 1
        end

        setColorText(43, SettingMain.ResMain[2] - 1, "[0xf2b233]" .. navigation[1] .. " [0xffffff]",
            SettingMain.color.blackGray)
        set(29, SettingMain.ResMain[2] - 1, " ", SettingMain.color.blackGray)
        set(58, SettingMain.ResMain[2] - 1, " ", SettingMain.color.blackGray)
        if navigation[1] > 1 then setColorText(29, SettingMain.ResMain[2] - 1, "[0x46c8e3]<[0xffffff]",
                SettingMain.color.blackGray) end
        if navigation[1] ~= navigation[2] then setColorText(58, SettingMain.ResMain[2] - 1, "[0x46c8e3]>[0xffffff]",
                SettingMain.color.blackGray) end
    end

    fill(1, SettingMain.ResMain[2] - 2, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
    setColorText(3, SettingMain.ResMain[2] - 1, "[0xf2b233] < В меню [0xffffff]", SettingMain.color.lightGray)
    setColorText(72, SettingMain.ResMain[2] - 1, "[0xf2b233] К товарам > [0xffffff]", SettingMain.color
    .lightGray)

    if #ListItemTable == 0 then
        setColorText(nil, 14, "[0xf2b233]Нет доступных товаров для продажи магазину![0xffffff]",
            SettingMain.color.gray)
    else
        DrawItemListBalance()
    end





    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
        if s and s[1] == "touch" then
            if (s[3] >= 66 and s[3] <= 84) and (s[4] == 2) then
                setColorText(66, 2, "[0x46c8e3] Обновляю страницу [0xffffff]", SettingMain.color.gray)
                os.sleep(0.5)
                DrawItemListBalance()
                setColorText(66, 2, "[0xf2b233] Обновить страницу [0xffffff]", SettingMain.color.gray)
            end
            if (s[3] >= 3 and s[3] <= 13) and (s[4] == SettingMain.ResMain[2] - 1) then NewMainSceenPI() end
            if (s[3] >= 72 and s[3] <= 85) and (s[4] == SettingMain.ResMain[2] - 1) then mainScreenProduct() end
            if #ListItemTable >= 1 then
                local startNUMs = 6
                for tw = 1, #ListItemTable do
                    if (s[3] >= 1 and s[3] <= SettingMain.ResMain[1]) and (s[4] == startNUMs) then balanceInfo(tw) end
                    startNUMs = startNUMs + 1
                end
            end
        end
    end
end


_G.balanceInfo = function(id)
    clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
    fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
    local itemSelect = _G.BuffTableItemBalance[id]
    local function scanInvPlayer(itemToTake_Name, itemToTake_damage)
        local count = 0
        local err, allStacks = pcall(pim.getAllStacks)
        for i = 1, 36 do
            if allStacks[i] ~= nil and allStacks[i].all() ~= nil then
                if allStacks[i].all().id ~= nil and allStacks[i].all().dmg ~= nil then
                    if allStacks[i].all().id == itemToTake_Name and allStacks[i].all().dmg == itemToTake_damage then
                        count = count + allStacks[i].all().qty
                    end
                end
            end
        end
        return err == true and tonumber(count) or 0
    end

    countInMe = scanInvPlayer(itemSelect.id, itemSelect.dmg)

    if countInMe >= 1 then
        fill(1, 1, SettingMain.ResMain[1], 3, " ", SettingMain.color.blackGray)
        setColorText(nil, 2, "[0xf2b233]Вы выбрали: [0x46c8e3]" .. itemSelect.name .. "[0xffffff]",
            SettingMain.color.blackGray)
        STnewNum = ''
        newBalance = 0

        function PushNum(num, flag)
            local tbal = itemSelect.balance
            local ct = countInMe
            if num == 0 and (STnewNum == nil or STnewNum == '') then
                fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                setColorText(3, SettingMain.ResMain[2] - 3,
                    "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                    SettingMain.color.gray)
                STnewNum = ''
                newBalance = 0
            else
                STnewNum = STnewNum .. num
                if flag then STnewNum = num end
                local baseMonitor = tonumber(STnewNum)
                if baseMonitor > ct then
                    fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                    setColorText(3, SettingMain.ResMain[2] - 3,
                        "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                        SettingMain.color.gray)
                    STnewNum, newBalance = '', 0


                    Button(3, SettingMain.ResMain[2] - 12, 57, 4, SettingMain.color.blackGray, SettingMain.color.red,
                        'Обратите внимание!', 'У вас нет в наличии такого кол-ва ресурсов!',
                        SettingMain.color.orange)



                    Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                        "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> ?",
                        SettingMain.color.pim)
                    fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 9, 18, 1, " ", SettingMain.color.white)
                    setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
                else
                    newBalance = tonumber(string.format("%.3f", tonumber(baseMonitor * tbal)))
                    fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                    setColorText(3, SettingMain.ResMain[2] - 3,
                        "[0xf2b233]ИТОГО: [0x46c8e3]" ..
                        baseMonitor .. " шт.[0xf2b233], на сумму [0x46c8e3]" .. newBalance .. " эм.[0xffffff]",
                        SettingMain.color.gray)
                    fill(3, SettingMain.ResMain[2] - 12, 57, 4, " ", SettingMain.color.gray)
                    local mils = tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance + newBalance)))
                    Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                        "" ..
                        tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> " .. mils ..
                        "", SettingMain.color.pim)
                    fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                    fill(64, 9, 18, 1, " ", SettingMain.color.white)
                    setColorText(66, 9, "[0x303030]" .. tostring(baseMonitor) .. "<[0xffffff]", SettingMain.color.white)
                end
            end
        end

        function resetNum()
            if STnewNum ~= '' then
                STnewNum = ''
                newBalance = 0
                fill(3, SettingMain.ResMain[2] - 3, 59, 1, " ", SettingMain.color.gray)
                setColorText(3, SettingMain.ResMain[2] - 3,
                    "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
                    SettingMain.color.gray)
                Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
                    "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> ?",
                    SettingMain.color.pim)
                fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
                fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)
                fill(64, 9, 18, 1, " ", SettingMain.color.white)
                setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
            end
        end

        function backspace()
            local getString = STnewNum
            local countLen = getString:len()
            if countLen > 1 then
                local deletNum = string.sub(getString, 1, countLen - 1)
                STnewNum = deletNum
                PushNum(STnewNum, true)
            else
                resetNum()
            end
            return
        end

        Button(5, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Ваш баланс',
            "" .. tostring(NowSettingShop.UserInfo.balance) .. "", SettingMain.color.pim)
        Button(23, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'В наличии',
            "" .. tostring(countInMe) .. "", SettingMain.color.pim)
        Button(41, 5, 16, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Цена за 1 шт',
            "" .. tonumber(string.format("%.3f", tonumber(itemSelect.balance))) .. "", SettingMain.color.pim)
        fill(SettingMain.ResMain[1] - 24, 4, 26, SettingMain.ResMain[1] - 3, " ", SettingMain.color.lightGray)
        Button(64, 4, 21, 4, SettingMain.color.blackGray, SettingMain.color.orange, 'Изменения в балансе',
            "" .. tonumber(string.format("%.3f", tonumber(NowSettingShop.UserInfo.balance))) .. " -> ?",
            SettingMain.color.pim)
        fill(64, 4, 21, 1, " ", SettingMain.color.lightGray)
        fill(64, 7, 21, 1, " ", SettingMain.color.lightGray)

        fill(64, 9, 18, 1, " ", SettingMain.color.white)
        setColorText(66, 9, "[0x303030]Укажи кол-во[0xffffff]", SettingMain.color.white)
        setColorText(82, 9, "[0xf2b233] × [0xffffff]", SettingMain.color.blackGray)

        Button(64, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '1')
        Button(72, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '2')
        Button(80, 19, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '3')
        Button(64, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '4')
        Button(72, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '5')
        Button(80, 15, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '6')
        Button(64, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '7')
        Button(72, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '8')
        Button(80, 11, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '9')
        Button(64, 23, 5, 3, SettingMain.color.blackGray, SettingMain.color.orange, '0')
        Button(72, 23, 13, 3, SettingMain.color.blackGray, SettingMain.color.pim, 'Продать')


        setColorText(3, SettingMain.ResMain[2] - 5, "[0xf2b233]Можно продать: [0x46c8e3]" ..
        countInMe .. " шт.[0xffffff]", SettingMain.color.gray)
        setColorText(3, SettingMain.ResMain[2] - 4,
            "[0x46c8e3]- - - - - - - - - - - - - - - - - - - - - - - - - - -[0xffffff]", SettingMain.color.gray)
        setColorText(3, SettingMain.ResMain[2] - 3,
            "[0xf2b233]ИТОГО: [0x46c8e3]0 шт.[0xf2b233], на сумму [0x46c8e3]0 эм.[0xffffff]",
            SettingMain.color.gray)
        setColorText(3, SettingMain.ResMain[2] - 1, "[0xf2b233] Назад к списку [0xffffff]",
            SettingMain.color.lightGray)
        setColorText(46, SettingMain.ResMain[2] - 1, "[0xf2b233] Продать все [0xffffff]",
            SettingMain.color.lightGray)
    else
        setColorText(nil, 10, "[0xf2b233]Вы выбрали: [0x46c8e3]" .. itemSelect.name .. "[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 12, "[0xf2b233]Данный предмет отсутствует у вас в инвентаре[0xffffff]",
            SettingMain.color.gray)
        set(nil, 14, "Чтобы продать этот предмет магазину", SettingMain.color.gray)
        set(nil, 15, "положите его к себе в инвентарь", SettingMain.color.gray)
        Button(33, 18, 20, 3, SettingMain.color.lightGray, SettingMain.color.orange, 'Вернуться к списку')
        setColorText(nil, SettingMain.ResMain[2] - 1,
            "[0xf2b233]Возникли вопросы или трудности? Пишите в Discord: [0x46c8e3]" ..
            SettingMain.AdminDiscord .. "[0xffffff]", SettingMain.color.gray)
    end
    while true do
        local err, name = pcall(pim.getInventoryName)
        local s = { computer.pullSignal(0) }
        if name == "pim" then
            UserLogout()
            mainScreenShop()
        end
        if countInMe >= 1 then
            if s and (s[1] == "touch" or s[1] == "key_down") then
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 23 and s[4] <= 25)) or (s[1] == "key_down" and (s[3] == 48 and s[4] == 82) or (s[3] == 48 and s[4] == 11)) then
                    PushNum(0, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 49 and s[4] == 79) or (s[3] == 49 and s[4] == 2)) then
                    PushNum(1, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 50 and s[4] == 80) or (s[3] == 50 and s[4] == 3)) then
                    PushNum(2, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 19 and s[4] <= 21)) or (s[1] == "key_down" and (s[3] == 51 and s[4] == 81) or (s[3] == 51 and s[4] == 4)) then
                    PushNum(3, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 52 and s[4] == 75) or (s[3] == 52 and s[4] == 5)) then
                    PushNum(4, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 53 and s[4] == 76) or (s[3] == 53 and s[4] == 6)) then
                    PushNum(5, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 15 and s[4] <= 17)) or (s[1] == "key_down" and (s[3] == 54 and s[4] == 77) or (s[3] == 54 and s[4] == 7)) then
                    PushNum(6, false) end
                if (s[1] == "touch" and (s[3] >= 64 and s[3] <= 68) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 55 and s[4] == 71) or (s[3] == 55 and s[4] == 8)) then
                    PushNum(7, false) end
                if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 76) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 56 and s[4] == 72) or (s[3] == 56 and s[4] == 9)) then
                    PushNum(8, false) end
                if (s[1] == "touch" and (s[3] >= 80 and s[3] <= 84) and (s[4] >= 11 and s[4] <= 13)) or (s[1] == "key_down" and (s[3] == 57 and s[4] == 73) or (s[3] == 57 and s[4] == 10)) then
                    PushNum(9, false) end
                if (s[1] == "touch" and (s[3] >= 82 and s[3] <= 84) and (s[4] == 9)) then resetNum() end
                if (s[1] == "key_down" and (s[3] == 8 and s[4] == 14)) then backspace() end
                if tonumber(newBalance) > 0 and (STnewNum ~= nil or STnewNum ~= '') then
                    if (s[1] == "touch" and (s[3] >= 72 and s[3] <= 83) and (s[4] >= 23 and s[4] <= 25)) or (s[1] == "key_down" and (s[3] == 13 and s[4] == 28)) then
                        goToSellBalance(id, STnewNum) end
                end
            end
            if s and s[1] == "touch" then
                if (s[3] >= 3 and s[3] <= 18) and (s[4] == SettingMain.ResMain[2] - 1) then balance() end
                if (s[3] >= 46 and s[3] <= 57) and (s[4] == SettingMain.ResMain[2] - 1) then goToSellBalance(id,
                        countInMe) end
            end
        else
            if s and s[1] == "touch" then
                if (s[3] >= 33 and s[3] <= 53) and (s[4] >= 18 and s[4] <= 21) then balance() end
            end
        end
    end
end


_G.goToSellBalance = function(id, num)
    local function scanInvPlayer(itemToTake_Name, itemToTake_damage)
        local count = 0
        local err, allStacks = pcall(pim.getAllStacks)
        for i = 1, 36 do
            if allStacks[i] ~= nil and allStacks[i].all() ~= nil then
                if allStacks[i].all().id ~= nil and allStacks[i].all().dmg ~= nil then
                    if allStacks[i].all().id == itemToTake_Name and allStacks[i].all().dmg == itemToTake_damage then
                        count = count + allStacks[i].all().qty
                    end
                end
            end
        end
        return err == true and tonumber(count) or 0
    end

    local statusBuy = ''
    local CountToBuy = tonumber(num)
    local userToHold = PlayerPIM
    local selectedItem = _G.BuffTableItemBalance[id]
    local FullMoney = tonumber(string.format("%.3f", tonumber(CountToBuy * selectedItem.balance)))
    CountSelectedItemToME = scanInvPlayer(selectedItem.id, selectedItem.dmg)


    if CountSelectedItemToME >= CountToBuy and (CountToBuy ~= 0 or CountToBuy ~= nil or CountToBuy ~= '') then
        clear(SettingMain.ResMain[1], SettingMain.ResMain[2])
        fill(1, 1, SettingMain.ResMain[1], SettingMain.ResMain[2], " ", SettingMain.color.gray)
        setColorText(nil, 12, "[0x00cc00]Происходит процесс продажи[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 13, "[0xffffff]Товар: [0x46c8e3]" .. selectedItem.name .. "[0xffffff]",
            SettingMain.color.gray)
        setColorText(nil, 15, "[0xf2b233]Не покидайте PIM до завершения процесса[0xffffff]",
            SettingMain.color.gray)


        local gift = takeItem(tostring(selectedItem.id), tonumber(selectedItem.dmg), CountToBuy)
        if gift == CountToBuy then
            fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
            fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
            setColorText(nil, 12, "[0x00cc00]Процесс продажи завершен[0xffffff]",
                SettingMain.color.gray)
            setColorText(nil, 15, "[0xf2b233]Баланс успешно пополнен![0xffffff]",
                SettingMain.color.gray)
            statusBuy = 'success'
        else
            CountToBuy = gift
            FullMoney = tonumber(string.format("%.3f", tonumber(CountToBuy * selectedItem.balance)))
            if CountToBuy == 0 then
                fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                setColorText(nil, 12, "[0xff0000]Процесс продажи завершен[0xffffff]",
                    SettingMain.color.gray)
                setColorText(nil, 15, "[0xf2b233]Товар не забрали, ваш баланс не был изменен![0xffffff]",
                    SettingMain.color.gray)
                statusBuy = 'emerrorget'
            else
                fill(1, 12, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                fill(1, 15, SettingMain.ResMain[1], 1, " ", SettingMain.color.gray)
                setColorText(nil, 12, "[0x00cc00]Процесс продажи завершен[0xffffff]",
                    SettingMain.color.gray)
                setColorText(nil, 15,
                    "[0xf2b233]Товар забран частично! Забрали: " ..
                    CountToBuy .. " шт., на сумму: " .. FullMoney .. " [0xffffff]", SettingMain.color.gray)
                statusBuy = 'selminisuccess'
            end
        end


        if CountToBuy > 0 then
            local SendMoneyErr, SendMoney = pcall(function() return sendGET(SettingMain.http ..
                "balance.php?TokenAuth=" ..
                NowSettingShop.TokenAuth .. "&player=" .. userToHold .. "&type=2&balance=" .. FullMoney .. "") end)
            if SendMoneyErr == false or SendMoney ~= "success" then
                logDiscord("(goToSellBalance) balance.php: Не смог пополнить баланс игрока (" ..
                userToHold .. ") Продавал: " ..
                selectedItem.name .. " (" .. CountToBuy .. " шт.) (" .. FullMoney .. " эм)  ")
                logShop("balance,emerrorserver," ..
                selectedItem.id .. selectedItem.dmg .. "," .. FullMoney .. "," .. CountToBuy .. "")
            end
            NowSettingShop.UserInfo.balance = tonumber(string.format("%.3f",
                tonumber(NowSettingShop.UserInfo.balance + FullMoney)))
            SendMoney = nil
        end
        logShop("balance," .. statusBuy .. "," .. selectedItem.id ..
        selectedItem.dmg .. "," .. FullMoney .. "," .. CountToBuy .. "")
        os.sleep(1)
        local pimErrStatus, name = pcall(pim.getInventoryName)
        if name ~= PlayerPIM then
            UserLogout()
            mainScreenShop()
        end
        if CountBalanceList() ~= #_G.BuffTableItemBalance then UpdateBalanceList() end
        NewMainSceenPI()
    else
        local pimErrStatus, name = pcall(pim.getInventoryName)
        if name ~= PlayerPIM then
            UserLogout()
            mainScreenShop()
        end
        balanceInfo(id)
    end
end

if #_G.ProductList == 0 or _G.ProductList == nil then LoaditemAfterBoot() else mainScreenShop() end
