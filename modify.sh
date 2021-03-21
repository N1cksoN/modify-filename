#!/bin/bash

#"Made by Shevchenko Mykyta"
#"NR. Albomu: 295461"


#FOR LINUX GNU PLEASE USE SED INSTEAD OF GSED

#<----------HELP---------->
scriptName=`basename $0`

help() 
{
	cat<<EOT 1>&2

    Write a script modify with the following syntax:

        modify [-r] [-l|-u] <dir/file names...>
        modify [-r] <sed pattern> <dir/file names...>
        modify [-h]

    which will modify file names. The script is dedicated to
    lowerizing (-l) file names, uppercasing (-u) 
    file names or internally calling sed command 
    with the given sed pattern which will operate on file names.

    Changes may be done either with recursion (-r) 
    or without it. -h displays this help.

    Write a second script, named modify_examples,
    which will lead the tester of the modify script 
    through the typical, uncommon and even incorrect 
    scenarios of usage of the modify script.
EOT
}


#<----------GET ARGUMENTS---------->

getArgs() {
    for (( i=0; i<${#all_args[*]}; i++ )); do
        if [ ${all_args[i]} != '-r' ] && [ ${all_args[i]} != '-u' ] && [ ${all_args[i]} != '-l' ]; then
            if [ -f ${all_args[i]} ] || [ -d ${all_args[i]} ]; then #if its file or dir
                args[0]=${all_args[i]}; #storing path
            elif [[ -n ${all_args[i]} ]]; then
                args[1]=${all_args[i]}; #storing sed pattern
            fi
        fi
    done            
}


#<----------CHANGING NAMES---------->

changeName() {
  old_path=$(dirname "$1")/$(basename "$1");
  if [[ ${param[1]} == u ]]; then
    change_base=`echo $(basename "$1") |tr '[:lower:]' '[:upper:]'`;
  else
    change_base=`echo $(basename "$1") |tr '[:upper:]' '[:lower:]'`;
  fi
  new_path=$(dirname "$1")/$change_base;
  #change name
  mv -f "$old_path" "$new_path";
}

changeAllNames() { #$1 -> path
  echo "Changing names for path: $1";
  find $1 -maxdepth 1 -type f |while read i; do
    changeName "$i";
  done
}

changeAllNamesWithRecursion() {
    echo "Changing names with recursion for path: $1";
    find $1 -type f |while read i; do
        changeName "$i";
    done
}

changeAllSedNames() {
    echo "Changing names with sed pattern for path: $1";
    find $1 -maxdepth 1 -type f |while read i; do
        #FOR LINUX GNU PLEASE USE SED INSTEAD OF GSED
        #gsed -i $sed_pattern $1;
        gsed -s $2;
    done
}

changeAllSedNamesWithRecursion() {
    echo "Changing names with sed using recursion for path: $1";
    find $1 -type f |while read i; do
        #FOR LINUX GNU PLEASE USE SED INSTEAD OF GSED
        gsed -s $2;
        #gsed -i $sed_pattern $1;
    done
}



#<----------EXECUTION---------->

executionOption() {
  if [[ ${#args[*]} == 0 ]]; then
    #option and no arguments
    changeAllNames $PWD; 
  else
    if test "${args[0]+isset}" ; then
      changeAllNames ${args[0]};
    else
      echo "ERROR --> there is an argument and not a path";
      exit;
    fi
  fi
}

executionOptionWithRecursion() {
    if [[ ${#args[*]} == 0 ]]; then
        changeAllNamesWithRecursion $PWD;
    else
        if test "${args[0]+isset}"; then
            changeAllNamesWithRecursion ${args[0]};
        else
            echo "ERROR --> give path not sed";
            exit;
        fi
    fi
}

executionSed() {
    if [[ ${#args[*]} == 0 ]]; then
        echo "There is no parameters and no arguments";
        exit;
    fi 

    if [[ ${#args[*]} == 1 ]]; then
        if test "${args[1]+isset}"; then
            echo "Should perform sed pattern in current dir: ${args[*]}";
            changeAllSedNames $PWD ${args[1]};
        else 
            echo "ERROR --> give sed pattern not ${args[0]}";
            exit;
        fi
    fi

    if [[ ${#args[*]} == 2 ]]; then 
        changeAllSedNames ${args[0]} ${args[1]};
    fi   
}

executionSedWithRecursion() { #no parameters
  if [[ ${#args[*]} == 0 ]]; then
    echo "There is no parameters and no arguments";
    exit;
  fi

  if [[ ${#args[*]} == 1 ]]; then #need to perform sed pattern in current directory
    if test "${args[1]+isset}" ; then
      changeAllSedNamesWithRecursion $PWD ${args[1]};
    else
      echo "ERROR --> give sed pattern not ${args[0]}";
      exit;
    fi
  fi

  if [[ ${#args[*]} == 2 ]]; then #need sed pattern and path to perform
    changeAllSedNamesWithRecursion ${args[0]} ${args[1]};
  fi
}

#<----------GET PARAMETERS---------->
args=();
param=( false false );

while getopts "hrlu" opts; do
    case "${opts}" in
        \?)
            echo "Wrong params. Please use [-r] [-l|-u] instead.";
            exit
            ;;
        h) 
            help;
            exit
            ;;
        r)
            param[0]='r';
            ;;
        l)
            param[1]='l';
            ;;
        u)
            param[1]='u';
            ;;  
        # s)
        #    param[0]='s';
        #    ;;  
    esac
done

all_args=($*);
getArgs;

#<----------MAIN PART---------->

if [ ${param[0]} == false ] && [ ${param[1]} == false ]; then
  #no parameters
  executionSed;
elif [ ${param[0]} != false ] && [ ${param[1]} != false ]; then
  #two parameters
  executionOptionWithRecursion;
else
  #one parameter
  if [ ${param[0]} == r ]; then
    #recursion
    executionSedWithRecursion;
  else
    #option
    executionOption;
  fi
fi
