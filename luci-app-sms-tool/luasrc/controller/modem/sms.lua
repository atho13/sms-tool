local a = require "luci.util"
local a = require "nixio.fs"
local a = require "luci.sys"
local a = require "luci.http"
local a = require "luci.dispatcher"
local a = require "luci.http"
local b = require "luci.sys"
local b = require "luci.model.uci".cursor()
module("luci.controller.modem.sms", package.seeall)

function index()
    entry({"admin", "modem"}, firstchild(), "Modem", 30).dependent = false;
    entry({"admin", "modem", "sms"}, alias("admin", "modem", "sms", "atcommands"), translate("AT/Message"), 3).acl_depends = {"luci-app-sms-tool"}
    entry({"admin", "modem", "sms", "readsms"}, template("modem/readsms"), translate("Received Messages"), 10)
    entry({"admin", "modem", "sms", "sendsms"}, template("modem/sendsms"), translate("Send Messages"), 20)
    entry({"admin", "modem", "sms", "ussd"}, template("modem/ussd"), translate("USSD Codes"), 30)
    entry({"admin", "modem", "sms", "atcommands"}, template("modem/atcommands"), translate("AT Commands"), 1)
    entry({"admin", "modem", "sms", "smsconfig"}, cbi("modem/smsconfig"), translate("Configuration"), 50)
    entry({"admin", "modem", "sms", "delete_one"}, call("delete_sms", smsindex), nil).leaf = true;
    entry({"admin", "modem", "sms", "delete_all"}, call("delete_all_sms"), nil).leaf = true;
    entry({"admin", "modem", "sms", "run_ussd"}, call("ussd"), nil).leaf = true;
    entry({"admin", "modem", "sms", "run_at"}, call("at"), nil).leaf = true;
    entry({"admin", "modem", "sms", "run_sms"}, call("sms"), nil).leaf = true;
    entry({"admin", "modem", "sms", "readsim"}, call("slots"), nil).leaf = true;
    entry({"admin", "modem", "sms", "countsms"}, call("count_sms"), nil).leaf = true;
    entry({"admin", "modem", "sms", "user_ussd"}, call("userussd"), nil).leaf = true;
    entry({"admin", "modem", "sms", "user_atc"}, call("useratc"), nil).leaf = true;
    entry({"admin", "modem", "sms", "user_phonebook"}, call("userphb"), nil).leaf = true;
    entry({"admin", "modem", "load_atcmd"}, call("load_atcmd"), nil).leaf = true
end;

function delete_sms(a)
    local b = tostring(b:get("sms_tool", "general", "readport"))
    local a = a;
    for a in a:gmatch("%d+") do
        os.execute("sms_tool -d " .. b .. " delete " .. a .. "")
    end
end;

function delete_all_sms()
    local a = tostring(b:get("sms_tool", "general", "readport"))
    os.execute("sms_tool -d " .. a .. " delete all")
end;

function get_ussd()
    local a = luci.model.uci.cursor()
    if a:get("sms_tool", "general", "ussd") == "1" then
        return " -R"
    else
        return ""
    end
end;

function get_pdu()
    local a = luci.model.uci.cursor()
    if a:get("sms_tool", "general", "pdu") == "1" then
        return " -r"
    else
        return ""
    end
end;

function ussd()
    local c = tostring(b:get("sms_tool", "general", "ussdport"))
    local d = get_ussd()
    local e = get_pdu()
    local b = a.formvalue("code")
    if b then
        local b = io.popen("sms_tool -d " .. c .. d .. e .. " ussd " .. b .. " 2>&1")
        local d = b:read("*a")
        b:close()
        a.write(tostring(d))
    else
        a.write_json(a.formvalue())
    end
end;

function at()
    local d = tostring(b:get("sms_tool", "general", "atport"))
    local b = a.formvalue("code")
    if b then
        local b = io.popen("sms_tool -d " .. d .. " at " .. b:gsub("[$]", "\\$"):gsub("\"", "\\\"") .. " 2>&1")
        local d = b:read("*a")
        b:close()
        a.write(tostring(d))
    else
        a.write_json(a.formvalue())
    end
