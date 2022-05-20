#!/bin/bash

dbname=$1

createTableFiles(){
    dbname=$1
    tname=$2

    if [ ! -f /home/$USER/project/databases/$dbname/$tname ] ;then
        touch /home/$USER/project/databases/$dbname/$tname
        touch /home/$USER/project/databases/$dbname/"$tname.type"
        chmod a+wrx /home/$USER/project/databases/$dbname/$tname
        chmod a+wrx /home/$USER/project/databases/$dbname/"$tname.type"
        echo "----------------------Table has been created successfully"----------------------

    #else
    #    echo Table name already exist, please enter another name
    #   createTable $dbname $tname
    fi

}

setRecords(){
    dbname=$1
    tname=$2
    colNum=$3
    i=0
            record=""
        colDType=""
    while [ $i -lt $colNum ] 
    do

        if [ $i -eq 0 ] ;then
            echo "First column must be PRIMARY KEY."
        fi
        read -p "Enter Column Name #$((i+1)): " colName
        checkname=$(/home/$USER/project/scripts/chkname.sh $colName)
        if [ $checkname -eq 0 ] ;then
            select dtype in "int" "varchar"
            do
                #echo "Choise the DataType number: "
                colDType=$dtype
                break
            done
        elif [ $checkname -eq 1 ] ;then
            echo "Wrong Column name format."
            setRecords $dbname $tname $colNum
            return 0
        elif [ $checkname -eq 2 ] ;then
            echo "You didn't enter any thing, Please enter a name"
            setRecords $dbname $tname $colNum
            return 0
        fi
        i=$((i+1))
        if [ -z $colDType ] ;then
            #set column data type by default varchar if the user choosed wrong number 
            colDType="varchar"
        fi
        record+="${colName}:${colDType}\n"
        #echo "record is: $record"
    done
        #create table files in case of all data is true only.
        createTableFiles $dbname $tname
        #The \n escape sequence indicates a line feed. 
        #Passing the -e argument to echo enables interpretation of escape sequences.
        echo -e $record >> /home/$USER/project/databases/$dbname/"$tname.type"


}

tableFormat(){
    dbname=$1
    tname=$2
    read -p "Enter the number of columns: " colNum
    chkIsNum=$(/home/$USER/project/scripts/chkint.sh $colNum)
    if [ $chkIsNum -eq 0 ] ;then
        setRecords $dbname $tname $colNum
    elif [ $chkIsNum -eq 1 ] ;then
        echo "Please Enter Numbers only"
        tableFormat $dbname $tname 
    elif [ $chkIsNum -eq 2 ] ;then
        echo "You didn't enter any thing, Please enter a number"
        tableFormat $dbname $tname 

    fi
}

createTable(){
    dbname=$1
    echo  $'\n' ------------------------------Create Table------------------------------ $'\n' 
    echo "-------------------------------------------------------------------------"
    read -p "Enter table name: " tname
    checkname=$(/home/$USER/project/scripts/chkname.sh $tname)
    if [ $checkname -eq 0 ] ;then
        #check is this table name is already exist.
        #cat /home/$USER/project/scripts/databases/$dbname/$tname 2>/dev/null
        if [ -f /home/$USER/project/databases/$dbname/$tname ] ;then
            echo "This table name is Exist..."
            createTable $dbname
            return 0
        else
            tableFormat $dbname $tname
            return 0
        fi
        tableFormat $dbname $tname
    elif [ $checkname -eq 1 ] ;then
        echo wrong table name format
        createTable $dbname
        return 0 
    elif [ $checkname -eq 2 ] ;then
        echo "You didn't enter any thing, Please enter a name"
        createTable $dbname
        return 0
    fi

}

createTable $dbname
