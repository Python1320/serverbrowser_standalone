

require"util"


--:gsub("/",'\\')

--hook={}
--hook.Add=function() end
--timer={}
--timer.Simple=function() end

--vstruct = require"vstruct"


_G.Msg=io.write
_G.MsgN=print
_G.ErrorNoHalt=Msg

local socket=require"socket"
local Now = socket.gettime

co = require"co"
local cothink = co._Think
local serverquery = require"serverquery" or serverquery

local first = true
local OnThink

ID_LISTCTRL = 1000

local listCtrl

local listCtrl_n=-1
local function add(name,ping)
    listCtrl_n = listCtrl_n  + 1
	--local lc_item = listCtrl:GetItemCount()

    lc_item = listCtrl:InsertItem(listCtrl_n, name)
    listCtrl:SetItem(lc_item, 1, tostring(ping))

    return lc_item
end


function main()

	frame = wx.wxFrame( 
		wx.NULL, 
		wx.wxID_ANY, 
		"Source server browser",
		wx.wxDefaultPosition, 
		wx.wxSize(600, 400),
		wx.wxDEFAULT_FRAME_STYLE )
	
	listCtrl = wx.wxListView(frame, 
		ID_LISTCTRL,
		wx.wxDefaultPosition, 
		wx.wxDefaultSize,
		wx.wxLC_REPORT + wx.wxLC_SINGLE_SEL + wx.wxLC_HRULES + wx.wxLC_VRULES)
  
	listCtrl:InsertColumn(0, "Name", wx.wxLIST_FORMAT_LEFT, -1)
    listCtrl:InsertColumn(1, "Ping (ms)", wx.wxLIST_FORMAT_LEFT, -1)

    listCtrl:SetColumnWidth(0, 480)
    listCtrl:SetColumnWidth(1, 70)
										
	think_hook = wx.wxTimer(frame)   
	

	frame:Connect(wx.wxEVT_TIMER,
		function (event)
				OnThink()
		end)

    think_hook:Start(0)
		
    frame:Show(true)
end

main()


local function server_reply(what,entry,x)
	if what == nil then
		--Msg"[Server Info] Fail "print(entry,x)
	end
	if what == true then
		
		local item = add(tostring(entry.name),not entry.ping and -1 or math.ceil(entry.ping*1000))
		Msg"."
		--Msg"[Server Reply] " print(math.ceil((entry[4] or -1)*1000),entry.name)
	elseif what == false then
		if entry == true then return end
		if entry == false then 
			refreshing = false
			wantstop = true
			
			print"\nSearch: Finished"
      return
		end
		Msg"[Server Info] Got failure: "print(entry,x)
		return
	end

end


worker = serverquery.getServerInfoWorker(server_reply,50,2,1)

stopf=worker.stop or function() end

local function cb(info,ip,port,ipport) 
	if info == true and ip then
		--Msg"add "print(ip,port)
		--if wantstop then return true end
		worker.add_queue(ip,port)
	end
end

OnThink = function()
	cothink()
	
	if true and first then 
			first =false  
			serverquery.getServerList(cb, [[\gamedir\garrysmod\empty\1]])
			--print"first!"
	end
	

	
end


wx.wxGetApp():MainLoop()
