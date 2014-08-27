if not HAS_RUN then

	STOCKS = {}

	require"socket"

	http = require"socket.http"

	require("irclib")

	start()

	local s

	while not(tostring(s):find("End of /NAMES list")) do
		s = irc_receive()
		if s then print(s) end
	end

	--irc_send("/join #StockBotTesting")

	--local STOCK_FOCUS = "TRON"

	--local MNIIP_FOCUS = {{['min'] = 650, ['max'] = 1000, ['name'] = "TRON"}, {['min'] = 25, ['max'] = 50, ['name'] = "FRG2"}}

	if not io.open("focus.stock", "r") then
		local f = io.open("focus.stock", "w")
		f:write([[MNIIP_FOCUS = {
	{['name'] = "TRON", ['min'] = 650, ['max'] = 1000, ['amount'] = 90,
		['active']= true
	},
	{['name'] = "IRON", ['min'] = -1, ['max'] = 9e99, ['amount'] = 50,
		['active']= true
	},
	{['name'] = "C5", ['min'] = -1, ['max'] = 9e99, ['amount'] = 50,
		['active']= true
	},
	{['name'] = "PSCN", ['min'] = -1, ['max'] = 9e99, ['amount'] = 50,
		['active']= true
	},
	{['name'] = "WATR", ['min'] = -1, ['max'] = 9e99, ['amount'] = 50,
		['active']= true
	},
	{['name'] = "GOLD", ['min'] = -1, ['max'] = 9e99, ['amount'] = 80,
		['active']= true
	},
	{['name'] = "OIL", ['min'] = -1, ['max'] = 10, ['amount'] = 80,
		['active']= true
	},
}]])
		f:close()
	end

	dofile("focus.stock")

	n = #MNIIP_FOCUS

	--local STOCK_URL = "http://tptapi.com/stock_history.php?history=" .. STOCK_FOCUS
	MARKET_URL = "http://tptapi.com/stock.php"

	CURRENT_USER = "BMNNation"

	CURRENT_PASS = "_PASSWORD"

	QUERY_TAB = irc_send("/query stockbot614")
	setTab(QUERY_TAB)
	irc_send("!!login " .. CURRENT_USER .. " " .. CURRENT_PASS)
	--irc_send("test")

	--irc_send("/join #TPTAPIStocks")
	irc_send("/join #BMNStockBot")

	irc_rawsend("#BMNStockBot", "Booted successfully!")

end

CONNECTED = true

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

local TableStr = [[
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>BMN &middot; Stocks</title>
</head>
<body>
<table style="text-align: left; width: 1000px;" border="3"
 cellpadding="2" cellspacing="2">
]]

local TableStrAlt = [[
<!DOCTYPE html><html><head>
  <meta charset="ISO-8859-1">
  <title>BMN · Stocks</title>
  <link href="//brilliant-minds.tk/bootstrap/bootstrap.min.css" rel="stylesheet" type="text/css">
  <link href="//brilliant-minds.tk/bootstrap/bootstrap-theme.min.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="http://vps3.wolfy1339.tk/bootstrap/css/font-awesome.min.css">
  <link rel="icon" type="image/png" sizes="152x152" href="http://brilliant-minds.tk/img/favicon152.png">

</head>
<body><div class="table-responsive">
<table style="text-align: left; width: 1000px;" border="0" cellpadding="2" cellspacing="2" id="bstable" class="table table-hover table-striped">
]]
MainTableStr = TableStr

function round(n)
	return n-math.floor(n) >= 0.5 and math.ceil(n) or math.floor(n)
end

function sendMessage()
	local f = io.open("message.stock", "r")
	local s = f:read("*all")
	f:close()
	if #s > 0 then
		irc_rawsend("#BMNStockBot", ({s:gsub("@REPEAT", "")})[1])
		print(({s:gsub("@REPEAT", "")})[1])
		if not s:find("@REPEAT") then
			f = io.open("message.stock", "w")
			f:write("")
			f:close()
		end
	end
end

UPDATE_SCRIPT=false

if not(threshold) then
	threshold = 0
end

