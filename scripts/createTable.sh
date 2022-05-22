#!/bin/bash

dbname=$1
colDType=""
createTableFiles() {
    dbname=$1
    tname=$2

    if [ ! -f /home/$USER/project/databases/$dbname/$tname ]; then
        touch /home/$USER/project/databases/$dbname/$tname
        touch /home/$USER/project/databases/$dbname/"$tname.type"
        chmod 755 /home/$USER/project/databases/$dbname/*
        echo "------$(tput setaf 1)$(tput setab 7)Table has been created successfully$(tput sgr 0)-----"
    fi

}

#check the data type of the each column and enforce user to chose from select[int,varchar]
selectDType() {
    select dtype in "int" "varchar"; do
        case $REPLY in
        1)
            colDType=$dtype
            break
            ;;
        2)
            colDType=$dtype
            break
            ;;
        *)
            echo "Please enter one of these options."
            selectDType
            return
            ;;
        esac
    done

}

checkUniqueColName() {
    i=$1
    records=$2
    if [ $i -eq 0 ]; then
        echo "$(tput setaf 1)$(tput setab 7)First column must be PRIMARY KEY.$(tput sgr 0)"
    fi
    read -p "Enter Column Name #$((i + 1)): " colName
    checkname=$(/home/$USER/project/scripts/chkname.sh $colName)
    if [ $checkname -eq 0 ]; then
        if [ $i -gt 0 ]; then
            #check if the column name is unique.
            result=$(echo -e $records | awk -v tmp=$colName -F: '{
                    if(tmp == $1) 
                    {
                        print $1;
                        exit;
                    }
                }')
            if [ ! -z $result ]; then
                echo "$(tput setaf 1)$(tput setab 7)column name is not unique, please enter a different column name.$(tput sgr 0)"
                checkUniqueColName $i $records
                return
            fi
        fi
        selectDType
    elif [ $checkname -eq 1 ]; then
        echo "$(tput setaf 1)$(tput setab 7)Wrong Column name format.$(tput sgr 0)"
        checkUniqueColName $i $records
        return 0
    elif [ $checkname -eq 2 ]; then
        echo "$(tput setaf 1)$(tput setab 7)You didn't enter any thing, Please enter a name$(tput sgr 0)"
        checkUniqueColName $i $records
        return 0
    fi
}

setRecords() {
    dbname=$1
    tname=$2
    colNum=$3
    i=0
    record=""
    colDType=""
    while [ $i -lt $colNum ]; do

        checkUniqueColName $i $record
        i=$((i + 1))
        record+="${colName}:${colDType}\n"
    done
    #create table files in case of all data is true only.
    createTableFiles $dbname $tname
    #The \n escape sequence indicates a line feed.
    #Passing the -e argument to echo enables interpretation of escape sequences.
    echo -e $record >>/home/$USER/project/databases/$dbname/"$tname.type"

}

tableFormat() {
    dbname=$1
    tname=$2
    read -p "Enter the number of columns: " colNum
    chkIsNum=$(/home/$USER/project/scripts/chkint.sh $colNum)
    if [ $chkIsNum -eq 0 ]; then
        setRecords $dbname $tname $colNum
    elif [ $chkIsNum -eq 1 ]; then
        echo "$(tput setaf 1)$(tput setab 7)Please Enter Numbers only$(tput sgr 0)"
        tableFormat $dbname $tname
        return 0
    elif [ $chkIsNum -eq 2 ]; then
        echo "$(tput setaf 1)$(tput setab 7)You didn't enter any thing, Please enter a number$(tput sgr 0)"
        tableFormat $dbname $tname
        return 0
    fi
}

createTable() {
    dbname=$1
    echo "----------$(tput setaf 1)$(tput setab 7)Create Table$(tput sgr 0)----------"
    echo "-----------------------------------------------------"
    read -p "Enter table name: " tname
    checkname=$(/home/$USER/project/scripts/chkname.sh $tname)
    if [ $checkname -eq 0 ]; then
        #check is this table name is already exist.
        #cat /home/$USER/project/scripts/databases/$dbname/$tname 2>/dev/null
        if [ -f /home/$USER/project/databases/$dbname/$tname ]; then
            echo "$(tput setaf 1)$(tput setab 7)This table name is Exist...$(tput sgr 0)"
            createTable $dbname
            return 0
        else
            tableFormat $dbname $tname
            return 0
        fi
        tableFormat $dbname $tname
    elif [ $checkname -eq 1 ]; then
        echo "$(tput setaf 1)$(tput setab 7)wrong table name format$(tput sgr 0)"
        createTable $dbname
        return 0
    elif [ $checkname -eq 2 ]; then
        echo "$(tput setaf 1)$(tput setab 7)You didn't enter any thing, Please enter a name$(tput sgr 0)"
        createTable $dbname
        return 0
    fi

}

createTable $dbname
