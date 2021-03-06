--[[
    Loader for other libraries written by Lorand.
    As long as this is loaded first in other libraries, then the _libs table
    boilerplate prep is unnecessary in those libraries.
--]]

local lor_utils = {}
lor_utils._version = '2016.08.02'
lor_utils._author = 'Ragnarok.Lorand'
lor_utils.load_order = {'functional','math','strings','tables','chat','exec','settings'}

_libs = _libs or {}
_libs.lor = _libs.lor or {}

if not _libs.lor.utils then
    _libs.lor.utils = lor_utils
    _libs.strings = _libs.strings or require('strings')
    
    lor = lor or {}
    lor.G = gearswap and gearswap._G or _G
    xpcall = lor.G.xpcall
    lor.watc = lor.G.windower.add_to_chat
    
    function _handler(err)
        --[[
            Error handler to print the stack trace of the error.
            Example use:
            local fmt = nil
            local status = xpcall(function() fmt = '%-'..tostring(longest_wstr(stbl:keys()))..'s  :  %s' end, _handler)
            if status then return nil end
        --]]
        local st_re = '([^/]+/[^/]+%.lua:.*)'
        local tb_str = debug.traceback()
        local tb = tb_str:split('\n')
        tb = tb:slice(2)
        tb = tb:reverse()
        tb = T({'stack traceback:'}):extend(tb)
        tb:append(err)
        for _,tl in pairs(tb) do
            if (type(tl) == 'string') and (not tl:match('%[C%]: in function \'xpcall\'')) then
                local trunc_line = tl:match(st_re)
                if trunc_line then
                    lor.watc(167, tostring(trunc_line))
                else
                    lor.watc(167, tostring(tl))
                end
            end
        end
    end
    
    --[[
        Wrapper for functions so that calls to them resulting in exceptions will
        generate stack traces.
    --]]
    function traceable(fn)
        return function(...)
            local args = {...}
            local res = nil
            local status = xpcall(function() res = fn(unpack(args)) end, _handler)
            return res
        end
    end
    
    function _silentHandler(err) end
    
    function try(fn)
        return function(...)
            local args = {...}
            local res = nil
            local status = xpcall(function() res = fn(unpack(args)) end, _silentHandler)
            return status, res
        end
    end
    
    local function t_contains(t, val)
        --Used for enforcing the load order without loading the tables library
        for _,v in pairs(t) do
            if v == val then return true end
        end
        return false
    end
        
    function yyyymmdd_to_num(date_str)
        local y,m,d,o = date_str:match('^(%d%d%d%d)[^0-9]*(%d%d)[^0-9]*(%d%d)[^0-9]*(.*)')
        local x = (#o > 0) and (tonumber(o) or 1) or 0
        return os.time({year=y,month=m,day=d}) + x
    end
    
    function isfunc(obj) return type(obj) == 'function' end
    function isstr(obj) return type(obj) == 'string' end
    function istable(obj) return type(obj) == 'table' end
    function isnum(obj) return type(obj) == 'number' end
    function isbool(obj) return type(obj) == 'boolean' end
    function isnil(obj) return type(obj) == 'nil' end
    function isuserdata(obj) return type(obj) == 'userdata' end
    function isthread(obj) return type(obj) == 'thread' end
    function class(obj)
        local m = getmetatable(obj)
        return m and m.__class or type(obj)
    end
    
    local try_req = try(require)
    
    local function load_lor_lib(lname, version)
        if _libs.lor[lname] == nil then
            local success, result = try_req('lor/lor_'..lname)
            if success then
                _libs.lor[lname] = result
            else
                error('lor_%s not found!  Please update from https://github.com/lorand-ffxi/lor_libs':format(lname, lib_version, version))
            end
        end
        if _libs.lor[lname] ~= nil then
            local lib_version = _libs.lor[lname]._version
            local req_version = version and isstr(version) and yyyymmdd_to_num(version) or 0
            if req_version > yyyymmdd_to_num(lib_version) then
                error('lor_%s version %s < %s (required) - Please update from https://github.com/lorand-ffxi/lor_libs':format(lname, lib_version, version))
            end
        end
    end
    
    --[[
        Loads the given libs/lor lib or list of libs, optionally requiring a
        specific version.  It is possible to load all, and specify the version
        for particular libs.
    --]]
    _libs.lor.req = function(...)
        local args = {...}
        local targs = {}
        for _,arg in pairs(args) do
            local targ = istable(arg) and arg or {n=arg,v=0}
            targs[targ.n:lower()] = targ.v
        end
        
        if targs['all'] ~= nil then
            for _,lname in pairs(lor_utils.load_order) do
                load_lor_lib(lname, targs[lname])
            end
        else
            for _,lname in pairs(lor_utils.load_order) do
                if targs[lname] ~= nil then
                    load_lor_lib(lname, targs[lname])
                end
            end
        end
    end
    
    _libs.req = function(...)
        for _,lname in pairs({...}) do
            _libs[lname] = _libs[lname] or require(lname)
        end
    end
    
    lor.G.collectgarbage()
end

return lor_utils

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Ragnarok.Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of libs/lor nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------