local commands = {}
local help = {}

	help.main = function()
		irc_rawsend("#BMNStockBot", 'Commands: "*command args ..."')
		irc_rawsend("#BMNStockBot", 'For help on a particular command, type "*help [command]"')
		irc_rawsend("#BMNStockBot", 'For a list of commands, type "*commands"')
	end

	commands.help = function(t)
		if not(t[1]) then
			help.main()
		else
			if help[t[1]] then
				irc_rawsend("#BMNStockBot", help[t[1]])
			else
				irc_rawsend("#BMNStockBot", "Sorry, no help available for that command.")
			end
		end
	end

	commands.buy = function(t)
		irc_send("!!buy " .. t[1] .. " " .. t[2] .. "%")
		irc_rawsend("#BMNStockBot", "Bought " .. t[2] .. "% " .. (t[1]):upper() .. "!")
	end
	help.buy = "*buy (name of stock) (percentage). Used just like !!buy."

	commands.sellall = function(t)
		irc_send("!!sellall " .. t[1])
		irc_rawsend("#BMNStockBot", "Sold all" .. t[1] .. " stocks!")
	end
	help.sellall = "*sellall (name of stock). Sells all of said stock, as the name implies."

	commands.msg = function(t)
		irc_rawsend("#TPTAPIStocks", table.concat(t, " "))
	end
	help.msg = "*msg (message to be sent). Sends a message to the #TPTAPI channel."

	commands.reboot = function(t)
		UPDATE_SCRIPT = true;
		irc_rawsend("#BMNStockBot", "Rebooting next cycle!")
		cycle = true
	end
	help.reboot = "*reboot (NO ARGS). Runs a cycle, then reboots the script without closing it. The code is also updated."

	commands.commands = function(t)
		local s = ""
		for i, v in pairs(commands) do
			s = s .. i .. ", "
		end
		s = s:sub(1, -3)
		irc_rawsend("#BMNStockBot", s)
	end
	help.commands = "*commands (NO ARGS). Displays a list of commands."

	commands.cycle = function(t)
		cycle = true
	end
	help.cycle = "*cycle (NO ARGS). Checks focus stocks and updates the output page."

	commands.focus = function(t)
		if t[1] then
			local f = io.open("focus.stock", "r")
			local s = f:read("*all")
			f:close()
			s = s:sub(1, -2)
			for i, v in ipairs(t) do
				s = s .. "	{['name'] = \"" .. v .. [[", ['min'] = -1, ['max'] = 9e99, ['amount'] = 50,
		['active']= true
	},]] .. "\n"
			end
			s = s .. "}"
			local f = io.open("focus.stock", "w")
			f:write(s)
			irc_rawsend("#BMNStockBot", "Added stocks " .. (table.concat(t, ", ")):sub(1, -1) .. " to focus list!")
		else
			local s = "Focus stocks: "
			for n = 1, #MNIIP_FOCUS do
				s = s .. MNIIP_FOCUS[n].name .. ", "
			end
			irc_rawsend("#BMNStockBot", s:sub(1, -3))
		end
	end
	help.focus = "*focus (stock) (stock) ... - if args are given, adds each arg to the stock focus list, else lists current focus stocks."

	commands.output = function(t)
		if not t[1] then
			irc_rawsend("#BMNStockBot", "Options: fancy, normal")
		elseif type(t[1]) == 'string' then
			if (t[1]):lower() == "fancy" or (t[1]):lower() == "normal" then
				local f = io.open(t[1] .. ".txt", "r")
				local s = f:read("*all")
				TableStr = s
				TableMode = t[1]
				irc_rawsend("#BMNStockBot", "Set output formatting to " .. t[1] .. ".txt!")
			else
				irc_rawsend("#BMNStockBot", "Invalid output mode!")
			end
		end
	end
	help.output = "*output (OPT). Sets the output mode, or lists the possible output modes if no arguments are given."

	commands.threshold = function(t)
		if t[1] then
			threshold = t[1]
			irc_rawsend("#BMNStockBot", "Set buy/sell threshold to " .. t[1] .. "%!")
		else
			irc_rawsend("#BMNStockBot", "Please enter threshold value!")
		end
	end
	help.threshold = "*threshold (percent). Sets the buy/sell threshold."

