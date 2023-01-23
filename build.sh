#!/bin/bash
set -e

declare -a COMMANDS=(install deps delete usage create reg checkreg init admin deploy image dashboard token opendash defaultadmin)
CMD="${1:-usage}"; shift 2>/dev/null

deps() {
    ! type docker &>/dev/null && echo "docker not installed." && exit 1
    ! type kubectl &>/dev/null && echo "kubectl not installed." && exit 1
    echo 'All dependencies met.'
}

black=$'\e[30m'
red=$'\e[31m'
green=$'\e[32m'
yellow=$'\e[33m'
blue=$'\e[34m'
magenta=$'\e[35m'
cyan=$'\e[36m'
white=$'\e[37m'
reset=$'\e[0m'

# ----------------------------- COMMANDS -----------------------------

defaultadmin() {
    kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default
}


usage() {
    cmds="${COMMANDS[@]}"
    cmds="[${cmds// /|}]"
    echo
    echo "${black}usage: ${yellow}${0##*/} ${reset}$cmds"
    echo
}

install() {
    echo "Add the following to ~/.bashrc to enable completion:"
    echo "  type kind &>/dev/null && . <(kind completion bash)"
    exec go install sigs.k8s.io/kind@latest
}

dashboard() {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
}

opendash() {
    open "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
}

token() {
    kubectl get secrets -o "jsonpath={.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base65 --decode
}

create() {
    local name=${1}

    echo "Creating cluster $name"
    local config=""
    if [[ -r kind-$name.yaml ]]; then
        kind create cluster --name "$name" --config "kind-$name.yaml"
      else
        echo "No config file found for $name using default config"
        kind create cluster --name "$name"
      fi

    # deploy ingress controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
}


delete() {
    local cluster=${1}
    printf "Do you want to completely delete cluster '$cluster'? "
    read response
    [[ ! $response =~ ^y(es)? ]] && echo "Fine. Cancelling." && exit 0
    kind delete cluster --name "$cluster"
}

init() {
    delete "$@" && create "$@" && admin "$@"
}

reg() {
    docker rm -f reg || true
    docker run -d --restart always -p "127.0.0.1:5000:5000" --name reg registry
    docker network connect kind reg || true
    kubectl apply -f - <<EOM
    apiVersion: v1
    kind: ConfigMap
    metadata:
        name: local-registry-hosting
        namespace: kube-public
    data:
        localRegistryHosting.v1: |
            host: "localhost:5000"
            help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOM
}

checkreg() {
    docker inspect -f '{{.State.Running}}' reg 2>/dev/null
}

admin() {
    local cluster=${1:-kind}
    echo "${red}WARNING: granting admin perms to all in '$cluster'${reset}"
    kubectl apply -f - <<EOM
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cluster-admin
    rules:
    - apiGroups: [""]
      resources: ["*"]
      verbs: ["create","get","watch","list"]
EOM
    kubectl apply -f - <<EOM
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: cluster-admin-binding
    subjects:
    - kind: User
      name: default
      apiGroup: rbac.authorization.k8s.io
    - kind: Group
      name: system:unauthenticated
      apiGroup: rbac.authorization.k8s.io
    - kind: Group
      name: system:authenticated
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: cluster-admin
      apiGroup: rbac.authorization.k8s.io
EOM
}

image() {
    docker pull rwxrob/httphey
    docker tag rwxrob/httphey localhost:5000/httphey:1.0
    docker push localhost:5000/httphey:1.0
}

deploy() {
    local cluster=${1}
    exec kubectl apply -f "k8s/${cluster}.yaml"
}

# ------------------------ complete -C foo foo -----------------------

if [[ -n $COMP_LINE ]]; then
    for c in ${COMMANDS[@]}; do 
        [[ ${c:0:${#1}} == $1 ]] && echo "$c"
    done
    exit 0
fi

for c in ${COMMANDS[@]}; do
    if [[ $c == $CMD ]]; then
        "$CMD" "$@"
        exit $?
    fi
done