end;

function sms()
    local d = tostring(b:get("sms_tool", "general", "sendport"))
    local b = a.formvalue("scode")
    nr = string.sub(b, 1, 20)
    msgall = string.sub(b, 21)
    msg = string.gsub(msgall, "\n", " ")
    if b then
        local b = io.popen("sms_tool -d " .. d .. " send " .. nr .. " '" .. msg .. "'")
        local d = b:read("*a")
        b:close()
        a.write(tostring(d))
    else
        a.write_json(a.formvalue())
    end
end;

function slots()
    local a = {}
    local d = tostring(b:get("sms_tool", "general", "readport"))
    local c = tostring(b:get("sms_tool", "general", "smsled"))
    local e = tostring(b:get("sms_tool", "general", "ledtype"))
    local f = tostring(b:get("sms_tool", "general", "lednotify"))
    local b = tostring(b:get("sms_tool", "general", "storage"))
    local d = luci.util.exec("sms_tool -s" .. b .. " -d " .. d .. " status")
    local b = string.sub(d, 23, 27)
    local d = d:match('[^: ]+$')
    a["use"] = string.match(b, '%d+')
    local b = string.match(b, '%d+')
    if f == "1" then
        luci.sys.call("echo " .. b .. " > /etc/config/sms_count")
        if e == "S" then
            luci.util.exec("/etc/init.d/led restart")
        end;
        if e == "D" then
            luci.sys.call("echo 0 > '/sys/class/leds/" .. c .. "/brightness'")
        end
    end;
    a["all"] = string.match(d, '%d+')
    luci.http.prepare_content("application/json")
    luci.http.write_json(a)
end;

function count_sms()
    os.execute("sleep 3")
    local a = luci.model.uci.cursor()
    if a:get("sms_tool", "general", "lednotify") == "1" then
        local d = tostring(b:get("sms_tool", "general", "readport"))
        local a = tostring(b:get("sms_tool", "general", "storage"))
        local a = luci.util.exec("sms_tool -s" .. a .. " -d " .. d .. " status")
        local a = string.sub(a, 23, 27)
        local a = string.match(a, '%d+')
        os.execute("echo " .. a .. " > /etc/config/sms_count")
    end
end;

function uussd(b)
    local a = nixio.fs.access("/etc/config/ussd.user") and io.popen("cat /etc/config/ussd.user")
    if a then
        for d in a:lines() do
            local a = d;
            if a then
                b[#b + 1] = {usd = a}
            end
        end;
        a:close()
    end
end;

function userussd()
    local a = {}
    uussd(a)
    luci.http.prepare_content("application/json")
    luci.http.write_json(a)
end;

function uat(b)
    local a = nixio.fs.access("/etc/config/atcmds.user") and io.popen("cat /etc/config/atcmds.user")
    if a then
        for d in a:lines() do
            local a = d;
            if a then
                b[#b + 1] = {atu = a}
            end
        end;
        a:close()
    end
end;

function useratc()
    local a = {}
    uat(a)
    luci.http.prepare_content("application/json")
    luci.http.write_json(a)
end;

function uphb(b)
    local a = nixio.fs.access("/etc/config/phonebook.user") and io.popen("cat /etc/config/phonebook.user")
    if a then
        for d in a:lines() do
            local a = d;
            if a then
                b[#b + 1] = {phb = a}
            end
        end;
        a:close()
    end
end;

function userphb()
    local a = {}
    uphb(a)
    luci.http.prepare_content("application/json")
    luci.http.write_json(a)
end;

function load_atcmd()
    local g = require "nixio.fs"
    local h = require "luci.http"
    local i = h.formvalue("modem") or "modem1"
    local j = "/etc/config/atcmds.user." .. i;
    local k = g.readfile(j) or ""
    h.prepare_content("text/plain")
    h.write(k)
end