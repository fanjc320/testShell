#!/bin/bash

let etcd=`ls -l /etc|grep "^d"|wc -l` #文件夹个数
let etcf=`ls -l /etc|grep "^-"|wc -l` #文件个数
let sum=$[$etcd+$etcf]
echo sum:$sum
