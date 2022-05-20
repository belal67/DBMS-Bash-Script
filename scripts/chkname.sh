#!/bin/bash

#check if lenth of string is zero
if [ -z $1 ] ;then
    echo 2
elif [[ $1 =~ ^[a-zAZ09]+ ]] ;then
    if [[ ! $1 =~ ['!@#$%^&*/\?()-;:.,<>{}،؛÷+']+ ]] ;then
        echo 0
    else
        echo 1
    fi 
else
    echo 1
fi