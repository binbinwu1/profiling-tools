usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
  -b <user application to trace>       To specify the full path of user application
  -u <function to trace>               Function name
  -k <kernel function to trace>
  -h                        Show this help
EOM
}


TRACE_EVENTS="bpftrace -e '"

process_args() {
    while getopts "b:u:k:" option; do
        case "$option" in
            b) app=$OPTARG;;
            u) function=$OPTARG
               TRACE_EVENTS+="uprobe:$app:$function {@start_${function}=nsecs;} uretprobe:$app:$function {printf(\"[u:$function] Execute time: %ld us\n\", (nsecs - @start_${function})/1000);} "
               ;;
            k) function=$OPTARG
               TRACE_EVENTS+="kprobe:$function {@start_${function}=nsecs;} kretprobe:$function {printf(\"[k:$function] Execute time: %ld us\n\", (nsecs - @start_${function})/1000);} "
               ;;
            h) usage
               exit 0
               ;;
            *)
               echo "Invalid option '-$OPTARG'"
               usage
               exit 1
               ;;
        esac
    done
}



process_args "$@"
TRACE_EVENTS+="'"
echo $TRACE_EVENTS
eval ${TRACE_EVENTS}
