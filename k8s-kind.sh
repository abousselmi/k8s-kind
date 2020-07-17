#!/usr/bin/env bash

# Copyright 2020 abousselmi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Bootstarp a kubernetes cluster based on kind and kubeadmin
# Author: abousselmi
#

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

KIND_RELEASE="0.7.0"
KUBECTL_RELEASE="1.18.0"
LINUX_ARCH="amd64"
BIN_DIR="/usr/local/bin/"
CLUSTER_NAME="k8s"
CLUSTER_CONFIG="kind-multi-node-config.yaml"
USER_UID="1000"

RED='\e[0;31m'
GREEN='\e[0;32m'
NC='\e[0m'

function log {
    echo -e "🔥$GREEN $(date +"%r")[INFO] $1 $NC"
}

function logerr {
    echo -e "🔥$RED $(date +"%r")[ERRO] $1 $NC"
}

function print_motd {
    log " ██   ██  █████  ███████     ██   ██ ██ ███    ██ ██████  "
    log " ██  ██  ██   ██ ██          ██  ██  ██ ████   ██ ██   ██ "
    log " █████    █████  ███████     █████   ██ ██ ██  ██ ██   ██ "
    log " ██  ██  ██   ██      ██     ██  ██  ██ ██  ██ ██ ██   ██ "
    log " ██   ██  █████  ███████     ██   ██ ██ ██   ████ ██████  "
    log " This is just a bootstrap script"
}

function print_usage {
    echo "Usage: $0 OPTION COMMAND"
    echo ""
    echo "Options:"
    echo "  -m      bootstrap a multi node cluster"
    echo "  -s      bootstrap a single node cluster"
    echo ""
    echo "Commands:"
    echo "  start   setup kubernetes cluster"
    echo "  stop    remove the current cluster"
    echo "  help    print usage"
    echo ""
    echo "Example:"
    echo "  To bootstrap a multi node ckuster, you can do:"
    echo "  sudo $0 -m start"
    echo ""
}

function setup_kind {
    which kind &> /dev/null
    RET_CODE=$?
    if [[ $RET_CODE -ne 0 ]] ; then
        log "'kind' is not installed on the system"
        log "download 'kind' verion: ${KIND_RELEASE}"
        curl -sLo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_RELEASE}/kind-$(uname)-${LINUX_ARCH}
        chmod +x ./kind
        log "move 'kind' to ${BIN_DIR}"
        mv ./kind ${BIN_DIR}
    else
        log "'kind' is already installed, continue.."
    fi
}

function setup_kubectl {
    which kubectl &> /dev/null
    RET_CODE=$?
    if [[ $RET_CODE -ne 0 ]] ; then
        log "'kubectl' is not installed on the system"
        log "download 'kubectl' version: ${KUBECTL_RELEASE}"
        curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_RELEASE}/bin/linux/${LINUX_ARCH}/kubectl
        chmod +x ./kubectl
        log "move 'kubectl' to ${BIN_DIR}"
        mv ./kubectl ${BIN_DIR}
    else
        log "'kubectl' is already installed, continue.."
    fi
}

function enable_kubectl_autocompletion {
    log "enable 'kubectl' autocompletion"
    kubectl completion bash > /etc/bash_completion.d/kubectl
}

function check_dependencies {
    which $1 &> /dev/null
    RET_CODE=$?
    if [[ $RET_CODE -eq 0 ]] ; then
        log "'$1' is installed, continue.."
    else
        logerr "'$1' is not installed on the system, stopping.."
        exit 1
    fi
}

function setup_cluster {
    log "create kubernetes cluster '${CLUSTER_NAME}'"
    if $1 ; then
        kind create cluster --name ${CLUSTER_NAME}
    else
        kind create cluster --name ${CLUSTER_NAME} --config ${CLUSTER_CONFIG}
    fi
    log "specify the cluster '${CLUSTER_NAME}' as the current context for kubectl"
    kubectl cluster-info --context kind-${CLUSTER_NAME}

    log "Update kubernetes config ownership"
    chown -R $USER_UID:$USER_UID /home/$(getent passwd "$USER_UID"|cut -d: -f1)/.kube
}

function remove_cluster {
    log "remove kubernetes cluster '${CLUSTER_NAME}'"
    kind delete cluster --name ${CLUSTER_NAME}
}

function bootstrap_cluster {
    clear
    print_motd
    log "start bootstrapping.."
    START=$(date +%s)
    log "check dependencies.."
    check_dependencies curl
    check_dependencies docker
    setup_kind
    setup_kubectl
    enable_kubectl_autocompletion
    setup_cluster $1
    END=$(date +%s)
    DURATION=$(( $END - $START ))
    log "finished in $DURATION seconds."
}

case "$1" in
    "-m")
        case "$2" in
            "start")
                bootstrap_cluster false
                ;;
            *)
                print_usage
                exit 1
                ;;
        esac
        ;;
    "-s")
        case "$2" in
            "start")
                bootstrap_cluster true
                ;;
            *)
                print_usage
                exit 1
                ;;
        esac
        ;;
    "stop")
        remove_cluster
        ;;
    "help")
        print_usage
        ;;
    *)
        print_usage
        exit 1
        ;;
esac

