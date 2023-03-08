--CHECK PARAMS
if not ngx.var.arg_id then
    ngx.log(ngx.ERR, 'ID is missed')
    return
end

--CONNECT TO THE REDIS
local redis = require "redis"
local red = redis:new()
red:set_timeout(1000)
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.log(ngx.ERR, 'Redis connect failed '..err)
    return
end

local key = "views_"..ngx.var.arg_id.."_"..ngx.var.remote_addr.."_"..os.date("%Y%m%d%H")

ok, err = red:incr(key)
if not ok then
    ngx.log(ngx.ERR, 'Error on increment'..err)
    return
end

--SET CONNECTION TO PULL
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.log(ngx.ERR, 'Keepalive failed')
    return
end

ngx.say("#empty JAVASCRIPT")