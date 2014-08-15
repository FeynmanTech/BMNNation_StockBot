local mode = "mniip"

STOCKS = {}

require"socket"

local http = require"socket.http"

require("irclib")

start()

local s

--while s ~= "ÿ" do
	while not(tostring(s):find("End of /NAMES list")) do
		s = irc_receive()
	end
	--[[
	if s ~= nil then
		print(("%q"):format(s), s)
		if s == "ÿ" then
			print("S=ÿ")
		end
	end
	--]]
--end

--irc_send("/join #StockBotTesting")

--local STOCK_FOCUS = "TRON"

--local MNIIP_FOCUS = {{['min'] = 650, ['max'] = 1000, ['name'] = "TRON"}, {['min'] = 25, ['max'] = 50, ['name'] = "FRG2"}}

if not io.open("focus.stock", "r") then
	local f = io.open("focus.stock", "w")
	f:write([[MNIIP_FOCUS = {
		{['min'] = 650, ['max'] = 1000, ['amount'] = 90, ['name'] = "TRON"},
		{['min'] = 25, ['max'] = 50, ['amount'] = 90, ['name'] = "FRG2"},
		{['min'] = 7, ['max'] = 15, ['amount'] = 50, ['name'] = "GLOW"},
	}]])
	f:close()
end

dofile("focus.stock")

local n = #MNIIP_FOCUS

--local STOCK_URL = "http://tptapi.com/stock_history.php?history=" .. STOCK_FOCUS
local MARKET_URL = "http://tptapi.com/stock.php"

local CURRENT_USER = "BMNNation"

local CURRENT_PASS = "[BMNNation Password]"

irc_send("/query stockbot614")
--irc_send("!!login " .. CURRENT_USER .. " " .. CURRENT_PASS)
--irc_send("test")

irc_send("/join #TPTAPIStocks")

--local f = io.open("TRON_STOCK_DATA.txt", "w")

local CurrentTime = os.date("*t", os.time())

local months = {
	"Jan.",
	"Feb.",
	"Mar.",
	"Apr.",
	"May",
	"Jun.",
	"Jul",
	"Aug.",
	"Sep.",
	"Oct.",
	"Nov.",
	"Dec."
}

function login(user, pass)
	return http.request{
		["method"] = "POST",
		["url"] = "http://tptapi.com/login_proc.php?login",
		["headers"] = {
			["Username"] = user,
			["Password"] = pass,
			["PHPSESSID"] = "qfcnirdolni9t4aoebrv3qldo0"
		}
	}
end

--[[
--print("LOGIN RESULTS: ")
local loginRes = {login("BMNNation", "[BMNNation Password]")}

for i, v in pairs(loginRes) do
	print("\t", i, ":\t", v)
	if type(v) == "table" then
		for ni, nv in pairs(v) do
			print("\t\t", ni, ":\t", nv)
		end
	end
end
--]]
function BuySellStock(action, name, amount)
	return http.request{
		["method"] = "POST",
		["url"] = "http://tptapi.com/stockProc.php?opt="..action.."&stock="..name,
		["headers"] = {
			["shares"] = amount,
			["class"] = 1
		}
	}
end
--[[
print("\n\n")

print("BUY/SELL RESULTS: ")
local BuySellRes = {BuySellStock(0, "SING", 10)}

for i, v in pairs(BuySellRes) do
	print("\t", i, ":\t", v)
	if type(v) == "table" then
		for ni, nv in pairs(v) do
			print("\t\t", ni, ":\t", nv)
		end
	end
end
--]]

function sendMessage()
	local f = io.open("message.stock", "r")
	local s = f:read("*all")
	f:close()
	f = io.open("message.stock", "w")
	if #s > 0 then
		irc_send(({s:gsub("@REPEAT", "")})[1])
		if not s:find("@REPEAT") then
			f:write("")
		end
	end
	f:close()
end

