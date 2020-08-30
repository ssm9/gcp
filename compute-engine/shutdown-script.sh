#!/bin/bash

dns_start() {
    gcloud dns record-sets transaction start -z "${ZONENAME}"
}

dns_del() {
    if [[ -n "$1" && "$1" != '@' ]]; then
        local -r name="$1.${ZONE}."
    else
        local -r name="${ZONE}."
    fi
    local -r ttl="$(ttlify "$2")"
    local -r type="$3"
    shift 3
    gcloud dns record-sets transaction remove     -z "${ZONENAME}" --name "${name}" --ttl "${ttl}" --type "${type}" "$@"
}

dns_commit() {
    gcloud dns record-sets transaction execute -z "${ZONENAME}"
}

# get the external ip of the VM using the metadata API
external_ip() {
    curl http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"
}

main() {
    ZONENAME="zone-name-here"
    VM_NAME="vm-name-here"
    dns_start
    dns_del "${VM_NAME}" "ttl" "record_type" `external_ip`
    dns_commit
}

main
