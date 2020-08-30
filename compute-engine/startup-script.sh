#!/bin/bash

# https://stackoverflow.com/questions/34726498/how-to-update-google-cloud-dns-with-ephemeral-ip-for-an-instance

dns_start() {
    gcloud dns record-sets transaction start -z "${ZONENAME}"
}

dns_add() {
    if [[ -n "$1" && "$1" != '@' ]]; then
        local -r name="$1.${DOMAIN}."
    else
        local -r name="${DOMAIN}."
    fi
    local -r ttl="$(ttlify "$2")"
    local -r type="$3"
    shift 3
    gcloud dns record-sets transaction add      -z "${ZONENAME}" --name "${name}" --ttl "${ttl}" --type "${type}" "$@"
}

dns_commit() {
    gcloud dns record-sets transaction execute -z "${ZONENAME}"
}

# get the external ip of the VM using the metadata API
external_ip() {
    curl http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"
}

main() {
    DOMAIN="domain.here"
    ZONENAME="zone-name-here"
    VM_NAME="vm-name-here"
    dns_start
    dns_add "${VM_NAME}" "ttl" "record_type" `external_ip` "${VM_NAME}.${DOMAIN}."
    dns_commit
}

main
