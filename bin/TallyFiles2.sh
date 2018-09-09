#!/bin/bash
#
# TallyFiles
#
# Ben Belden

# add functionality for no file argument 

declare recurse=false
declare subd=false
declare zero=false

for arg in "$@" ; do
    if [ $arg == "-r" ] ; then
        recurse=true
    elif [ "$arg" == "-d" ] ; then
        subd=true
    elif [ "$arg" == "-z" ] ; then
        zero=true
    fi
    if [ $arg != "-r" ] && [ $arg != "-d" ] && [ $arg != "-z" ] ; then 
        
        # -r -d -z
        if [ $recurse == true ] && [ $subd == true ] && [ $zero == true ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
            printf "\tdirs: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
            printf "\tzero: %s\n\n" $x
            dirList=$( find $PWD -type d | grep -v ^$PWD$ )
            for dir in $dirList ; do
                cd $dir
                printf "\t%s\n" $dir
                x=$( find $PWD -maxdepth 1 -type f | wc -l )
                printf "\t\tfiles: %s\n" $x
                x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
                printf "\t\tdirs: %s\n" $x
                x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
                printf "\t\tzero: %s\n" $x
                echo
            done
            cd $path
        fi
        
        # -r -d
        if [ $recurse == true ] && [ $subd == true ] && [ $zero == false ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
            printf "\tdirs: %s\n\n" $x
            dirList=$( find $PWD -type d | grep -v ^$PWD$ )
            for dir in $dirList ; do
                cd $dir
                printf "\t%s\n" $dir
                x=$( find $PWD -maxdepth 1 -type f | wc -l )
                printf "\t\tfiles: %s\n" $x
                x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
                printf "\t\tdirs: %s\n" $x
                echo
            done
            cd $path
        fi
        
        # -r -z
        if [ $recurse == true ] && [ $subd == false ] && [ $zero == true ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
            printf "\tzero: %s\n\n" $x
            dirList=$( find $PWD -type d | grep -v ^$PWD$ )
            for dir in $dirList ; do
                cd $dir
                printf "\t%s\n" $dir
                x=$( find $PWD -maxdepth 1 -type f | wc -l )
                printf "\t\tfiles: %s\n" $x
                x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
                printf "\t\tzero: %s\n" $x
                echo
            done
            cd $path
        fi
        
        # -r       
        if [ $recurse == true ] && [ $subd == false ] && [ $zero == false ] ; then 
            path=$PWD
            cd "$arg"
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n\n" $x
            dirList=$( find $PWD -type d | grep -v ^$PWD$ )
            for dir in $dirList ; do
                cd $dir
                printf "\t%s\n" $dir
                x=$( find $PWD -maxdepth 1 -type f | wc -l )
                printf "\t\tfiles: %s\n" $x
                echo
            done
            cd $path
        fi
        
        # -d -z
        if [ $recurse == false ] && [ $subd == true ] && [ $zero == true ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
            printf "\tdirs: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
            printf "\tzero: %s\n" $x
            cd $path
        fi
        
        # -d
        if [ $recurse == false ] && [ $subd == true ] && [ $zero == false ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type d | grep -v ^$PWD$ | wc -l )
            printf "\tdirs: %s\n" $x
            cd $path
        fi

        # -z 
        if [ $recurse == false ] && [ $subd == false ] && [ $zero == true ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            x=$( find $PWD -maxdepth 1 -type f -size 0 | wc -l )
            printf "\tzero: %s\n" $x
            cd $path
        fi
       
        # no options
        if [ $recurse == false ] && [ $subd == false ] && [ $zero == false ] ; then 
            path=$PWD
            cd $arg
            printf "%s/\n" $arg
            x=$( find $PWD -maxdepth 1 -type f | wc -l )
            printf "\tfiles: %s\n" $x
            cd $path
        fi
        echo
    fi
done

exit 0

