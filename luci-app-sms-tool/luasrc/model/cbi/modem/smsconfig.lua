local e=require"luci.util"
local t=require"nixio.fs"
local e=require"luci.sys"
local e=require"luci.http"
local e=require"luci.dispatcher"
local e=require"luci.http"
local e=require"luci.sys"
local a=require"luci.model.uci".cursor()
local r="/etc/config/ussd.user"
local h="/etc/config/phonebook.user"
local e="/etc/config/smscommands.user"
local f="/etc/config/atcmds.user"
local w=tostring(a:get("sms_tool","general","smsled"))
local g=tostring(a:get("sms_tool","general","ledtype"))
local e=tostring(a:get("sms_tool","general","checktime"))
local i
local e
local m,c,y,p,n
local b=nixio.fs.glob("/dev/tty[A-Z][A-Z]*")
local v=nixio.fs.glob("/dev/tty[A-Z][A-Z]*")
local l=nixio.fs.glob("/dev/tty[A-Z][A-Z]*")
local u=nixio.fs.glob("/dev/tty[A-Z][A-Z]*")
local d=nixio.fs.glob("/sys/class/leds/*")
local o=tostring(a:get("sms_tool","general","readport"))
local a=tostring(a:get("sms_tool","general","storage"))
local a=luci.util.exec("sms_tool -s"..a.." -d "..o.." status")
local a=string.sub(a,23,27)
local s=string.match(a,'%d+')
i=Map("sms_tool",translate(""),
translate(""))
e=i:section(NamedSection,'general',"sms_tool",""..translate(""))
e.anonymous=true
e:tab("sms",translate("SMS Settings"))
e:tab("ussd",translate("USSD Codes Settings"))
e:tab("at",translate("AT Commands Settings"))
e:tab("info",translate("Notification Settings"))
this_tab="sms"
m=e:taboption(this_tab,Value,"readport",translate("SMS Reading Port"))
if b then
local e
for e in b do
m:value(e,e)
end
end
mem=e:taboption(this_tab,ListValue,"storage",translate("Message storage area"),translate("Messages are stored in a specific location (for example, on the SIM card or modem memory), but other areas may also be available depending on the type of device."))
mem.default="SM"
mem:value("SM",translate("SIM card"))
mem:value("ME",translate("Modem memory"))
mem.rmempty=true
local a=e:taboption(this_tab,Flag,"mergesms",translate("Merge split messages"),translate("Checking this option will make it easier to read the messages, but it will cause a discrepancy in the number of messages shown and received."))
a.rmempty=false
msma=e:taboption(this_tab,ListValue,"algorithm",translate("Merge algorithm"),translate(""))
msma.default="Simple"
msma:value("Simple",translate("Simple (merge without sorting)"))
msma:value("Advanced",translate("Advanced (merges with sorting)"))
msma:depends("mergesms","1")
msma.rmempty=true
msmd=e:taboption(this_tab,ListValue,"direction",translate("Direction of message merging"),translate(""))
msmd.default="Start"
msmd:value("Start",translate("From beginning to end"))
msmd:value("End",translate("From end to beginning"))
msmd:depends("algorithm","Advanced")
msmd.rmempty=true
c=e:taboption(this_tab,Value,"sendport",translate("SMS Sending Port"))
if v then
local e
for e in v do
c:value(e,e)
end
end
local a=e:taboption(this_tab,Value,"pnumber",translate("Prefix Number"),translate("The phone number should be preceded by the country prefix (for Poland it is 48, without '+'). If the number is 5, 4 or 3 characters, it is treated as 'short' and should not be preceded by a country prefix."))
a.rmempty=true
a.default=48
local a=e:taboption(this_tab,Flag,"prefix",translate("Add Prefix to Phone Number"),translate("Automatically add prefix to the phone number field."))
a.rmempty=false
local a=e:taboption(this_tab,Flag,"information",translate("Explanation of number and prefix"),translate("In the tab for sending SMSes, show an explanation of the prefix and the correct phone number."))
a.rmempty=false
local a=e:taboption(this_tab,TextValue,"user_phonebook",translate("User Phonebook"),translate("Each line must have the following format: 'Contact name;Phone number'. Save to file '/etc/config/phonebook.user'."))
a.rows=7
a.rmempty=false
function a.cfgvalue(e,e)
return t.readfile(h)
end
function a.write(a,a,e)
e=e:gsub("\r\n","\n")
t.writefile(h,e)
end
this_taba="ussd"
y=e:taboption(this_taba,Value,"ussdport",translate("USSD Sending Port"))
if l then
local e
for e in l do
y:value(e,e)
end
end
local a=e:taboption(this_taba,Flag,"ussd",translate("Sending USSD Code in plain text"),translate("Send the USSD code in plain text. Command is not being coded to the PDU."))
a.rmempty=false
local a=e:taboption(this_taba,Flag,"pdu",translate("Receive message without PDU decoding"),translate("Receive and display the message without decoding it as a PDU."))
a.rmempty=false
local a=e:taboption(this_taba,TextValue,"user_ussd",translate("User USSD Codes"),translate("Each line must have the following format: 'Code name;Code'. Save to file '/etc/config/ussd.user'."))
a.rows=7
a.rmempty=true
function a.cfgvalue(e,e)
return t.readfile(r)
end
function a.write(a,a,e)
e=e:gsub("\r\n","\n")
t.writefile(r,e)
end
this_tabc="at"
p=e:taboption(this_tabc,Value,"atport",translate("AT Commands Sending Port"))
if u then
local e
for e in u do
p:value(e,e)
end
end
local a=e:taboption(this_tabc,TextValue,"user_at",translate("User AT Commands"),translate("Each line must have the following format: 'AT Command name;AT Command'. Save to file '/etc/config/atcmds.user'."))
a.rows=20
a.rmempty=true
function a.cfgvalue(e,e)
return t.readfile(f)
end
function a.write(a,a,e)
e=e:gsub("\r\n","\n")
t.writefile(f,e)
end
this_tabb="info"
local t=e:taboption(this_tabb,Flag,"lednotify",translate("Notify new messages"),translate("The LED informs about a new message. Before activating this function, please config and save the SMS reading port, time to check SMS inbox and select the notification LED."))
t.rmempty=false
function t.write(a,t,e)
if o~=nil or o~=''then
if(s~=nil and w~=nil)then
if e=='1'then
luci.sys.call("echo "..s.." > /etc/config/sms_count")
luci.sys.call("uci set sms_tool.general.lednotify=".. 1 ..";/etc/init.d/smsled enable;/etc/init.d/smsled start")
luci.sys.call("/sbin/cronsync.sh")
elseif e=='0'then
luci.sys.call("uci set sms_tool.general.lednotify=".. 0 ..";/etc/init.d/smsled stop;/etc/init.d/smsled disable")
if g=='D'then
luci.sys.call("echo 0 > '/sys/class/leds/"..w.."/brightness'")
end
luci.sys.call("/sbin/cronsync.sh")
end
return Flag.write(a,t,e)
end
end
end
local t=e:taboption(this_tabb,Value,"checktime",translate("Check inbox every minute(s)"),translate("Specify how many minutes you want your inbox to be checked."))
t.rmempty=false
t.maxlength=2
t.default=5
function t.validate(t,e)
if(tonumber(e)<60 and tonumber(e)>0)then
return e
end
end
sync=e:taboption(this_tabb,ListValue,"prestart",translate("Restart the inbox checking process every"),translate("The process will restart at the selected time interval. This will eliminate the delay in checking your inbox."))
sync.default="6"
sync:value("4",translate("4h"))
sync:value("6",translate("6h"))
sync:value("8",translate("8h"))
sync:value("12",translate("12h"))
sync.rmempty=true
n=e:taboption(this_tabb,Value,"smsled",translate("Notification LED"),translate("Select the notification LED."))
if d then
local e
local e
for e in d do
local e=e
local e=string.sub(e,17)
n:value(e,e)
end
end
oled=e:taboption(this_tabb,ListValue,"ledtype",translate("The diode is dedicated only to these notifications"),translate("Select 'No' in case the router has only one LED or if the LED is multi-tasking."))
oled.default="D"
oled:value("S",translate("No"))
oled:value("D",translate("Yes"))
oled.rmempty=true
local t=e:taboption(this_tabb,Value,"ledtimeon",translate("Turn on the LED for seconds(s)"),translate("Specify for how long the LED should be on."))
t.rmempty=false
t.maxlength=3
t.default=1
local e=e:taboption(this_tabb,Value,"ledtimeoff",translate("Turn off the LED for seconds(s)"),translate("Specify for how long the LED should be off."))
e.rmempty=false
e.maxlength=3
e.default=5
return i
