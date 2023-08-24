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
               TRACE_EVENTS+="uprobe:$app:$function {@ustack_count[ustack]=count();} "
               ;;
            k) function=$OPTARG
               TRACE_EVENTS+="kprobe:$function {@kstack_count[kstack]=count();} "
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