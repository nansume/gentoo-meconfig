declare MKDIR="mkdir"

MKDIR=(`PATH="/opt/bin:${PATH}" type -P ${MKDIR}`) &&

        ! . testelf ${MKDIR} &&

mkdir() { . "/opt/bin/mkdir" $@;}
#declare -fx mkdir


MKDIR_S=${MKDIR}  #MKDIR_S=${MKDIR/#/. } - nowork: IFS=$'\n ${MKDIR} dir/

declare -p MKDIR_S