while true do
---[[

	irc_send("/ping")

	CurrentTime = os.date("*t", os.time())

	while not(CurrentTime.sec % 15 == 0) do
		CurrentTime = os.date("*t", os.time())
		---[[
		local f = io.open("reboot.stock", "r")
		local s = f:read("*all")
		if #s > 5 then
			irc_send(s:gsub("REBOOT", "REBOOTING"))
			os.exit()
			--os.execute("StockBot.lua")
		end

		sendMessage()

		--]]
	end

	--dofile("STOCK_FOCUS.txt")
--]]
	print()
	print()
	print(
		string.rep("*", 40)
	)
	print(
		CurrentTime.year .. ":\t" ..
		months[CurrentTime.month] .. " " ..
		CurrentTime.day .. ":\t" ..
		CurrentTime.hour .. ":" ..
		CurrentTime.min .. ":" ..
		CurrentTime.sec
	)
	print(
		string.rep("*", 40), "\n"
	)

	dofile("focus.stock")

	local n = #MNIIP_FOCUS

	if mode == "mniip" then

		for n = 1, #MNIIP_FOCUS do

			STOCK_FOCUS = MNIIP_FOCUS[n].name

			local STOCK_URL = "http://tptapi.com/stock_history.php?history=" .. STOCK_FOCUS

			local STOCK_DATA = tostring(http.request(STOCK_URL))

			local STOCK_PRICE, STOCKS_OWNED = 0, 0

			for v in STOCK_DATA:gmatch("%['CURRENT'%,%s+%d+%]") do
				for d in v:gmatch("%d+") do
					print(STOCK_FOCUS .. " CURRENT VALUE: " .. d)
					STOCK_PRICE = d
				end
			end

			for v in STOCK_DATA:gmatch("%['" .. CURRENT_USER .. "'%,%s+%d+%]") do
				for d in v:gmatch("%d+") do
					--print(STOCK_FOCUS .. " STOCKS OWNED BY " .. CURRENT_USER .. ": " .. d .. "\n\n")
					STOCKS_OWNED = STOCKS_OWNED + d
				end
			end

			print(STOCK_FOCUS .. " STOCKS OWNED BY " .. CURRENT_USER .. ": " .. STOCKS_OWNED .. "")
			STOCKS_OWNED = 0

			for v in STOCK_DATA:gmatch("%['" .. CURRENT_USER .. "'%,%s+%d+%]") do
				for d in v:gmatch("%d+") do
					--print(STOCK_FOCUS .. " STOCKS OWNED BY " .. "FeynmanLogomaker" .. ": " .. d .. "\n\n")
					STOCKS_OWNED = STOCKS_OWNED + d
				end
			end

			print(STOCK_FOCUS .. " STOCKS OWNED BY " .. "FeynmanLogomaker" .. ": " .. STOCKS_OWNED .. "\n\n")

			if tonumber(STOCK_PRICE) < MNIIP_FOCUS[n].min and not(STOCKS[n] == STOCK_PRICE) then
				irc_send("!!buy " .. MNIIP_FOCUS[n].name .. " " .. MNIIP_FOCUS[n].amount .. "%")
				irc_send("02Bought " .. MNIIP_FOCUS[n].amount .. "% " .. MNIIP_FOCUS[n].name .. " Stocks!")
				STOCKS[n] = STOCK_PRICE
			elseif tonumber(STOCK_PRICE) > MNIIP_FOCUS[n].max and STOCKS_OWNED > 0 then
				irc_send("!!sellall " .. MNIIP_FOCUS[n].name)
				irc_send("04Sold all " .. MNIIP_FOCUS[n].name .. " Stocks!")
			end

			STOCKS_OWNED = 0

		end

	else

		STOCK_FOCUS = "TRON"

		local STOCK_URL = "http://tptapi.com/stock_history.php?history=" .. STOCK_FOCUS

		local STOCK_DATA = tostring(http.request(STOCK_URL))

		local STOCK_PRICE, STOCKS_OWNED = 0, 0

		for v in STOCK_DATA:gmatch("%['CURRENT'%,%s+%d+%]") do
			for d in v:gmatch("%d+") do
				print(STOCK_FOCUS .. " CURRENT VALUE: " .. d)
				STOCK_PRICE = d
			end
		end

		for v in STOCK_DATA:gmatch("%['" .. CURRENT_USER .. "'%,%s+%d+%]") do
			for d in v:gmatch("%d+") do
				--print(STOCK_FOCUS .. " STOCKS OWNED BY " .. CURRENT_USER .. ": " .. d .. "\n\n")
				STOCKS_OWNED = STOCKS_OWNED + d
			end
		end

		print(STOCK_FOCUS .. " STOCKS OWNED BY " .. CURRENT_USER .. ": " .. STOCKS_OWNED .. "")
		STOCKS_OWNED = 0

		for v in STOCK_DATA:gmatch("%['" .. "FeynmanLogomaker" .. "'%,%s+%d+%]") do
			for d in v:gmatch("%d+") do
				--print(STOCK_FOCUS .. " STOCKS OWNED BY " .. "FeynmanLogomaker" .. ": " .. d .. "\n\n")
				STOCKS_OWNED = STOCKS_OWNED + d
			end
		end

		print(STOCK_FOCUS .. " STOCKS OWNED BY " .. "FeynmanLogomaker" .. ": " .. STOCKS_OWNED .. "\n\n")

		if tonumber(STOCK_PRICE) < 400 then
			irc_send("!!buy TRON 90%")
			print("Bought 90% TRON Stocks!")
		elseif tonumber(STOCK_PRICE) > 1000 and STOCKS_OWNED > 0 then
			irc_send("!!sell TRON " .. STOCKS_OWNED)
			print("Sold all TRON Stocks!")
		end
		STOCKS_OWNED = 0

	end

	--irc_send("Stock check cycle finished!")

	while CurrentTime.sec % 15 == 0 do
		CurrentTime = os.date("*t", os.time())
		--irc_receive()
	end

end


--f:write(TRON_DATA)
--f:close()

--io.read()