TableMode = "fancy"
commands.output{TableMode}


while not UPDATE_SCRIPT do
---[[

	print()

	--irc_rawsend("#BMNStockBot", "/ping")

	CurrentTime = os.date("*t", os.time())

	local cmd, n = {}
	cycle = false

	while not(CurrentTime.sec % 15 == 0 or cycle) do
		setTab("#BMNStockBot")
		local msg = irc_receive()
		cmd, n = {}
		if msg then
			print(msg)
			if type(msg) == "string" then
				if msg:find("ping") then
					irc_rawsend("#BMNStockBot", "Recieved possible ping: " .. msg)
				end
				msg = msg:sub(2, -1)
				if ((msg:lower()):find("feynman") or msg:find("wolfy1339") or msg:find("KydonShadow")) and msg:find("PRIVMSG") then
					local msg = msg:sub(msg:find(":") + 1, -1)
					print(msg)
					cmd, n = {}, 1
					if msg:sub(1, 1) == "*" then
						msg = msg:gsub("%*", "")
						print(msg)
						for s in msg:gmatch("%S+") do
							print("ARG: " .. s)
							cmd[n] = s
							n = n + 1
						end
					end
				end
			end
		end
		setTab(QUERY_TAB)
		if cmd[1] then
			print(cmd[1])
			if commands[cmd[1]] then
				(commands[table.remove(cmd, 1)])(cmd)
			else
				irc_rawsend("#BMNStockBot", "Invalid command " .. cmd[1] .. "!")
			end
		end
		CurrentTime = os.date("*t", os.time())
		---[[
		local f = io.open("reboot.stock", "r")
		local s = f:read("*all")
		f:close()
		if #s > 1 then
			local f = io.open("reboot.stock", "w")
			f:write("")
			f:close()
			if (s:sub(1, 1) == "*") then
				irc_rawsend("#BMNStockBot", "REBOOTING AFTER NEXT CYCLE: " .. s)
			end
			UPDATE_SCRIPT=true
			print("REBOOTING AFTER NEXT CYCLE!")
			--os.execute("StockBot.lua")
		end

		sendMessage()

		--]]
	end

	--dofile("STOCK_FOCUS.txt")
--]]

	local f = io.open(TableMode .. ".txt", "r")
	local s = f:read("*all")
	TableStr = s
	f:close()

	InfoFile = io.open("output/index.html", "w")
	print(InfoFile)

	local function TablePush(...)
		if type(({...})[1]) == 'table' then
			local cols, args = ({...})[1], {...}
			table.remove(args, 1)
			for i, v in ipairs(args) do
				TableStr = TableStr .. '\n\t<td style="background-color: rgb(' ..
					cols[1] .. ', ' .. cols[2] .. ', ' .. cols[3] .. '); width: 200px;">' ..
					args[i] .. '</td>\n'
			end
		else
			for i, v in ipairs{...} do
				TableStr = TableStr .. '\n\t<td style="width: 200px;">' .. ({...})[i] .. '</td>\n'
			end
		end
	end
	local function TableRow()
		TableStr = TableStr .. '</tr>\n<tr>'
	end
	if TableMode=="fancy" then
		TableStrEnd = [[
		</tbody>
		</div>
		</div>
		</table>
		</body>
		</html>
		]]
	else
		TableStrEnd = [[
		</tbody>
		</table>
		</body>
		</html>
		]]
	end

	print()

	print(
		"+" ..
		string.rep("-", 31) ..
		"+"
	)
