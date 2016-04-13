#!/bin/bash
# {{ groups.server }}

help(){
        echo "Available options are as following"
        echo "start bootstrap"
        echo "start server"
        echo "start client"
        echo "restart bootstrap"
        echo "restart server"
        echo "restart client"
        echo "status"
        echo "stop"

}

if [ $# -eq 0 ]; then
    echo "NO OPTIONS PASSED"
    help
    exit 1
fi

COMMAND=/usr/bin/consul
PIDFILES=/var/run
APPNAME=consul
LOGFILES=/var/log
LOG=${LOGFILES}/${APPNAME}.log
#HOSTIP=$(hostname -i)
#HOSTIP={{ ansible_default_ipv4.address }}
HOSTIP={{ ansible_enp0s8.ipv4.address }}
DATA_DIR={{ consul.data_dir }}
OPTION=$1
MODE=$2
export COMMAND PIDFILES APPNAME LOG HOSTIP OPTION MODE DATA_DIR

start_bootstrap(){
	if [ -f ${PIDFILES}/${APPNAME}.pid ]; then
                PID=$(cat ${PIDFILES}/${APPNAME}.pid)
        else
                PID=$(pidof ${APPNAME})
        fi
	if [[ ${PID} != "" ]] ; then
		if ps -p ${PID} > /dev/null
		then
   			echo "$APPNAME IS ALREADY RUNNING UNDER $PID"
		else
			rm -rf /var/consul/*
			nohup ${COMMAND} agent -server -ui -data-dir=${DATA_DIR} -config-dir /etc/consul.d/bootstrap -bind=${HOSTIP} -client 0.0.0.0 -ui-dir=/home/consul/dest -bootstrap-expect=2 > ${LOG} 2>&1 &
			echo $! > ${PIDFILES}/${APPNAME}.pid
		fi
	else
		rm -rf /var/consul/*
                nohup ${COMMAND} agent -server -data-dir=${DATA_DIR} -config-dir /etc/consul.d/bootstrap -bind=${HOSTIP} -client 0.0.0.0 -ui-dir=/home/consul/dest -bootstrap-expect=2 > ${LOG} 2>&1 &
                echo $! > ${PIDFILES}/${APPNAME}.pid
	fi
	#nohup consul agent -server -data-dir=/var/consul -bind=192.168.33.10 -bootstrap-expect 3  &
	exit 0
}

start_server(){
        if [ -f ${PIDFILES}/${APPNAME}.pid ]; then
                PID=$(cat ${PIDFILES}/${APPNAME}.pid)
        else
                PID=$(pidof ${APPNAME})
        fi
	if [[ ${PID} != "" ]] ; then
		if ps -p ${PID} > /dev/null
        	then
                	echo "$APPNAME IS ALREADY RUNNING UNDER $PID"
        	else
			rm -rf /var/consul/*
                	nohup ${COMMAND} agent -server -ui -data-dir=${DATA_DIR} -config-dir /etc/consul.d/server -bind=${HOSTIP} -client 0.0.0.0 -ui-dir=/home/consul/dest > ${LOG} 2>&1 &
                	echo $! > ${PIDFILES}/${APPNAME}.pid
        	fi
	else
		rm -rf /var/consul/*
		nohup ${COMMAND} agent -server -ui -data-dir=${DATA_DIR} -config-dir /etc/consul.d/server -bind=${HOSTIP} -client 0.0.0.0 -ui-dir=/home/consul/dest > ${LOG} 2>&1 &
                echo $! > ${PIDFILES}/${APPNAME}.pid
	fi
	#nohup consul agent -server -ui --data-dir=/var/consul -bind=192.168.33.13 -client 0.0.0.0 -ui-dir=/home/consul/dist &
	exit 0
}

start_client(){
	if [ -f ${PIDFILES}/${APPNAME}.pid ]; then
                PID=$(cat ${PIDFILES}/${APPNAME}.pid)
        else
                PID=$(pidof ${APPNAME})
        fi
	if [[ ${PID} != "" ]] ; then
        	if ps -p ${PID} > /dev/null
        	then
                	echo "$APPNAME IS ALREADY RUNNING UNDER $PID"
        	else
			rm -rf /var/consul/*
                	nohup ${COMMAND} agent -data-dir=${DATA_DIR} -config-dir /etc/consul.d/client -bind=${HOSTIP} > ${LOG} 2>&1  &
                	echo $! > ${PIDFILES}/${APPNAME}.pid
		fi
	else
		rm -rf /var/consul/*
		nohup ${COMMAND} agent -data-dir=${DATA_DIR} -config-dir /etc/consul.d/client -bind=${HOSTIP} > ${LOG} 2>&1  &
                echo $! > ${PIDFILES}/${APPNAME}.pid
        fi
	#nohup consul agent -data-dir=/var/consul -bind=192.168.33.11 &
	exit 0
}

stop(){
	if [ -f ${PIDFILES}/${APPNAME}.pid ]; then
                PID=$(cat ${PIDFILES}/${APPNAME}.pid)
        else
                PID=$(pidof ${APPNAME})
        fi
        if [[ ${PID} != "" ]] ; then
		kill -2 ${PID}
		sleep 5
		if ps -p $PID > /dev/null
        	then
                	kill -9 ${PID}
        	else
			echo "$APPNAME Stopped"
		fi
		rm ${PIDFILES}/${APPNAME}.pid
	else
		echo "APPLICATION [ ${APPNAME} ] IS ALREADY  DOWN"
                exit 1
	fi
}

restart(){
	stop
	sleep 10
	case "${MODE}" in
                        bootstrap)
                                start_bootstrap
                                ;;
                        server)
                                start_server
                                ;;
                        client)
                                start_client
                                ;;
                        *)
                                echo "WRONG MODE [ ${MODE} ]"
                                exit 1
          esac
}

status(){
	if [ -f ${PIDFILES}/${APPNAME}.pid ]; then
		PID=$(cat ${PIDFILES}/${APPNAME}.pid)
	else
		PID=$(pidof ${APPNAME})
	fi
	if [[ ${PID} != "" ]] ; then
        	if ps -p $PID > /dev/null
        	then
                	echo "$APPNAME IS RUNNING UNDER $PID"
			exit 0
        	else
			echo "$APPNAME IS STOPPED"
		fi
	else
		echo "APPLICATION [ ${APPNAME} ] IS DOWN"
		exit 1
	fi
}

case "$OPTION" in
	start)
		case "${MODE}" in
			bootstrap)
				start_bootstrap
				;;
			server)
				start_server
				;;
			client)
				start_client
				;;
			*)
				echo "WRONG MODE [ ${MODE} ]"
				exit 1;
		esac
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	status)
		status
		;;
	*)
		echo "WRONG OPTION [ ${OPTION} ]"
		help
		exit 1
esac
exit 0
