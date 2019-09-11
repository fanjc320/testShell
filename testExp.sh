#!/bin/bash

set timeout 60
set host 192.168.60.225
set name mlbc
set password mlbc2019

spawn ssh $host -l $name

expect{
    "(yes/no)?"{
        send "yes\n"
        expect "assword:"
        send "$password\n"
    }

    "assword:"{
        send "$password\n"
        }
}
expect "#"

send "uname\n"
expect "mlbc"
send_ser "Now you can do some operation on this terminal\n"
Interact

