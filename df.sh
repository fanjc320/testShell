#!/bin/bash

number=`df|grep '^/dev'|tr -s " " " "|cut -d" " -f5|tr -s "%" " "|sort -n|tial -n1`
