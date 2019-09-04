-- SPAMFilter v1.0 by Darkspy

-- QoL Fixes added by Andersleet:
	-- Will no longer filter messages you send
	-- Added /sf as a slash command
	-- Added support for whisper filtering


-- Keyword threshold to trigger the filter
threshold = 3

-- Other globals

friendTable = {}
friendCount = 0

guildTable = {}
guildCount = 0

groupTable ={}
groupCount = 0

preventKnown = false

-- Slash command handler
SLASH_SPAMFILTER1 = "/spamfilter"
SLASH_SPAMFILTER1 = "/sf"

SlashCmdList["SPAMFILTER"] = function(msg)
	if msg == "toggle" then
		filterSPAM = not filterSPAM
		 if (filterSPAM == false) then
			 DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r SPAM filter enabled")
		 else
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r SPAM filter disabled")
		 end
	elseif msg == "verbose" then
		verbose = not verbose
		 if (verbose == true) then
			 DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r verbose SPAM filtering enabled")
		 else
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r verbose SPAM filtering disabled")
		 end
	elseif msg == "words" then
		if userKeywords then	
			-- build a string using the words array
			result = ""
			for i = 1, #userKeywords do
				--comma delimite
				if (result.length ~= 0) then
					result = result .. ", "
				end
				result = result .. userKeywords[i]
			end
		end 
		--display the words
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r" .. result)	
	elseif msg:find("add") then
	-- get words to add
	msg = string.gsub(msg, "add", "") -- remove the word add
	msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
	msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
	-- If there is not an array, we will have to create it.
	if userKeywords then
		table.insert(userKeywords,msg)
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r Added " .. msg)
	else
		userKeywords = {msg}
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r Added " .. msg)
	end 
	elseif msg:find("remove") then
		-- get words to remove
		msg = string.gsub(msg, "remove", "") -- remove the word remove
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		-- If there is an array to remove an item from.
		if userKeywords then
		-- remove words
			for i = 1, #userKeywords do
				if (userKeywords[i] == msg) then
					table.remove(userKeywords,i)
				end
			end
			--inform the user
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r Removed " .. msg)
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r No custom user words found")
		end
		
	 elseif msg:find("test") then
			
		local pI = GetNumPartyMembers()
		local rI = GetNumRaidMembers()

		local tPM = 0
		local pPM = 0
		local rPM = 0

		-- Party members exist
		if (pI > 0) then
			pPM = pI
		end
		
		if (rI > 0) then
			rPM = rI
		end
		
		tPM = (pPM + rPM)
		
		print(tPM)	
				
	 else
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r List of commands")
		DEFAULT_CHAT_FRAME:AddMessage("/spamfilter toggle                 Enable/Disable SPAM filtering.")
		DEFAULT_CHAT_FRAME:AddMessage("/spamfilter words                  Displays the list of words used to identify SPAM. (3 matches result in a filtered message)")
		DEFAULT_CHAT_FRAME:AddMessage("/spamfilter add WORD          Add a new word to identify SPAM")
		DEFAULT_CHAT_FRAME:AddMessage("/spamfilter remove WORD      Remove a word")
		DEFAULT_CHAT_FRAME:AddMessage("/spamfilter verbose               Toggle displaying filtered messages.")
	end
end

--Load variables, tell the user we loaded etc.
function SPAMFilter_OnLoad()
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter Loaded:|r type /spamfilter or /sf for options.")
	--setup default values on first login
	if (userkeywords == nil) then
		userKeywords = { "welcome","web","buy","sell", "selling", "USD", "cheap", "code", "coupon", "customer", "deal", "deliver", "delivery", "discount", "express", "fast", "free", "gift", "gold",
					   "iphone", "low", "lowest", "order", "promotion", "safe", "sale", "save", "site", "service", "win", "www", "%.com", "%.net", "%.org", "price", "coins",
					   "account", "goo.gl", "[gm]", "http://", "bonus account", "server anniversary", "100g", "disc o unt", "cheapest", "powerleveling", "fast" ,"1000g", "1ooog" }
	end
	
	-- Get names of friends and store them, as well as the count
	for f = 1, GetNumFriends() do
		local fi = GetFriendInfo(f)
		if (fi ~= nil) then
			table.insert(friendTable, fi)
			friendCount = friendCount + 1	
		end		
	end
	
	-- Get names of guild members and store them, as well as the count
	for g = 1, GetNumGuildMembers() do
		local gI = GetGuildRosterInfo(g)
		if (gI ~= nil) then
			table.insert(guildTable, gI)
			guildCount = guildCount + 1
		end
	end
		
 	-- Get names of party and/or raid members and store them, as well as the count
 	-- Group or Raid members -- TODO -- TODO -- TODO
 	
--  	local pI = GetNumPartyMembers()
--  	local rI = 	GetNumRaidMembers()
--  	
--  	local tPM = 0 	
--  	
-- 	if (rI > 0) then
--  		for r = 1, GetRaidRosterInfo(rI) do
--  			table.insert(groupTable, r)
--  		end
--  	end	
--  	
--  	if (pI > 0) then
--  		for r = 1, GetRaidRosterInfo(rI) do
--  			table.insert(groupTable, r)
--  		end
--  	end	
end


-- DEFAULT_CHAT_FRAME:AddMessage(GetNumPartyMembers())

-- ChatFilter() - Used to filter chat messages
local function SpamFilter(msg, player, channelstring, target, ...)
	
	-- Fix to not filter your own sent messages
	if (UnitName("player") == player) then
		return false
	end
	
	-- Fix to not filter your friend's sent messages
	for f = 1, friendCount do
		if (table.contains(friendTable, player)) then
			return false
		end
	end
	
	-- Fix to not filter your guild's sent messages
	for g = 1, guildCount do
		if (table.contains(guildTable, player)) then
			return false
		end
	end
	
	-- Fix to not filter your party or raid's sent messages --- WIP
-- 	if groupTable then
-- 		for g1 = 1, #groupTable do
-- 			if (table.contains(groupTable, player)) then
-- 				DEFAULT_CHAT_FRAME:AddMessage("Hit")
-- 				return false
-- 			else
-- 				DEFAULT_CHAT_FRAME:AddMessage("Not Hit")
-- 			end
-- 		end
-- 	end
		
	
	
	-- Gold spam filter
	 if (filterSPAM == false) then 
	 
		matchCount = 0
		
		-- Search the message for specific userkeywords
		if userKeywords then
			for i = 1, #userKeywords do
				if string.lower(msg):find(userKeywords[i]) then
					matchCount = matchCount + 1
				end
			end
		end
		
		if (preventKnown == true) then
			return false
		end
		
		if (matchCount >= threshold) then
				if (verbose == true) then
					DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SPAM Filter:|r filtered message from " .. player .. " - " .. msg)
				end
			return true
		end
		
		return false
	 end

	return false
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
		
-- Chat filter event hooks
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", SpamFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", SpamFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", SpamFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", SpamFilter)

-- Fix to add support for whispers
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", SpamFilter)

SPAMFilter_OnLoad()
