#!/bin/bash

shopt -s extglob

alias ..='cd ..'
alias -- -='cd -'
alias grep='grep --color'
alias grepr='grep --exclude-dir .svn --exclude-dir=build  --exclude=./tags --color -RIn'
alias l='ls -alFv --color=auto'
alias ll='ls -lv --color=auto'
alias ll.='ls -lv --color=auto -d .*'
alias lh='l -h'
alias rz='rz -by'
alias sz='sz -by'
alias tcpdumpx='tcpdump -nn -N -l -B 5000'
alias tcpdumpxe='tcpdump -nn -N -l -B 5000 -i eth0'
alias tcpdumpxb='tcpdump -nn -N -l -B 5000 -i bond1'
alias p='ps -ef'
alias gr='grep'
alias pg='ps -ef | grep'
alias uniqx='sort | uniq'
alias uniqc='sort | uniq -c'
alias uniqcn='sort | uniq -c | sort -n'
alias awss3='aws --endpoint-url=https://s3-api.us-geo.objectstorage.service.networklayer.com s3'
alias cdlog='cd $(pwd | sed "s/app/applog/")'
alias cdapp='cd $(pwd | sed "s/applog/app/")'
alias cdutil='cd /usr/local/mfw/include/util'
alias cdredis='cd /usr/local/mfw/include/redis'

alias cdtools='cd /data/tools/script/'
alias cdbackup='cd /data/version_backup'
alias lspackge='ls /data/version_backup/'
alias cdmfwsynclog='cd /data/app/mfw/mfwsynclog'
alias cdremote='cd /data/remote_log/MLBC'

alias ..='cd ..'
alias grep='grep --exclude-dir .svn --exclude-dir=build  --exclude=tags --color'
alias grepr='grep --exclude-dir .svn --exclude-dir=build  --exclude=tags --color -RIn'
alias l='ls -alF --color=auto'
alias ll='ls -l --color=auto'
alias ll.='ls -l --color=auto -d .*'
alias llh='ll -h | sort -k5 -h'
alias vi='vim'
alias ssh='ssh -p 22'
alias scp='scp -P 22'

alias du='du --max=1 -h | sort -hr'

alias r='./cc_release_server.sh'
alias rlog='./cc_release_log.sh'

alias u='./upload_cc_server.sh'
alias uconfig='./upload_cc_config.sh'
alias utool='./upload_cc_tools.sh'

export PS1='[\u@\h:\w]\$ '

# TOOLSFUNC_LEVEL未设置或者为空，初始化为1
if [[ ${TOOLSFUNC_LEVEL:+x} == "" ]]; then
    export TOOLSFUNC_LEVEL=1
fi

# SSH_GETPWD未设置时初始化(如果已经设置为空就不处理)
# 当BASH_SOURCE设置且不为空，设置SSH_GETPWD为相同目录下的脚本
#echo bash_source ${BASH_SOURCE}
#echo dir bash_source $(dirname ${BASH_SOURCE[0]})
#echo "SSH_GETPWD+x ${SSH_GETPWD+x}

if [[ ${SSH_GETPWD+x} == "" && ${BASH_SOURCE[0]:+x} != "" && -x $(dirname ${BASH_SOURCE[0]})/ssh_getpwd.sh ]]; then
    export SSH_GETPWD=$(dirname $(readlink -f ${BASH_SOURCE[0]}))/ssh_getpwd.sh
fi

echo "flag ---0--- "${TOOLS_CONFIG+x}
echo "flag ---1--- "${BASH_SOURCE[0]:+x}
#export -n TOOLS_CONFIG

if [[  ${TOOLS_CONFIG+x} == "" && ${BASH_SOURCE[0]:+x} != "" && -f $(dirname ${BASH_SOURCE[0]})/toolsconfig.txt ]]; then
    export TOOLS_CONFIG=$(dirname $(readlink -f ${BASH_SOURCE[0]}))/toolsconfig.txt

    echo "flag ---00--- "${TOOLS_CONFIG}
    echo "flag ---11--- "${BASH_SOURCE[0]}
fi

export TOOLS_CONFIG=toolsconfig.txt

echo "flag ---22--- "${TOOLS_CONFIG}

# BASH_SOURCE设置且不为空，从本地读取文件内容
if [[ ${BASH_SOURCE[0]:+x} != "" ]]; then
    function get_toolsfunc_content()
    {
        cat ${BASH_SOURCE[0]} 2>/dev/null
    }
    function get_sshgetpwd_content()
    {
        cat "$SSH_GETPWD" 2>/dev/null
    }
    function get_toolsconfig_content()
    {
        echo "$funcname=gettoolscontent=begin=called=====" >&2
        cat "$TOOLS_CONFIG" 2>/dev/null
        #echo "$funcname=gettoolscontent=end=called=====" >&2
    }
fi

function get_toolsfunc_curr_backtrace()
{
    echo "$(whoami)@$(showip one):$(pwd)"
}

function get_toolsfunc_export_script_base64()
{
    (
    echo "function get_toolsfunc_content() { echo '$(get_toolsfunc_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
    echo "function get_sshgetpwd_content() { echo '$(get_sshgetpwd_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
    echo "function get_toolsconfig_content() { echo '$(get_toolsconfig_content | gzip -c | base64)' | base64 -d | gzip -dc; }"
    echo "export TOOLSFUNC_LEVEL=$((TOOLSFUNC_LEVEL + 1))"
    echo "export TOOLSFUNC_BACKTRACE=(${TOOLSFUNC_BACKTRACE[@]} '$(get_toolsfunc_curr_backtrace)')"
    if [[ ${SSH_PWD+x} != "" ]]; then
        echo "export SSH_PWD='$SSH_PWD'"
    fi
    cat <<'EOF'
eval "$(get_toolsfunc_content)"
unset TOOLSFUNC_IMPORT_SCRIPT
[[ $(history | wc -l) -gt 0 ]] && history -d $(( $(history | tail -1 | awk '{print $1}') ))
EOF
    ) | gzip -c | base64
}

function get_toolsfunc_export_script()
{
    cat <<EOF
export TOOLSFUNC_IMPORT_SCRIPT='eval "\$(echo "$(get_toolsfunc_export_script_base64)" | base64 -d | gzip -dc )"'
EOF
}

function get_toolsfunc_import_script()
{
    cat <<EOF
eval "\$TOOLSFUNC_IMPORT_SCRIPT"
EOF
}

function show_toolsfunc_info()
{
    echo "SSH_PWD: $SSH_PWD"
    echo "SSH_GETPWD: $SSH_GETPWD"
    echo "SSH_OPT: $SSH_OPT"
    echo "SCP_OPT: $SCP_OPT"
}

function get_toolsfunc_filename()
{
    if [[ ${BASH_SOURCE[0]} != "" ]]; then
        echo $(readlink -f ${BASH_SOURCE[0]})
    fi
}

#####################################################################

function confirm()
{
    local msg=$1
    local prompt
    if [[ $msg == "" ]]; then
        msg="confirm"
    fi
    while true; do
        echo -ne "$msg [y/n] "
        read -n 1 -r prompt
        echo
        if [[ $prompt == 'y' || $prompt == 'Y' ]]; then
            return 0
        elif [[ $prompt == 'n' || $prompt == 'N' ]]; then
            return 1
        fi
    done
}

function listargs()
{
    echo "args num: $#"
    local n=0
    for arg in "$@"; do
        echo "arg $((++n)): $arg"
    done
}

