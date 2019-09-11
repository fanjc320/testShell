#!/usr/bin/expect
spawn ssh mlbc@192.168.60.225
expect "*password:"
send "mlbc2019\r"
#expect "*#"
interact

