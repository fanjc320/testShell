#!/bin/bash

#巧妙使用tr做数字相加操作：

echo 1 2 3 4 5 6 7 8 9 | xargs -n1 | echo $[ $(tr '\n' '+') 0 ]
