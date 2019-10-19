--[[

Copyright © 2019, Wiener
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PhantomGem nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'PhantomGem'
_addon.author = 'Wiener'
_addon.version = '1.0'
_addon.commands = {'phantomgem', 'pg'}

require('tables')
local packets = require('packets')
local res = require('resources')

npcs = {
    [231] = {name='Trisvain',menuId=892,zone=231},
    [236] = {name='Raving Opossum',menuId=429,zone=236},
    [240] = {name='Mimble-Pimble',menuId=895,zone=240},
}

pGems = {
     [0]={ki=2468, cost=10, oi=2},      -- shadow lord
     [1]={ki=2470, cost=10, oi=258},    -- stellar fulcrum
     [2]={ki=2469, cost=10, oi=514},    -- celestial nexus
     [3]={ki=2471, cost=15, oi=770},    -- apathy
     [4]={ki=2472, cost=15, oi=1026},   -- arrogance
     [5]={ki=2473, cost=15, oi=1282},   -- envy
     [6]={ki=2474, cost=15, oi=1538},   -- cowardice
     [7]={ki=2475, cost=15, oi=1794},   -- rage
     [8]={ki=2476, cost=20, oi=2050},   -- p. perpetrator
     [9]={ki=2545, cost=10, oi=2306},   -- savage
    [10]={ki=2546, cost=10, oi=2562},   -- warrior
    [11]={ki=2556, cost=10, oi=2818},   -- puppet in peril
    [12]={ki=2557, cost=10, oi=3074},   -- legacy
    [13]={ki=2595, cost=10, oi=3330},   -- head wind
    [14]={ki=2619, cost=10, oi=3586},   -- avatar
    [15]={ki=2923, cost=10, oi=3842},   -- moonlit
    [16]={ki=2924, cost=10, oi=4098},   -- waking the beast
    [17]={ki=2925, cost=10, oi=4354},   -- waking dreams
    [18]={ki=2987, cost=10, oi=4610},   -- feared one
    [19]={ki=2988, cost=10, oi=4866},   -- dawn
    [20]={ki=3185, cost=10, oi=5122},   -- stygian pact
    [21]={ki=3186, cost=10, oi=5378},   -- champion
    [22]={ki=3187, cost=10, oi=5634},   -- divine
    [23]={ki=3188, cost=10, oi=5890},   -- maiden
}

shortcuts = {
    ["shadow"] = 0,
    ["lord"] = 0,
    ["sl"] = 0,
    ["stellar"] = 1,
    ["fulcrum"] = 2,
    ["sf"] = 1,
    ["celestial"] = 2,
    ["nexus"] = 2,
    ["cn"] = 2,
    ['apathy'] = 3,
    ['aahm'] = 3,
    ['arrogance'] = 4,
    ['aaev'] = 4,
    ['envy'] = 5,
    ['aamr'] = 5,
    ['cowardice'] = 6,
    ['coward'] = 6,
    ['aatt'] = 6,
    ['rage'] = 7,
    ['aagk'] = 7,
    ['perp'] = 8,
    ['perpetrator'] = 8,
    ['dm'] = 8,
    ['savage'] = 9,
    ['ouryu'] = 9,
    ['warrior'] = 10,
    ['war'] = 10,
    ['tenzen'] = 10,
    ['puppet'] = 11,
    ['peril'] = 11,
    ['pip'] = 11,
    ['legacy'] = 12,
    ['gessho'] = 12,
    ['headwind'] = 13,
    ['shikaree'] = 13,
    ['avatar'] = 14,
    ['garuda'] = 14,
    ['ramuh'] = 14,
    ['titan'] = 14,
    ['ifrit'] = 14,
    ['leviathan'] = 14,
    ['shiva'] = 14,
    ['moonlit'] = 15,
    ['path'] = 15,
    ['mp'] = 15,
    ['fenrir'] = 15,
    ['beast'] = 16,
    ['wtb'] = 16,
    ['dream'] = 17,
    ['wd'] = 17,
    ['diabolos'] = 17,
    ['fearedone'] = 18,
    ['feared'] = 18,
    ['fo'] = 18,
    ['omega'] = 18,
    ['ultima'] = 18,
    ['dawn'] = 19,
    ['promathia'] = 19,
    ['stygian'] = 20,
    ['sp'] = 20,
    ['odin'] = 20,
    ['champion'] = 21,
    ['cait'] = 21,
    ['caitsith'] = 21,
    ['divine'] = 22,
    ['alexander'] = 22,
    ['alex'] = 22,
    ['maiden'] = 23,
    ['lilith'] = 23,
}

local _gem = nil
windower.register_event('addon command', function(...)
    local info = windower.ffxi.get_info()
    local npc = npcs[info.zone]
    if npc then
        local args = T{...}
        local cmd = args[1]

        if cmd == "reset" then
            ResetDialogue(npc, true)
        else
            _gem = nil
            local gemNumber = tonumber(cmd)
            if type(gemNumber) ~= 'number' then
                gemNumber = shortcuts[cmd:lower()]
            end

            if gemNumber and type(gemNumber) == 'number' then
                _gem = pGems[gemNumber]
                if HaveKI(_gem.ki) then
                    windower.add_to_chat(10, "\'" .. res.key_items[_gem.ki].en .. "\' already in possession!")
                    _gem = nil
                else
                    EngageDialogue(npc)
                end
            else
                windower.add_to_chat(10, "Phantom gem was not found.")
            end
        end
    else
        windower.add_to_chat(10, string.format("No phantom gem npc in zone #%d!", info.zone))
    end
end)

function HaveKI(ki)
    local KIs = windower.ffxi.get_key_items()
    for _,v in ipairs(KIs) do
        if v == ki then return true end
    end
    return false
end

function FindNPC(npcName)
    local playerMob = windower.ffxi.get_mob_by_target('me')
    local npcMob = windower.ffxi.get_mob_by_name(npcName)
    if playerMob and playerMob.status == 0 and npcMob then
        if math.sqrt(npcMob.distance) < 6 then
            return npcMob.id, npcMob.index
        else
            windower.add_to_chat(10, "Phantom gem NPC too far away!")
        end
    end
    return nil, nil
end

function EngageDialogue(npc)
    local target, targetIndex = FindNPC(npc.name)
	if target and targetIndex then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=target,
			["Target Index"]=targetIndex,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

windower.register_event('incoming chunk',function(id,data)
    if is_injected then return end

    if id == 0x034 then
        local p = packets.parse('incoming',data)
        local zone = p['Zone']
        local menuId = p['Menu ID']
        local npc = npcs[zone]
        local merits = data:unpack('I2',17)
        if not _gem or not npc or npc.menuId ~= menuId then return false end
        if _gem.cost <= merits then
            local packet = packets.new('outgoing', 0x05B)
            packet["Target"]=p['NPC']
            packet["Option Index"]=_gem.oi
            packet["_unknown1"]=0
            packet["Target Index"]=p['NPC Index']
            packet["Automated Message"]=false
            packet["_unknown2"]=0
            packet["Zone"]=zone
            packet["Menu ID"]=menuId
            packets.inject(packet)

            _gem = nil
            return true
        else
            windower.add_to_chat(10, 'Not enough merits to buy gem!')
            ResetDialogue(npc, false)
            _gem = nil
            return true
        end
    end
end)

function ResetDialogue(npc, forced)
    _gem = nil
    local target, targetIndex = FindNPC(npc.name)
	if target and targetIndex then
		local resetPacket = packets.new('outgoing', 0x05B, {
		["Target"]=target,
		["Option Index"]=0,
		["_unknown1"]=16384,
		["Target Index"]=targetIndex,
		["Automated Message"]=false,
		["_unknown2"]=0,
		["Zone"]=npc.zone,
		["Menu ID"]=npc.menuId})
		packets.inject(resetPacket)
        if forced then
            windower.add_to_chat(10, 'Reset sent.')
        end
	end
end
