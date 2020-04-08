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

RED='\e[0;31m'
GREEN='\e[0;32m'
NC='\e[0m'

function log {
    echo -e "$GREEN $(date +"%r")[INFO] $1 $NC"
}

function logerr {
    echo -e "$RED $(date +"%r")[ERRO] $1 $NC"
}

function setup_kind {
    log "download 'kind' verion: ${KIND_RELEASE}"
    curl -sLo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_RELEASE}/kind-$(uname)-${LINUX_ARCH}
    chmod +x ./kind
    log "move 'kind' to ${BIN_DIR}"
    mv ./kind ${BIN_DIR}
}

function setup_kubectl {
    log "download 'kubectl' version: ${KUBECTL_RELEASE}"
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_RELEASE}/bin/linux/${LINUX_ARCH}/kubectl
    chmod +x ./kubectl
    log "move 'kubectl' to ${BIN_DIR}"
    mv ./kubectl ${BIN_DIR}
}

function enable_kubectl_autocompletion {
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

function create_cluster {
    log "create the kubernetes cluster"
    kind create cluster
}

log "start bootstrapping.."
START=$(date +%s)
log "checking dependencies.."
check_dependencies curl
check_dependencies docker
setup_kind
check_dependencies kind
setup_kubectl
check_dependencies kubectl
enable_kubectl_autocompletion
create_cluster
END=$(date +%s)
DURATION=$(( $END - $START ))
log "finished in $DURATION seconds."