--[[
	TablePush(CurrentTime.year .. ":\t" ..
		months[CurrentTime.month] .. " " ..
		CurrentTime.day .. ":\t" ..
		(" "):rep(2 - #(tostring(CurrentTime.hour))) .. CurrentTime.hour .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.min))) .. CurrentTime.min .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.sec))) .. CurrentTime.sec
	)
	TableRow()
--]]
	print(
		"|" .. CurrentTime.year .. ":\t" ..
		months[CurrentTime.month] .. " " ..
		CurrentTime.day .. ":\t" ..
		(" "):rep(2 - #(tostring(CurrentTime.hour))) .. CurrentTime.hour .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.min))) .. CurrentTime.min .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.sec))) .. CurrentTime.sec .. "|"
	)

	print(
		"+" ..
		string.rep("-", 6) .. "+" .. string.rep("-", 24) ..
		"+" .. ("-"):rep(28) .. "+"
	)

	dofile("focus.stock")

	local n = #MNIIP_FOCUS

	TableStr = TableStr .. "<p>Current threshold: " .. threshold .. "</p>\n<thead>\n"
	TablePush("Stock", "Price", "% Avg. Dev.", "Avg. Dev.", "Owned")
	TableStr = TableStr .. "</thead>"

	print(("|%-6s| %5s%15s%15s%15s  |"):format("Stock", "Price", "% Avg. Dev.", "Avg. Dev.", "Owned"))
	TableRow()
	print("|------+" .. ("-"):rep(53) .. "+")

	table.sort(MNIIP_FOCUS, function(a, b) if (a.name):sub(1, 1) < (b.name):sub(1,1) then return true else return false end end)

	for n = 1, #MNIIP_FOCUS do

		STOCK_FOCUS = MNIIP_FOCUS[n].name

		local STOCK_URL = "http://tptapi.com/stock_history.php?history=" .. STOCK_FOCUS

		local STOCK_DATA = tostring(http.request(STOCK_URL))

		local STOCK_PRICE, STOCKS_OWNED = 0, 0

		local STOCK_HIST_SUM, STOCK_HIST_COUNT = 0, 0

		--['2014-08-18 17:10:14',  698]

		for v in STOCK_DATA:gmatch("%['%d+-%d+-%d+%s%d+:%d+:%d+'%,%s+%d+%]") do
			for d in v:gmatch("%,%s+%d+%]") do
				--print(STOCK_FOCUS .. " CURRENT VALUE: " .. d)
				STOCK_HIST_SUM = STOCK_HIST_SUM + tonumber(d:match("%d+"))
				STOCK_HIST_COUNT = STOCK_HIST_COUNT + 1
			end
		end

		local STOCK_AVERAGE = STOCK_HIST_SUM / STOCK_HIST_COUNT

		for v in STOCK_DATA:gmatch("%['CURRENT'%,%s+%d+%]") do
			for d in v:gmatch("%d+") do
				--print(STOCK_FOCUS .. " CURRENT VALUE: " .. d)
				STOCK_PRICE = d
			end
		end

		for v in STOCK_DATA:gmatch("%['" .. CURRENT_USER .. "'%,%s+%d+%]") do
			for d in v:gmatch("%d+") do
				--print(STOCK_FOCUS .. " STOCKS OWNED BY " .. CURRENT_USER .. ": " .. d .. "\n\n")
				STOCKS_OWNED = STOCKS_OWNED + d
			end
		end

		local STOCK_PRICE_AVG = STOCK_PRICE - STOCK_AVERAGE
		local STOCK_AVG_DEV = (STOCK_PRICE - STOCK_AVERAGE) / STOCK_AVERAGE * 100

		--print(STOCK_FOCUS .. "\n" .. ("_"):rep(50))

		local pstr = ("|%-5s%s| %5d%15s%15d%15g  |"):format(STOCK_FOCUS, (STOCKS_OWNED > 0 and "#" or " "), STOCK_PRICE, round(STOCK_AVG_DEV) .. "%", STOCK_PRICE_AVG, STOCKS_OWNED)

		local ptbl = {STOCK_FOCUS, STOCK_PRICE, round(STOCK_AVG_DEV) .. "%", round(STOCK_PRICE_AVG), STOCKS_OWNED}
		if STOCKS_OWNED > 0 then
			table.insert(ptbl, 1, {255,255,185})
		end
		TablePush(unpack(ptbl))
		TableRow()
		print(({pstr:gsub(" ", MNIIP_FOCUS[n].active and " " or "ú")})[1])

		if tostring(STOCK_AVG_DEV) == "-nan" and CONNECTED then
			irc_rawsend("#TPTAPIStocks", "Connection down!")
			CONNECTED = false
		elseif not(CONNECTED) and not(tostring(STOCK_AVG_DEV) == "-nan") then
			irc_rawsend("#TPTAPIStocks", "Connection back up!")
			CONNECTED = true
		end
		--[[
		):format("-- Raw Price:", "STOCK_PRICE"))
		print("-- Price (c.t. Average):		" .. round(STOCK_PRICE_AVG) .. " (Stock Average: " .. round(STOCK_AVERAGE) .. ")")
		print("-- Average Price:			" .. round(STOCK_AVG_DEV) .. "%")
		--print("TEST")
		--]]

		if MNIIP_FOCUS[n].active == true and tostring(STOCK_PRICE) ~= "0" then
			if (tonumber(STOCK_PRICE) <= MNIIP_FOCUS[n].min or STOCK_AVG_DEV <= -45) and not(STOCKS[n] == STOCK_PRICE) then
				irc_send("!!buy " .. MNIIP_FOCUS[n].name .. " " .. MNIIP_FOCUS[n].amount .. "%")
				irc_rawsend("#BMNStockBot", "02Bought " .. MNIIP_FOCUS[n].amount .. "% " .. MNIIP_FOCUS[n].name .. " Stocks!")
				STOCKS[n] = STOCK_PRICE
			elseif (tonumber(STOCK_PRICE) >= MNIIP_FOCUS[n].max or STOCK_AVG_DEV >= 45) and STOCKS_OWNED > 0 then
				irc_send("!!sellall " .. MNIIP_FOCUS[n].name)
				irc_rawsend("#BMNStockBot", "04Sold all " .. MNIIP_FOCUS[n].name .. " Stocks!")
			elseif (STOCK_AVG_DEV < tonumber(threshold)*-1) and not(STOCKS[n] == STOCK_PRICE) then
				irc_send("!!buy " .. MNIIP_FOCUS[n].name .. " " .. math.abs(STOCK_AVG_DEV) .. "%")
				irc_rawsend("#BMNStockBot", "02Bought " .. math.abs(round(STOCK_AVG_DEV)) .. "% " .. MNIIP_FOCUS[n].name .. " Stocks!")
				STOCKS[n] = STOCK_PRICE
			elseif (math.floor(STOCK_AVG_DEV) > tonumber(threshold)) and not(STOCKS[n] == STOCK_PRICE) and MNIIP_FOCUS[n].min == -1 and STOCKS_OWNED > 0 then
				irc_send("!!sellall " .. MNIIP_FOCUS[n].name)
				irc_rawsend("#BMNStockBot", "04Sold all " .. MNIIP_FOCUS[n].name .. " Stocks!")
				--irc_rawsend("#TPTAPIStocks", "DEBUG - Command used: " .. "!!sellall " .. MNIIP_FOCUS[n].name)
				STOCKS[n] = STOCK_PRICE
			end
		end

		STOCKS_OWNED = 0

		--irc_rawsend(QUERY_TAB, "/ping")

		--print("\n")

	end

	InfoFile:write((TableStr:gsub("DATE",
		CurrentTime.year .. ":\t" ..
		months[CurrentTime.month] .. " " ..
		CurrentTime.day .. ":\t" ..
		(" "):rep(2 - #(tostring(CurrentTime.hour))) .. CurrentTime.hour .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.min))) .. CurrentTime.min .. ":" ..
		("0"):rep(2 - #(tostring(CurrentTime.sec))) .. CurrentTime.sec))
 	.. TableStrEnd)
	InfoFile:close()

	--irc_rawsend("#TPTAPIStocks", "Stock check cycle finished!")

	while CurrentTime.sec % 15 == 0 do
		CurrentTime = os.date("*t", os.time())
		--irc_receive()
	end

end
irc_rawsend("#BMNStockBot", "Reboot completed!")

HAS_RUN=true

dofile("StockBot.lua")
--f:write(TRON_DATA)
--f:close()

--io.read()

