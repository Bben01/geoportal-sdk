#!/bin/bash

# -- option de nettoyage du répertoire
# par defaut, on ne le nettoie pas...
clean=false

##########
# doCmd()

doCmd () {
    cmd2issue=$1
    eval ${cmd2issue}
    retour=$?
    if [ $retour -ne 0 ] ; then
        printTo "Erreur d'execution (code:${retour}) !..."
        exit 100
    fi
}

##########
# printTo()

printTo () {
    text=$1
    d=`date`
    echo "[${d}] ${text}"
}

##########
# build()

build () {
    name=$1

    [ ${name} == "2d" ] && {
        main_directory="geoportal-sdk-2d"
    }

    [ ${name} == "3d" ] && {
        main_directory="geoportal-sdk-3d"
    }

    ucname=$(echo "${name}" | tr '[:lower:]' '[:upper:]')

    # binaires
    printTo "> dist/..."
    doCmd "mkdir -p ./${main_directory}/dist/"
    doCmd "cp ../../dist/${name}/*.js ./${main_directory}/dist/"
    doCmd "cp ../../dist/${name}/*.css ./${main_directory}/dist/"

    # sources
    printTo "> src/..."
    doCmd "mkdir -p ./${main_directory}/src/"
    doCmd "cp -r ../../src/Interface/ ./${main_directory}/src/."
    doCmd "cp -r ../../src/Utils/ ./${main_directory}/src/."
    doCmd "cp ../../src/Map.js ./${main_directory}/src/."
    doCmd "cp ../../src/SDK${ucname}.js ./${main_directory}/src/."

    doCmd "cp -r ../../src/OpenLayers/ ./${main_directory}/src/."
    [ ${name} == "3d" ] && {
        doCmd "cp -r ../../src/Itowns/ ./${main_directory}/src/."
    }

    # README & LICENCE & package.json
    printTo "> resources..."
    doCmd "cp ../../README-SDK-${ucname}.md ./${main_directory}/README.md"
    doCmd "cp ../../LICENCE-${ucname}.md ./${main_directory}/LICENCE.md"
    doCmd "cp package-SDK${ucname}.json ./${main_directory}/package.json"

    # npm pack
    printTo "> npm pack..."
    doCmd "cd ./${main_directory}"
    doCmd "npm pack"
    doCmd "cd .."
    doCmd "mv ./${main_directory}/*.tgz ."

    # clean
    if [ ${clean} == true ]
    then
        printTo "> clean..."
        doCmd "rm -rf ./${main_directory}/dist/ ./${main_directory}/src/"
        doCmd "rm ./${main_directory}/README.md"
        doCmd "rm ./${main_directory}/LICENCE.md"
        doCmd "rm ./${main_directory}/package.json"
        doCmd "rmdir ./${main_directory}/"
    fi
}

################################################################################
# MAIN
################################################################################
printTo "BEGIN"

opts=`getopt -o h --long help,all,2d,3d -n 'build-pack.sh' -- "$@"`
eval set -- "${opts}"

while true; do
    case "$1" in
        -h|--help)
            echo "Usage :"
            echo "    `basename $0` - construction du package TGZ à publier dans NPM"
            echo "    -h            Affiche cette aide."
            echo "    --2d            build : 2D,"
            echo "    --3d            build : 3D,"
            echo "    --all           build : All."
            echo "Par defaut, le repertoire n'est pas supprimé"
            echo "(cf. l'option 'clean=true' dans le code)."
            echo "Le package validé, on se place dans le répertoire pour la publication :"
            echo "  > npm login"
            echo "  > npm publish"
            exit 0
            ;;

        --2d)
            printTo "> Build 2d"
            build "2d"
            shift ;;

        --3d)
            printTo "> Build 3d"
            build "3d"
            shift ;;

        -a|--all)
            printTo "> Build all !"
            build "2d"
            build "3d"
            shift ;;

        --)
            shift
            break
            ;;

        \?)
            printTo "$OPTARG : option invalide : all, 2d, 3d !"
            exit -1
            ;;
   esac
done

printTo "END"
exit 0