function skiparg()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME args..."
        return 1
    fi

    local n=0
    while [[ $# -gt 0 ]]; do
        if [[ $1 == "--" ]]; then
            n=$((n + 1))
            break
        elif [[ ${1:0:2} == "--" ]]; then
            n=$((n + 1))
            if [[ $# -ge 2 ]]; then
                n=$((n + 1))
                shift
            fi
        elif [[ ${1:0:1} == "-" ]]; then
            n=$((n + 1))
            if [[ ${1:2} == "" && $# -ge 2 ]]; then
                n=$((n + 1))
                shift
            fi
        else
            break
        fi
        shift
    done
    echo $n
}

function isdigit()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME str [str ...]" >&2
        return 1
    fi
    
    local yes=1
    while [[ $# -gt 0 ]]; do
        if [[ ! "$1" =~ ^[[:digit:]]+$ ]]; then
            yes=0
            break
        fi
        shift
    done
    echo $yes
}

function isxdigit()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME str [str ...]" >&2
        return 1
    fi
    
    local yes=1
    while [[ $# -gt 0 ]]; do
        if [[ ! "$1" =~ ^[[:xdigit:]]+$ ]]; then
            yes=0
            break
        fi
        shift
    done
    echo $yes
}

function isinteger()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME str [str ...]" >&2
        return 1
    fi
    
    local yes=1
    while [[ $# -gt 0 ]]; do
        if [[ ! "$1" =~ ^-?[[:digit:]]+$ ]]; then
            yes=0
            break
        fi
        shift
    done
    echo $yes
}

function isset()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME with_empty var [var ...]" >&2
        return 1
    fi
    
    local with_empty=$1
    shift
    
    if [[ $with_empty == "1" ]]; then
        while [[ $# -gt 0 ]]; do
            if [[ ${!1+x} == "" ]]; then
                return 1
            fi
            shift
        done
    else
        while [[ $# -gt 0 ]]; do
            if [[ ${!1:+x} == "" ]]; then
                return 1
            fi
            shift
        done
    fi
    return 0
}

function timestr()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME timedesc [mofidification] [format]" >&2
        echo "    Example: $FUNCNAME 20150906 '1 day -1 sec'" >&2
        return 1
    fi
    
    local desc=$1
    local modify=$2
    local format=${3:-%Y-%m-%d %H:%M:%S}
    
    if [[ "$modify" == "" ]]; then
        date -d "$desc" +"$format"
    else
        local t=$(date -d "$desc" +'%Y-%m-%d %H:%M:%S')
        date -d "$t $modify" +"$format"
    fi
}

function timeseq()
{
    if [[ $# -lt 3 ]]; then
        echo "Usage: $FUNCNAME from to incr [time format]" >&2
        return 1
    fi
    
    local from=$(date -d "$1" +%s)
    local to=$(date -d "$2" +%s)
    local incr=$3
    local format=${4:-%Y-%m-%d %H:%M:%S}
    
    if [[ $from -eq $to ]]; then
        timestr "@$from" "" "$format"
        return 0
    fi
    
    local next=$(timestr "@$from" "$incr" "%s")
    if [[ $from -le $to ]]; then
        if [[ $next -le $from ]]; then
            echo "Error: $(timestr @$from) -> $(timestr @$to) with backward increment '$incr'"
            return 1
        fi
        
        for ((t = $from; t <= $to; t = $(timestr "@$t" "$incr" "%s") )); do
            timestr "@$t" "" "$format"
        done
    else
        if [[ $next -ge $from ]]; then
            echo "Error: $(timestr @$from) -> $(timestr @$to) with forward increment '$incr'"
            return 1
        fi
        
        for ((t = $from; t >= $to; t = $(timestr "@$t" "$incr" "%s") )); do
            timestr "@$t" "" "$format"
        done
    fi
}

function dateseq()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME from to [incr] [format]" >&2
        return 1
    fi
    
    local from=$(date -d "$1" +%Y%m%d)
    local to=$(date -d "$2" +%Y%m%d)
    local incr=$3
    local format=${4:-%Y%m%d}
    
    if [[ "$incr" == "" ]]; then
        if [[ $from -le $to ]]; then
            incr="1 day"
        else
            incr="1 day ago"
        fi
    fi
    
    timeseq "$from" "$to" "$incr" "$format"
}

function ts()
{
    if [[ $# -eq 0 ]]; then
        set -- now
    fi
    if [[ $1 == '-h' ]]; then
        echo "Usage: $FUNCNAME timedesc|timestamp ..." >&2
        return 1
    fi
    
    local in
    local out
    while [[ $# -ne 0 ]]; do
        in=$1
        shift

        if [[ $(echo "$in" | sed '/^ *[0-9][0-9]* *$/!d' | wc -l) -eq 1 ]]; then
            in=$(echo "$in" | sed 's/ //g')
            if [[ ${#in} -le 10 ]]; then
                out=$(date +'%Y-%m-%d %H:%M:%S' -d "@$in")
            else
                local mill=${in:$((${#in} - 3))}
                local sec=${in:0:$((${#in} - 3))}
                out=$(date +'%Y-%m-%d %H:%M:%S'.$mill -d "@$sec");
            fi
        else
            out=$(date +'%Y-%m-%d %H:%M:%S' -d "$in")" => "$(date +%s -d "$in")
        fi

        echo "$in => $out"
    done
}

function catlog()
{
    local err=0
    local sep='|'
    
    if [[ $# -gt 0 && ${1:0:2} == '-F' ]]; then
        if [[ ${1:2} != "" ]]; then
            sep=${1:2}
            shift
        elif [[ $# -gt 1 ]]; then
            sep=$2
            shift 2
        else
            err=1
        fi
    fi
    if [[ $err -eq 1 || $# -gt 1 || ($# -eq 1 && $(isdigit "$1") -eq 0 ) ]]; then
        echo "Usage: $FUNCNAME [-F sep] [column]" >&2
        return 1
    fi
    
    local col=${1:-80}
    col=$((col+0))
    
    local num=0
    while read line; do
        num=$((++num))
        if [[ $num -gt 1 ]]; then
            echo "-------------------";
        fi
        
        if [[ $col -eq 0 ]]; then
            echo "$line" | tr "$sep" '\n' | cat -n
        else
            echo "$line" | tr "$sep" '\n' | sed 's/\(.\{'$col'\}\).*/\1 .../g' | cat -n
        fi
    done
}

function desclog()
{
    head -n 1 | catlog "$@"
}

function collog()
{
    if [[ $# -ne 0 ]]; then
        awkf "$@" | column -t -s '|'
    else
        column -t -s '|'
    fi
}

function difftimelog()
{
    awk -F'|' '{
  ts=mktime(gensub(/[-:]/, " ", "g", $1)); 
  ms=gensub(/^[^.]*[.]*/, "", "g", $1); 
  ms = ts * 1000 + ms * 1;
  diff = 0;
  if (lastms != "") {
    diff = ms - lastms;
  }
  lastms = ms;
  diff = sprintf("%8.3f", diff / 1000);
  print diff"|"$0;
}'
}

function awkx()
{
    local err=0
    local sep=
    local fields=
    local fieldarr=()
    while [[ $# -gt 0 ]]; do
        if [[ ${1:0:2} == '-F' ]]; then
            if [[ ${1:2} != "" ]]; then
                sep=${1:2}
            elif [[ $# -gt 1 ]]; then
                sep=$2
                shift
            else
                err=1
                break
            fi
        else
            local range=$(echo "$1" | awk '
                function pfield(i, n) {
                    if (i != 0)
                        printf(" ");
                    printf("%s", n);
                }
                {
                    if (match($0, /^([-]?[0-9]+)-([-]?[0-9]+)$/, arr)) {
                        if (arr[1] <= arr[2]) {
                            for (n = arr[1]; n <= arr[2]; ++n) {
                                pfield(i, n);
                                ++i;
                            }
                        } else {
                            for (n = arr[1]; n >= arr[2]; --n) {
                                pfield(i, n);
                                ++i;
                            }
                        }
                    } else {
                        pfield(0, $0);
                    }
                    printf("\n");
                }')
            fieldarr=("${fieldarr[@]}" $range)
        fi
        shift
    done

    if [[ $err -eq 1 || ${#fieldarr} -eq 0 || $(isinteger "${fieldarr[@]}") -eq 0 ]]; then
        echo "Usage: $FUNCNAME [-F sep] field ... (-n for reverse order, x-y for range)" >&2
        return 1
    fi
    
    for f in "${fieldarr[@]}"; do
        if [[ $fields != "" ]]; then
            fields="$fields, "
        fi
        if [[ $f -ge 0 ]]; then
            fields="$fields\$$f"
        else
            fields="$fields((NF$f+1)>0?\$(NF$f+1):\"\")"
        fi
    done
    
    if [[ $sep != "" ]]; then
        awk -F"$sep" "BEGIN{OFS=FS} {print $fields}"
    else
        awk "{print $fields}"
    fi
}

function awkf()
{
    awkx -F'|' "$@"
}

function joinstr()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME delim [str]..." >&2
        return 1
    fi
    
    local delim=$1
    shift
    
    local n=0
    local res=''
    while [[ $# -gt 0 ]]; do
        if [[ $((++n)) -ne 1 ]]; then
            res="$res$delim"
        fi
        res="$res$1"
        shift
    done
    echo "$res"
}

function flock_run_nowait()
{
    if [[ $# -ne 2 ]]; then
        echo "Usage: $FUNCNAME lockfile command" >&2
        return 1
    fi
    
    local lockfile=$1
    local command=$2
    (
        flock -xn 200 || { echo "Already running!"; exit 1; }
        eval "$command"
    ) 200>$lockfile
}

function flock_run_wait()
{
    if [[ $# -ne 2 ]]; then
        echo "Usage: $FUNCNAME lockfile command" >&2
        return 1
    fi
    
    local lockfile=$1
    local command=$2
    (
        flock -x 200 || { echo "Lock failed!"; exit 1; }
        eval "$command"
    ) 200>$lockfile
}

function parallel_run()
{
    local arg
    local err=0
    local format="%08s%s"
    local linenum=8
    
    OPTIND=1
    while getopts ':F:n:' arg; do
        case $arg in 
            F) format=$OPTARG ;;
            n) linenum=$OPTARG ;;
            :) err=1 ;; # 选项参数缺失
            \?) OPTIND=$((OPTIND - 1)); break ;; # 未知选项
        esac
    done
    if [[ $OPTIND -gt 1 ]]; then
        shift $((OPTIND - 1))
    fi
    
    if [[ $err -eq 1 || $(isdigit "$linenum") -eq 0 || $# -lt 2 || $(isdigit "$1") -eq 0 ]]; then
        echo "Usage: $FUNCNAME [-F format] [-n linenum] procnum command [command ...]" >&2
        echo "       $FUNCNAME [-F format] [-n linenum] procnum -name command [-name command ...]" >&2
        return 1
    fi
    
    local procnum=$1
    shift
    
    local cmdnum=0
    local cmdlist=()
    local cmdname=()
    local cmdstatus=()
    local cmdinfo=()
    local lastcmdname=
    local timebegin=$(date +%s)
    while [[ $# -gt 0 ]]; do
        if [[ ${1:0:1} == "-" ]]; then
            lastcmdname=${1:1}
        else
            : $((++cmdnum))
            cmdlist=("${cmdlist[@]}" "$1")
            cmdname=("${cmdname[@]}" "${lastcmdname:-cmd-$cmdnum}")
            cmdstatus=("${cmdstatus[@]}" "pending")
            cmdinfo=("${cmdinfo[@]}" "")
            lastcmdname=
        fi
        shift
    done
    if [[ $lastcmdname != "" ]]; then
        echo "missing cmd for $lastcmdname" >&2
        return 1
    fi
    
    (
    local mainpid=$BASHPID
    local fifo=$(mktemp -u)
    mkfifo $fifo
    exec 210<>$fifo
    rm -f $fifo
    
    for ((i = 0; i < cmdnum; ++i)); do
        cat <<EOF
echo "$i running" >&210
(export PARALLEL_RUN_SELF_ID=$i; export PARALLEL_RUN_FIFO_FD=210; export PARALLEL_RUN_MAIN_PID=$mainpid; ${cmdlist[$i]}) >/dev/null 2>&1 && echo "$i finish" >&210 || echo "$i error" >&210
EOF
        echo -ne '\0'
    done | xargs -I{} -0 -P $procnum bash -c {} &
    local xargspid=$!
    trap "if [[ \$(ps h -o comm -p $xargspid) == 'xargs' ]]; then echo; echo -n 'killing xargs: $xargspid'; kill $xargspid; fi" EXIT
    
    PS1=''
    #tput civis
    local fin=0
    local time1=$(date +%s.%N)
    local time2
    local timediff
    while [[ $fin -lt $cmdnum ]]; do
        read -r -t 1 -u 210 id status info
        if [[ $? -eq 0 ]]; then
            cmdstatus[$id]=$status
            if [[ $status == "finish" || $status == "error" ]]; then
                : $((++fin))
            elif [[ $status == "info" ]]; then
                cmdinfo[$id]=$info
            fi
        fi
        
        time2=$(date +%s.%N)
        timediff=$(printf "%.0f" $(echo "($time2 - $time1)*1000" | bc))
        if [[ $fin -ge $cmdnum || $timediff -ge 1000 ]]; then
            time1=$time2

            tput clear; tput cup 0 0;
            local pending_num=0
            local running_num=0
            local finish_num=0
            local error_num=0
            for ((i = 0; i < cmdnum; ++i)); do
                case ${cmdstatus[$i]} in
                    "pending") : $((++pending_num));;
                    "running") : $((++running_num));;
                    "finish") : $((++finish_num));;
                    "error") : $((++error_num));;
                esac
            done
            
            local time_elapsed=$(($(date +%s) - timebegin))
            printf "Pending: %3d   Running: \e[93m%3d\e[0m\n" $pending_num $running_num
            printf " Finish: \e[92m%3d\e[0m     Error: \e[91m%3d\e[0m   Time Elapsed: %3ds\n\n" $finish_num $error_num $time_elapsed
            local color=
            for ((i = 0; i < cmdnum; ++i)); do
                case ${cmdstatus[$i]} in
                    "pending") color="\e[0m";;
                    "running") color="\e[93m";;
                    "finish") color="\e[92m";;
                    "error") color="\e[91m";;
                esac
                printf "${color}$format\e[0m" "${cmdname[$i]}" "${cmdinfo[$i]}"
                if [[ $(((i + 1) % linenum)) -eq 0 ]]; then
                    echo
                fi
            done
            echo
        fi
    done
    #tput cnorm
    )
}

function parallel_info()
{
    if [[ ${PARALLEL_RUN_SELF_ID:+x} == "x" && ${PARALLEL_RUN_FIFO_FD:+x} == "x" ]]; then
        echo "$PARALLEL_RUN_SELF_ID info $@" >&$PARALLEL_RUN_FIFO_FD
    fi
}

function is_parallel_run_alive()
{
    if [[ ${PARALLEL_RUN_MAIN_PID:+x} == "x" && $(ps h -o comm -p $PARALLEL_RUN_MAIN_PID) != "" ]]; then
        return 0
    fi
    return 1
}

function get_sshpwd()
{
    if [[ $1 == '-h' ]]; then
        echo "Usage: $FUNCNAME [host] [user]" >&2
        return 1
    fi
    
    local host=$1
    local user=${2:-root}
    if [[ $host == '' || $host == '.' ]]; then
        host=$(showip one)
    fi
    
    local passwd=$(/bin/bash <(get_sshgetpwd_content) "$host" "$user")
    echo "$user@$host: $passwd"
}

function get_expect_commproc()
{
    local proc=$(cat <<'EOF'
# expect用openpty与spawn出来的进程通信
# pty的一个特性是如果slave关闭了，master会读到-1
# expect使用的tcl库内部对pty读取做了一个缓存，大小为4096，读取时先使用缓存，不足再从pty读取(DoReadChars)
# 结合pty的特性和tcl的缓存，如果expect用掉了tcl的缓存并且还不够，tcl再去读pty时就返回-1，即eof，导致数据丢失(Tcl_ReadChars,DoReadChars,GetInput,ChanRead,ExpInputProc)
# 解决方法时每次都让expect读光tcl的缓存，即读取的大小至少大于tcl缓存，保证读到-1时数据已经被消耗光
# 根据expect算法(match_max * 3 + 1大小每次移除1/3 * use)，最少也要设置为4095(expAdjust, exp_buffer_shuffle)
# 正好pty内核的设置N_TTY_BUF_SIZE=4096，每次read pty最多只返回4095个字节数据，而tcl库对读取会有一次block处理，导致每次返回给expect最多4095字节(ChanRead)
match_max -d 16384;

proc getenv { name } {
    if { [info exists ::env($name) ] } {
        return $::env($name);
    };
    return "";
};

proc setenv { name value } {
    set ::env($name) $value;
};

proc feedpasswd { user host {script ""} } {
    set password "";
    #if { [getenv SSH_GETPWD_FROM_INPUT] != "1" } {
    #   puts "\n[exp_pid] req pwd from level [getenv TOOLSFUNC_LEVEL]";
    #} else {
    #   puts "\n[exp_pid] req pwd from level [getenv TOOLSFUNC_LEVEL], redirect to up level";
    #}; 
    if { [getenv SSH_GETPWD_FROM_INPUT] != "1" } {
        if { $password=="" && [info exists ::env(SSH_GETPWD)] && $::env(SSH_GETPWD)!="" } {
            set password [exec $::env(SSH_GETPWD) $host $user];
        } elseif { $password=="" && $script != "" } {
            set password [exec /bin/bash "$script" $host $user];
        };
        if { $password=="" && [info exists ::env(SSH_PWD)] && $::env(SSH_PWD)!="" } {
            set password $::env(SSH_PWD);
        };
    };
    if { $password=="" } {
        stty -echo;
        expect_user -re "(.*)\n";
        stty echo;
        set password $expect_out(1,string);
    };

    #puts "[exp_pid] rsp pwd $password from level [getenv TOOLSFUNC_LEVEL]";
    send -- "$password\n";
};

proc checkret {} {
    set ret [wait];
    set sysret [lindex $ret 2];
    set progret [lindex $ret 3];
    if {$sysret == 0 && $progret == 0} then {
        exit 0;
    } else {
        exit -1;
    }
};
EOF
)
    echo "$proc"
}

function runcmd()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME host command [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local host=$1
    local command=$2
    shift 2
    
    if [[ $host =~ .*@@.* ]]; then
        host="${host##*@@}@${host%@@*}"
    fi
    
    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set host [lindex $argv 1];
set arguments [lrange $argv 2 end];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];

set stty_init raw;
set timeout 86400;
spawn -noecho /usr/bin/ssh -t -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" -q {*}$arguments $host $command;
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue;
    };
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    };
    eof {};
}
checkret;
EOF
)
    TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$host" $SSH_OPT "$@"
}

function runcmdex()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME host command [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local host=$1
    local command="$(get_toolsfunc_export_script); export SSH_GETPWD_FROM_INPUT=1; $(get_toolsfunc_import_script); $2"
    shift 2
    
    runcmd "$host" "$command" "$@"
}

function runcmdclean()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME host command [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local sep='--------++++++++--------'
    local host=$1
    local command="echo $sep; $2"
    shift 2
    
    if [[ $host =~ .*@@.* ]]; then
        host="${host##*@@}@${host%@@*}"
    fi
    
    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set host [lindex $argv 1];
set arguments [lrange $argv 2 end];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];

set stty_init raw;
set timeout 86400;
spawn -noecho /usr/bin/ssh -t -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" -q {*}$arguments $host $command;
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

set oldflag [getenv SSH_GETPWD_FROM_INPUT];
setenv SSH_GETPWD_FROM_INPUT 0;
expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue;
    };
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    };
    -exact {--------++++++++--------} {
        setenv SSH_GETPWD_FROM_INPUT $oldflag;
        exp_continue;
    }
    eof {};
}
checkret;
EOF
)
    TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$host" $SSH_OPT "$@" | sed '0, /'$sep'/d'
}

function runcmdexclean()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME host command [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local host=$1
    local command="$(get_toolsfunc_export_script); export SSH_GETPWD_FROM_INPUT=1; $(get_toolsfunc_import_script); $2"
    shift 2
    
    runcmdclean "$host" "$command" "$@"
}

function shell()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME host [command] [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local host=$1
    local command=
    if [[ $# -gt 1 && ${2:0:1} != "-" ]]; then
        command=$2
        shift 2
    else
        shift 1
    fi
    
    if [[ $host =~ .*@@.* ]]; then
        host="${host##*@@}@${host%@@*}"
    fi

    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set host [lindex $argv 1];
set arguments [lrange $argv 2 end];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];

set timeout 86400;
spawn -noecho /usr/bin/ssh -t -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" -q {*}$arguments ${host};
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue; 
    }
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    }
    "@" {
        if {$command != ""} {
            send $command; 
            send "\n";
        }
        interact;
    }
    eof {
        send_error "some error occurs, quit ssh ...\n";
    }
}
puts "current toolsfunc shell level: [getenv TOOLSFUNC_LEVEL]";
checkret;
EOF
)
    TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$host" $SSH_OPT "$@"
    local ret=$?
    shellbt
    return $ret
}

function shellex()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME host [command] [ssh options]" >&2
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return 1
    fi
    
    local host=$1
    local initcmd="$(get_toolsfunc_export_script); exec -la bash bash -l; "
    local command="$(get_toolsfunc_import_script); "
    if [[ $# -gt 1 && ${2:0:1} != "-" ]]; then
        command="$command$2"
        shift 2
    else
        shift 1
    fi
    
    if [[ $host =~ .*@@.* ]]; then
        host="${host##*@@}@${host%@@*}"
    fi

    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set host [lindex $argv 1];
set arguments [lrange $argv 2 end];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];
set initcmd [getenv TOOLSFUNC_EXPECTENV_INIT_CMD];

set timeout 86400;
spawn -noecho /usr/bin/ssh -t -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" -q {*}$arguments ${host} $initcmd
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue; 
    }
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    }
    "@" {
        if {$command != ""} {
            send $command; 
            send "\n";
        }
        interact;
    }
    eof {
        send_error "some error occurs, quit ssh ...\n";
    }
}
puts "current toolsfunc shell level: [getenv TOOLSFUNC_LEVEL]";
checkret;
EOF
)
    TOOLSFUNC_EXPECTENV_INIT_CMD="$initcmd" TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$host" $SSH_OPT "$@"
    local ret=$?
    shellbt
    return $ret
}

function scpex()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME from ... to [scp options]"
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return
    fi

    local n=$#
    local idx=0
    local num=0
    while (( n > 0 )); do
        if [[ ${!n:0:1} == '-' ]]; then
            idx=$n
            num=0
        else
            if (( ++num >= 2 )); then
                break
            fi
        fi
        : $((--n))
    done

    local args=()
    if [[ $idx -ne 0 ]]; then
        args=($SCP_OPT "${@:$idx}" "${@:1:$((idx-1))}")
    else
        args=($SCP_OPT "$@")
    fi

    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set arguments [lrange $argv 1 end];

set stty_init raw;
set timeout 86400;
spawn -noecho /usr/bin/scp -o "StrictHostKeyChecking=no" -o "NumberOfPasswordPrompts=1" {*}$arguments;
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue;
    };
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    };
    eof {};
}
checkret;
EOF
)

    /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "${args[@]}"
}

function rsyncex()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME from ... to [rsync options]"
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return
    fi

    local sshprog="/usr/bin/ssh -o 'StrictHostKeyChecking=no' -o 'NumberOfPasswordPrompts=1' $SSH_OPT"
    
    local expectcmd=$(cat <<'EOF'
set sshprog [lindex $argv 0];
set getpwdscript [lindex $argv 1];
set arguments [lrange $argv 2 end];

set stty_init raw;
set timeout 86400
spawn -noecho /usr/bin/rsync -e "$sshprog" -av {*}$arguments
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Are you sure you want to continue connecting (yes/no)" {
        send "yes\n"; 
        exp_continue;
    };
    -re {([a-zA-Z0-9]*)@(.*)'.*assword:} {
        feedpasswd $expect_out(1,string) $expect_out(2,string) $getpwdscript;
        exp_continue; 
    };
    eof {};
}
checkret;
EOF
)

    /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") -- "$sshprog" <(get_sshgetpwd_content) "$@"
}

function suex()
{
    if [[ $1 == "-h" ]]; then
        echo "Usage: $FUNCNAME [user]"
        echo "       set SSH_GETPWD=script for password provider" >&2
        echo "       set SSH_PWD=password for default password" >&2
        return
    fi
    
    local user=$1
    if [[ $user == "" ]]; then
        user=root
    fi
    
    local ip=$(showip one)
    local command="unset SSH_GETPWD; unset SSH_PWD; $(get_toolsfunc_import_script); "
    
    local expectcmd=$(cat <<'EOF'
set getpwdscript [lindex $argv 0];
set user [lindex $argv 1];
set ip [lindex $argv 2];
set command [getenv TOOLSFUNC_EXPECTENV_COMMAND];

set timeout 86400
spawn -noecho /bin/su $user
fconfigure $spawn_id -encoding binary;
fconfigure "exp0" -encoding binary;

expect {
    -exact "Password:" {
        feedpasswd $user $ip $getpwdscript;
        exp_continue;
    };
    "@" {
        if {$command != ""} {
            send $command; 
            send "\n";
        }
        interact;
    };
}
puts "current toolsfunc shell level: [getenv TOOLSFUNC_LEVEL]";
checkret;
EOF
)

    (
    eval "$(get_toolsfunc_export_script)"
    TOOLSFUNC_EXPECTENV_COMMAND="$command" /usr/bin/expect -f <(get_expect_commproc; echo "$expectcmd") <(get_sshgetpwd_content) "$user" "$ip"
    )
}

function getiptype()
{
    if [[ $# -ne 1 ]]; then
        echo "Usage: $FUNCNAME ip" >&2
        return 1
    fi
    
    echo "$1" | awk -F. '{
        if ($1 == "127") print "loopback";
        else if ($1==10 || ($1==192 && $2==168) || ($1==172 && $2>=16 && $2<=31)) print "in";
        else print "out";
    }'
}

function showip()
{
    if [[ $1 == "-h" ]]; then
        echo "Usage: $FUNCNAME [in|out|one|all|interface]" >&2
        return 1
    fi
    if [[ $1 == "one" ]]; then
        local ip=$(showip in | head -1)
        if [[ $ip == "" ]]; then
            ip=$(showip out | head -1)
        fi
        echo "$ip"
        return 0
    fi
    
    local ifs=$(/sbin/ip -4 -o addr show scope global | sed 's|[0-9]*: \([^ \t]*\).*inet \([^/]*\)/.*|\1 \2|g; /^docker/d' | sort -V)
    local ips=$(echo "$ifs" | awk '{print $2}')
    if [[ $# -eq 0 ]]; then
        echo "$ips"
    elif [[ $1 == "in" ]]; then
        echo "$ips" | awk -F. '$1==10 || ($1==192 && $2==168) || ($1==172 && $2>=16 && $2<=31){print}'
    elif [[ $1 == "out" ]]; then
        echo "$ips" | awk -F. '!($1==10 || ($1==192 && $2==168) || ($1==172 && $2>=16 && $2<=31)){print}'
    elif [[ $1 == "all" ]]; then
        echo "$ifs"
    else
        echo "$ifs" | awk -vx="$1" '$1==x{print $2}'
    fi
}

function shellbt()
{
    local n=0;
    for bt in "${TOOLSFUNC_BACKTRACE[@]}"; do
        printf "  %2d: %s\n" $((++n)) "$bt"
    done
    printf "* %2d: %s\n" $((++n)) "$(get_toolsfunc_curr_backtrace)"
}

function get_process_parents()
{
    local pid ppid
    while [[ $# -gt 0 ]]; do
        pid=$1
        shift
        
        while [[ $pid -ne 0 ]]; do
            ppid=$(ps -o ppid= -p $pid)
            if [[ $ppid -ne 0 ]]; then
                echo $ppid
            fi
            pid=$ppid
        done
    done
}

function get_process_childs()
{
    local pid ppid
    while [[ $# -gt 0 ]]; do
        ppid=$1
        shift
        
        if [[ $ppid -ne 0 ]]; then
            for pid in $(ps -o pid= --ppid $ppid); do
                echo $pid
                get_process_childs $pid
            done
        fi
    done
}

function get_process_tree()
{
    local pid
    while [[ $# -gt 0 ]]; do
        pid=$1
        shift
        
        get_process_childs $pid
        echo $pid
        get_process_parents $pid
    done
}

function pstreeex()
{
    local options="--forest --sort=start_time -o user,pid,ppid,lstart,etime,time,args"
    if [[ $# -eq 0 ]]; then
        ps $options -e
    elif [[ $1 == '.' ]]; then
        ps $options -u $(whoami)
    else
        ps $options -p $(get_process_tree "$@")
    fi
}

function psex()
{
    local options="--sort=start_time -o user,pid,ppid,lstart,etime,time,args"
    if [[ $# -eq 0 ]]; then
        ps $options -e
    elif [[ $1 == '.' ]]; then
        ps $options -u $(whoami)
    else
        ps $options "$@"
    fi
}

export PS1='[\u@'"$(showip one)"':\w]\$ '

function s() { shellex "$@"; }
function r() { runcmdex "$@"; }
function sbt() { shellbt "$@"; }

#####################################################################

function mysqlex()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME ip [port] [mysql options]" >&2
        return 1
    fi
    
    local ip=$(getip "$1")
    local port=3306
    shift
    
    if [[ $# -gt 0 && $(isdigit "$1") -eq 1 ]]; then
        port=$1
        shift
    fi
    
    local MYSQL=mysql
    if [[ -x /usr/local/mysql/bin/mysql ]]; then
       MYSQL=/usr/local/mysql/bin/mysql
    fi

    $MYSQL -A -h $ip -P $port -u$MYSQL_USER "$@"
}

function getconfig()
{
    echo getconfig $funcname: @:$@ >&2
    echo getconfig $SELECTED_ENV
    echo "$@" | awk -venv="$SELECTED_ENV" '
    ARGIND==1 {
        count = NF;
        matching = 0;
        find = 0;
        for (i = 1; i <= NF; ++i)
            param[i] = $i;
    }
    ARGIND==2 && $0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ {
        if ($0 !~ /^[[:space:]]*--/) {
            if (!matching) {
                if (find) {
                    exit 0;
                }
                matching = 1;
                find = 0;
            }
            
            if (!find && NF == count) {
                find = 1;
                for (i = 1; i <= count; ++i) {
                    pat = "^("$i")$"
                    if (!match(param[i], pat)) {
                        find = 0;
                        break;
                    }
                }
            }
        } else {
            matching = 0;
            
            if (find) {
                op = gensub(/^[[:space:]]*--/, "", "g", $1);
                if (op ~ /^[a-zA-Z0-9_]+$/) {
                    print gensub(/^[[:space:]]*--/, "", "g", $0);
                } else if (match(op, "^[a-zA-Z0-9_]+\\["env"\\]$")) {
                    print gensub(/^[[:space:]]*--([^[]+)[^[:space:]]+/, "\\1", "g", $0);
                }
            }
        }
    }
    ' - <(get_toolsconfig_content)
}

function getconfig_item()
{
    #printf getconfig_item param:$@
    if [[ $# -lt 3 ]]; then
        echo "Usage: getconfig_item type replace params..."
        return 1
    fi
    
    echo $FUNCNAME $@ >&2
    local type=$1
    local replace=$2
    shift 2
    
    echo $FUNCNAME after shift: $@ replace:$replace >&2
    local temp=$(getconfig "$@")
    echo $FUNCNAME temp1 ${temp} >&2

    if [[ $replace == "" ]]; then
        local tmp=getconfig "$@" | awk -vtype="$type" '$1 == type {pat="^"type"[[:space:]]*"; print gensub(pat, "", 1)}'
        echo $funcname tmp ${tmp} >&2
        getconfig "$@" | awk -vtype="$type" '$1 == type {pat="^"type"[[:space:]]*"; print gensub(pat, "", 1)}'
    else
        local tmp=getconfig "$@" | awk -vtype="$type" -vreplace="$replace" '$1 == type {pat="^"type; print gensub(pat, replace, 1)}' 
        echo $funcname tmp1 ${tmp} >&2
        getconfig "$@" | awk -vtype="$type" -vreplace="$replace" '$1 == type {pat="^"type; print gensub(pat, replace, 1)}'
    fi
}

function getconfig_item_rec()
{
    echo getconfig_item_rec param: $@  >&2
    if [[ $# -lt 3 ]]; then
        echo "Usage: getconfig_item_rec type replace params..."
        return 1
    fi
    
    local num=$(($# - 2))
    local result=
    while [[ $num -gt 0 ]]; do
        result=$(getconfig_item "$1" "$2" "${@:3:$num}")
        if [[ $result != "" ]]; then
            printf "getconfig_item_rec --reuslt:$result" >&2
            echo "$result"
            break
        fi
        num=$((num - 1))
    done
    echo getconfig_item_rec result $result  >&2
}

function listconfig()
{
    if [[ $# -eq 0 ]]; then
        echo "=====$funcname=listconfig==0=" >&2
        get_toolsconfig_content 
        echo "-----$funcname--listconfig--0---------------"
        get_toolsconfig_content | awk '$0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*--/{print}'
    else
        echo "=====$funcname=listconfig==1=$@" >&2
        get_toolsconfig_content
        echo "-----$funcname-listconfig-----1-------------"
        get_toolsconfig_content | tac | awk '
        ARGIND==1{
            for (i = 1; i <= NF; ++i)
                types[$i] = 1;
            find = 0;
            matching = 0;
        }
        ARGIND==2 && $0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*$/ {
            if ($0 ~ /^[[:space:]]*--/) {
                if (!matching) {
                    matching = 1;
                    find = 0;
                }
                
                op = gensub(/^[[:space:]]*--/, "", "g", $1);
                if (!find && (op in types)) {
                    find = 1;
                }
            } else {
                matching = 0;
                if (find) {
                    print;
                }
            }
        }' <(echo "$@") - | tac
    fi
}

function getip()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME params..." >&2
        return 1
    fi
    
    if [[ $1 =~ ^[0-9]+.[0-9]+.[0-9]+.[0-9]+$ ]]; then
        echo $1
        return 0
    fi
    
    local cmd=$(getconfig_item_rec setip echo "$@")
    eval "$cmd"
}

function getipx()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME params..." >&2
        return 1
    fi
    
    getip "$@" | tr ' ' '\n'
}

function getpath()
{
    echo "$FUNCNAME param:$@" >&2
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME params..." >&2
        return 1
    fi

    local cmd=$(getconfig_item_rec setpath echo "$@")
    echo getpath cmd:$cmd >&2
    eval "$cmd"
}

function getcmd()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME params..." >&2
        return 1
    fi

    getconfig_item_rec setcmd '' "$@"
}

function select_env()
{
    local setcmd=$(getcmd ":env-$1:")
    if [[ $setcmd != "" ]]; then
        eval "$setcmd"
        export SELECTED_ENV=$1
    else
        local opts=$(echo $(listconfig | sed -n '/^:env-.*:$/s/:env-\([^:]*\).*/\1/gp') | tr ' ' '|')
        echo "Usage: $FUNCNAME $opts   (current env: $SELECTED_ENV)" >&2
        return 1
    fi
}

function check_env()
{
    if [[ "$SELECTED_ENV" == "" ]]; then
        if [[ "$1" != "" ]]; then
            echo "please use select_env to select one env" >&2
        fi
        return 1
    else
        return 0
    fi
}

function get_server_ip()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME app.server [division]" >&2
        return 1
    fi
    if ! check_env info; then
        return 1
    fi
    
    local appserver=$1
    local division=$2
    local sql="SELECT DISTINCT node FROM db_mfw.t_server"
    local cond=()
    if [[ $appserver == *"."* ]]; then
        cond=("${cond[@]}" "app='${appserver%.*}'" "server='${appserver#*.}'")
    else
        cond=("${cond[@]}" "app='${MFW_APP_NAME}'" "server='$appserver'")
    fi
    if [[ $division != "" ]]; then
        cond=("${cond[@]}" "division='$division'")
    fi
    if [[ ${#cond[@]} -ne 0 ]]; then
        cond=$(joinstr ' and ' "${cond[@]}")
        sql="$sql WHERE $cond"
    fi
    
    echo "$sql" | mysqlex $MFW_REGISTRY_DB_IP $MFW_REGISTRY_DB_PORT -N | sort | uniq
}

function get_service_port()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME app.server.service [division]" >&2
        return 1
    fi
    if ! check_env info; then
        return 1
    fi
    
    local names=($(echo "$1" | sed 's/\./ /g'))
    local division=$2
    local sql="SELECT DISTINCT endpoint FROM db_mfw.t_service"
    local cond=()
    if [[ ${#names[@]} -eq 3 ]]; then
        cond=("${cond[@]}" "app='${names[0]}'" "server='${names[1]}'" "service='${names[2]}'")
    elif [[ ${#names[@]} -eq 2 ]]; then
        cond=("${cond[@]}" "server='${names[0]}'" "service='${names[1]}'")
    elif [[ ${#names[@]} -eq 1 ]]; then
        cond=("${cond[@]}" "service='${names[0]}'")
    fi
    if [[ $division != "" ]]; then
        cond=("${cond[@]}" "division='$division'")
    fi
    if [[ ${#cond[@]} -ne 0 ]]; then
        cond=$(joinstr ' and ' "${cond[@]}")
        sql="$sql WHERE $cond"
    fi
    
    echo "$sql" | mysqlex $MFW_REGISTRY_DB_IP $MFW_REGISTRY_DB_PORT -N | awk '{print $3":"$5}' | sort | uniq
}

function figure_ip()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME ip ..." >&2
        return 1
    fi
    if ! check_env info; then
        return 1
    fi
    
    local ips=()
    while [[ $# -gt 0 ]]; do
        if [[ $1 == '.' ]]; then
            ips=("${ips[@]}" $(showip))
        else
            ips=("${ips[@]}" "$1")
        fi
        shift
    done
    local iplist=$(joinstr "', '" "${ips[@]}")
    local sql="SELECT DISTINCT CONCAT(app, '.', server, IF(division!='', '%', ''), division) FROM db_mfw.t_server WHERE node IN('$iplist')"
    
    echo "$sql" | mysqlex $MFW_REGISTRY_DB_IP $MFW_REGISTRY_DB_PORT -N | sort | uniq
}

function enter_machine()
{
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    
    local path=$(getpath "$@")
    local cmd=$(getcmd "$@")
    if [[ $path != "" ]]; then
        cd "$path"
    fi
    if [[ $cmd != "" ]]; then
        eval "$cmd"
    fi
}

function g()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME [[ssh options] --] user@host|host@@user[/next host] ..."
        listconfig setip | cat -n
        return 1
    fi
    
    local sshoption=()
    if [[ $1 == "-"* ]]; then
        while [[ $# -gt 0 ]]; do
            if [[ $1 != "--" ]]; then
                sshoption=("${sshoption[@]}" "$1")
                echo g: sshoption $sshoption
                shift
            else
                shift
                break;
            fi
        done
    fi

    local svr=$1    
    local nextsvr=
    if [[ $1 =~ .*/.* ]]; then
        echo g: "$1 =~ .*/.* "
        svr=${1%%/*}
        nextsvr=${1#*/}
    fi
    shift
    
    local user=
    if [[ $svr =~ .*@@.* ]]; then
        echo  g: 00000000
        user=${svr##*@@}
        svr=${svr%@@*}
    elif [[ $svr =~ .*@.* ]]; then
        echo  g: 0000000
        user=${svr%%@*}
        svr=${svr#*@}
    fi

    echo g: user:$user svr:$svr
    
    
    local formal_args=()
    if [[ $nextsvr != "" ]]; then
        echo g: 222222222
        formal_args=("$svr")
    else
        echo g: 33333333 
        formal_args=("$svr" "$@")
    fi
    
    if [[ $user == "" ]]; then
        user=$(getconfig_item_rec sshuser '' "${formal_args[@]}")
        echo g: user0:$user
    fi
    if [[ $user == "" ]]; then
        user=$SSH_DEFAULT_USER
        echo g: user1:$user
    fi

    local ips=($(getip "${formal_args[@]}"))
    local goenv=$(getconfig_item setenv '' "${formal_args[@]}")
    local sshoption_from_cfg=$(getconfig_item sshoption '' "${formal_args[@]}")

    echo ==g: ips:$ips goenv:$goenv sshoption_from_cfg:$sshoption_from_cfg

    if [[ $goenv == "" ]]; then
        goenv=$SELECTED_ENV
    fi

    local cmd="select_env $goenv"
    if [[ $nextsvr != "" ]]; then
        cmd="$cmd; g $nextsvr $@"
    else
        cmd="$cmd; enter_machine ${formal_args[@]}"
    fi

    if [[ ${#ips[*]} -eq 0 ]]; then
        echo "no ip available: $svr" >&2
        return 1
    fi
    if [[ ${#ips[*]} -eq 1 ]]; then
        shellex $user@${ips[0]} "$cmd" "${sshoption[@]}" $sshoption_from_cfg
        return $?
    fi
    
    echo "available ip list: "
    echo "${ips[@]}" | tr ' ' '\n' | cat -n
    
    local index=0
    until [[ $index -ge 1 && $index -le ${#ips[*]} ]]; do
        echo -n "Select one ip [1 - ${#ips[*]}]: "
        read -r index
    done

    shellex $user@${ips[$((index-1))]} "$cmd" "${sshoption[@]}" $sshoption_from_cfg

    echo shellex =================
}

function altip()
{
    if [[ $# -ne 2 ]]; then
        echo "Usage: $FUNCNAME ip in|out"
        return 1
    fi
    
    for ip in $(get_sshgetpwd_content | grep -w "$1" | awk '{for(i=1;i<=NF;++i) print $i}' | sed '/^[0-9.]\+$/!d'); do
        if [[ $(getiptype $ip) == "$2" ]]; then
            echo $ip
            return
        fi
    done
    
    echo "$1"
}

function gop()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME public-ip ..."
        return 1
    fi
    
    local ip=$(altip "$1" in)
    shift
    g "$ip" "$@"
}

function cdex()
{
    if [[ $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME params..."
        listconfig setpath | cat -n
        return 1
    fi
    
    local path=$(getpath "$@")
    echo cdex "path" $path >&2
    if [[ $path != '' ]]; then
        echo "cdex --0---"
        cd "$path"
    else
        echo "cdex --1---"
        cd "$@"
    fi
}

function c() { cdex "$@"; }

function get_online_zone()
{
    echo "select id from db_dirserver.t_dir where (flag = 1 or flag = 2) and (merge_to_zone is null or merge_to_zone = 0)" | mysqlex $(getip globaldb) -N
}

function flux()
{
    local t=5
    local bps=1
    while [[ $# -gt 0 ]]; do
        if [[ $1 == "byte" ]]; then
            bps=0
        else
            t=$1
        fi
        shift
    done
    
    local d1=$(cat /proc/net/dev | sed '1,2d; s/:/ /g' | awkx 1 2 3 10 11)
    sleep $t
    local d2=$(cat /proc/net/dev | sed '1,2d; s/:/ /g' | awkx 1 2 3 10 11)
    
    join <(echo "$d1") <(echo "$d2") | awk -vt=$t -vbps=$bps '{
        rxb = ($6 - $2) / t;
        rxp = ($7 - $3) / t;
        txb = ($8 - $4) / t;
        txp = ($9 - $5) / t;
        if (bps) {
            rxb = rxb * 8 / 1000 / 1000;
            txb = txb * 8 / 1000 / 1000;
        } else {
            rxb = rxb / 1024 / 1024;
            txb = txb / 1024 / 1024;
        }
        printf("%8s %8.3f %8.3f %8d %8d\n", $1, rxb, txb, rxp, txp);
    }'
}

function fluxnow()
{
  cat /proc/net/dev | sed '1,2d; s/:/ /g' | awkx 1 2 10
}

function fluxdiff()
{
  local f1 f2
  local update=0
  if [[ $# -eq 2 ]]; then
    f1=$1
	f2=$2
  elif [[ $# -eq 1 ]]; then
    f1=$1
    f2=$(fluxnow)
  elif [[ $# -eq 0 ]]; then
    if [[ "$__PREVIOUS_FLUX" == "" ]]; then
      __PREVIOUS_FLUX=$(fluxnow)
      return
	fi
    f1=$__PREVIOUS_FLUX
    f2=$(fluxnow)
    update=1
  fi
  
  awk '
    ARGIND==1 {inbound[$1]=$2; outbound[$1]=$3}
    ARGIND==2 && ($1 in inbound) {print $1, $2-inbound[$1], $3-outbound[$1]}
  ' <(echo "$f1") <(echo "$f2") | column -t
  
  if [[ $update -eq 1 ]]; then
    __PREVIOUS_FLUX=$f2
  fi
}

function runcmdip()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME args... cmd"
        return 1
    fi
    
    local num=$(($# - 1))
    local cmd="${@:$#}"
    local ips=$(getip "${@:1:$num}")
    local ip=
    for ip in $ips; do
        echo "====== $ip ======";
        runcmdclean $ip "$cmd"
        echo
    done
}

function runcmdipex()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: $FUNCNAME args... cmd"
        return 1
    fi
    
    local num=$(($# - 1))
    local cmd="${@:$#}"
    local ips=$(getip "${@:1:$num}")
    local ip=
    for ip in $ips; do
        echo "====== $ip ======";
        runcmdexclean $ip "$cmd"
        echo
    done
}

function prun()
{
    local process=20
    local cmd=
    while [[ $# -gt 0 ]]; do
        if [[ ${1:0:2} == '-P' ]]; then
            if [[ ${1:2} != "" ]]; then
                process=${1:2}
                shift
            elif [[ $# -gt 1 ]]; then
                process=$2
                shift 2
            else
                err=1
                break
            fi
        else
            break
        fi
    done
    
    if [[ $err -eq 1 || $# -lt 1 ]]; then
        echo "Usage: $FUNCNAME [-P max_procs=20] cmd..." >&2
        return 1
    fi

    cmd='(res=$('"$@"'); flock -x 200; if [[ $res != "" ]]; then echo "$res"; fi) 200</proc/$PPID/cmdline'
    if [[ $PRUN_EX_MODE == "1" ]]; then
        cmd='eval "$TOOLSFUNC_IMPORT_SCRIPT"; '"$cmd"
    fi
    xargs -I{} -P$process bash -c "$cmd"
}

function prunex()
{
    (
    eval "$(get_toolsfunc_export_script)"
    PRUN_EX_MODE=1 prun "$@"
    )
}

# 根据netstat结果中的进程id，找到对应的进程名字和参数
function netstatps()
{
    awk '$1 == "tcp" || $1 == "udp" {
        prog = $1 == "tcp" ? $7 : $6;
        pid = gensub(/\/.*/, "", "g", prog);
        if (pid ~ /^[0-9]+$/) {
            line = "";
            cmd = "ps --noheader -o args -p "pid;
            cmd | getline line;
            close(cmd);
            print $0"=== "line;
        } else {
            print $0;
        }
    }'
}

function netstatex()
{
    local args=(-nlptu)
    if [[ $# -gt 0 ]]; then
        args=(-np "$@")
    fi

    netstat "${args[@]}" 2>/dev/null | netstatps
}

function awk2()
{
    local awkprog=$(cat <<'EOF'
function tots(t) {
    return mktime(gensub(/[-:]/, " ", "g", t));
}

function fromts(ts) {
    return strftime("%Y-%m-%d %H:%M:%S", ts);
}

function getf(txt, p1, f1, p2, f2, p3, f3, p4, f4, p5, f5, p6, f6, p7, f7, p8, f8, p9, f9,  arr, n, i) {
    if (f1 == "" || f1 == 0) return txt;
    if (p1 == "") p1 = "[ \t]+";
    n = split(txt, arr, p1);
    if (f1 > n) return "";
    return getf(arr[f1], p2, f2, p3, f3, p4, f4, p5, f5, p6, f6, p7, f7, p8, f8, p9, f9);
}

function tidy(txt, p1, p2, p3, p4, p5, p6, p7, p8, p9) {
    if (p1 == "") p1 = "[][,:]";
    txt = gensub(p1, " ", "g", txt);
    
    if (p2 != "") return tidy(txt, p2, p3, p4, p5, p6, p7, p8, p9);
    
    txt = gensub(/^[ \t\r]+/, "", "g", txt);
    txt = gensub(/[ \t\r]+$/, "", "g", txt);
    txt = gensub(/[ \t\r]+/, " ", "g", txt);
    return txt;
}

function between(txt, ps, pe, inc,  i, j) {
    i = match(txt, ps);
    if (i == 0) return "";
    
    if (inc == "")
        txt = substr(txt, i + RLENGTH);
    else
        txt = substr(txt, i);

    if (pe == "") return txt;

    j = match(txt, pe);
    if (j == 0) return txt;
    return substr(txt, 1, j - 1);
}

EOF
)

    local n=$(skiparg "$@")
    if [[ $n -ne 0 ]]; then
        awk -f <(echo "$awkprog") "${@:1:n}" -W source "${@:n+1}"
    else
        awk -f <(echo "$awkprog") -W source "$@"
    fi
}

function get_battle_ip()
{
    if [[ $# -eq 0 ]]; then
        echo "Usage: $FUNCNAME id..."
        return 1
    fi
    
    while [[ $# -gt 0 ]]; do
        local battleid=$1
        shift
        
        echo "SELECT battle_id, direct_ip FROM db_zone_global.t_battle_status WHERE battle_id=$battleid" | mysqlex globaldb -N
    done
}

function trimcfg()
{
    sed -e 's/^[ \t]*#.*//g; /^$/d' "$@"
}

function tstable() {
  local sep=","
  if [[ $# -gt 0 ]]; then
    sep=$1
  fi

  awk -v sep="$sep" '{
    if ($1 ~ /^[0-9]+$/) {
        d = strftime("%F", $1);
        t = strftime("%T", $1);
        v = $2;
    } else {
        d = $1;
        t = $2;
        v = $3;
    }
    days[d];
    times[t];
    points[d" "t] = v;
  }
  END {
    days_len = asorti(days, sort_days);
    times_len = asorti(times, sort_times);

    printf("time");
    for (i = 1; i <= days_len; ++i) {
        printf("%s%s", sep, sort_days[i]);
    }
    printf("\n");

    for (i = 1; i <= times_len; ++i) {
        t = sort_times[i];
        printf("%s", t);

        for (j = 1; j <= days_len; ++j) {
            d = sort_days[j];
            v = points[d" "t];
            if (v == "") v = "-";
            printf("%s%s", sep, v);
        }
        printf("\n");
    }
  }'
}

function tscolumn() {
    tstable $'\t' | column -t
}
