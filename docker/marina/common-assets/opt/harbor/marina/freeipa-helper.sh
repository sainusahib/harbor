#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PATH=$PATH:/usr/local/bin
echo "$OS_DISTRO: Loading enviornment"
LOCAL_ENV=/tmp/harbor.env
rm -f ${LOCAL_ENV}
touch ${LOCAL_ENV}

cfg_auth=/etc/harbor/auth.conf
cfg_images=/etc/harbor/images.conf
cfg_network=/etc/harbor/network.conf
cfg_node=/etc/harbor/node.conf
cfg_roles=/etc/harbor/roles.conf

echo "$OS_DISTRO: cfg_images=$cfg_images"
CONF_SECTION=DEFAULT
IMAGE_REPO=$(crudini --get $cfg_images ${CONF_SECTION} repo)
IMAGE_NAMESPACE=$(crudini --get $cfg_images ${CONF_SECTION} namespace)
IMAGE_TAG=$(crudini --get $cfg_images ${CONF_SECTION} tag)
IMAGE_PULL_POLICY=$(crudini --get $cfg_images ${CONF_SECTION} pull_policy)
LOCAL_ENV_LIST="${LOCAL_ENV_LIST} IMAGE_PULL_POLICY"
echo "IMAGE_PULL_POLICY=${IMAGE_PULL_POLICY}" > ${LOCAL_ENV}
source ${LOCAL_ENV}
rm -f ${LOCAL_ENV}


IMAGE=docker.io/port/freeipa-client:latest



echo "$OS_DISTRO: cfg_network=$cfg_network"
for CONF_SECTION in DEFAULT freeipa external_dns; do
  for COMPONENT in $(crudini --get $cfg_network ${CONF_SECTION}); do
    VALUE="$(crudini --get $cfg_network ${CONF_SECTION} ${COMPONENT})"
    NAME="$(echo NETWORK_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
    LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
    echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
    source ${LOCAL_ENV}
    rm -f ${LOCAL_ENV}
  done
done


export OS_DOMAIN=${NETWORK_DEFAULT_OS_DOMAIN}
echo "OS_DOMAIN=${OS_DOMAIN}"

echo "$OS_DISTRO: cfg_auth=$cfg_auth"
for CONF_SECTION in DEFAULT freeipa; do
  if [ "${CONF_SECTION}" = "DEFAULT" ]; then
    DEBUG=$(crudini --get $cfg_auth ${CONF_SECTION} debug)
    HARBOR_ROLES=$(crudini --get $cfg_auth ${CONF_SECTION} roles)
    LOCAL_ENV_LIST="${LOCAL_ENV_LIST} DEBUG HARBOR_ROLES"
    echo "DEBUG=${DEBUG}" > ${LOCAL_ENV}
    source ${LOCAL_ENV}
    rm -f ${LOCAL_ENV}
    echo "HARBOR_ROLES=${HARBOR_ROLES}" > ${LOCAL_ENV}
    source ${LOCAL_ENV}
    rm -f ${LOCAL_ENV}
  else
      IMAGE_NAME_PREFIX=$CONF_SECTION
      for COMPONENT in $(crudini --get $cfg_auth ${CONF_SECTION}); do
        VALUE="$(crudini --get $cfg_auth ${CONF_SECTION} ${COMPONENT})"
        NAME="$(echo AUTH_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
        LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
        echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
        source ${LOCAL_ENV}
        rm -f ${LOCAL_ENV}
      done
  fi;
done


HARBOR_HOSTS_FILE=/var/run/harbor/hosts
HARBOR_RESOLV_FILE=/var/run/harbor/resolv.conf


start_container () {
  CONTAINER_NAME=$1
  CONTAINER_CONFIG_DIR="/var/run/harbor/containers/${CONTAINER_NAME}"
  rm -rf ${CONTAINER_CONFIG_DIR}
  mkdir -p ${CONTAINER_CONFIG_DIR}/secrets
  echo "AUTH_FREEIPA_HOST_ADMIN_USER=${AUTH_FREEIPA_HOST_ADMIN_USER}" > $CONTAINER_CONFIG_DIR/secrets/$(echo AUTH_FREEIPA_HOST_ADMIN_USER | tr '[:upper:]' '[:lower:]' )
  echo "AUTH_FREEIPA_HOST_ADMIN_PASSWORD=${AUTH_FREEIPA_HOST_ADMIN_PASSWORD}" > $CONTAINER_CONFIG_DIR/secrets/$(echo AUTH_FREEIPA_HOST_ADMIN_PASSWORD | tr '[:upper:]' '[:lower:]' )
  echo "HARBOR_HOSTS_FILE=${HARBOR_HOSTS_FILE}" > $CONTAINER_CONFIG_DIR/secrets/$(echo HARBOR_HOSTS_FILE | tr '[:upper:]' '[:lower:]' )
  echo "HARBOR_RESOLV_FILE=${HARBOR_RESOLV_FILE}" > $CONTAINER_CONFIG_DIR/secrets/$(echo HARBOR_RESOLV_FILE | tr '[:upper:]' '[:lower:]' )

  if [ "${IMAGE_PULL_POLICY}" == "Always" ] ; then
    docker pull ${IMAGE} || true
  fi
  docker rm -v -f ${CONTAINER_NAME}.${NETWORK_DEFAULT_OS_DOMAIN} || true

  touch ${HARBOR_HOSTS_FILE}
  touch ${HARBOR_RESOLV_FILE}


  HARBOR_HOSTS_FILE=/var/run/harbor/hosts
  HARBOR_RESOLV_FILE=/var/run/harbor/resolv.conf

  FREEIPA_CLIENT_CONTAINER=$(docker create \
  --name="${CONTAINER_NAME}.${NETWORK_DEFAULT_OS_DOMAIN}" \
  --hostname="${CONTAINER_NAME}.${NETWORK_DEFAULT_OS_DOMAIN}" \
  --dns="${NETWORK_FREEIPA_FREEIPA_MASTER_IP}" \
  --net=freeipa \
  -t \
  -v="/sys/fs/cgroup:/sys/fs/cgroup:ro" \
  -v="/tmp" \
  -v="/run" \
  -v="/run/lock" \
  -v="/var/run/harbor/secrets" \
  -v="${HARBOR_HOSTS_FILE}:${HARBOR_HOSTS_FILE}:ro" \
  -v="${HARBOR_RESOLV_FILE}:${HARBOR_RESOLV_FILE}:ro" \
  --volumes-from=${DATA_CONTAINER} \
  -v="/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-bundle.crt:ro" \
  --security-opt="seccomp=unconfined" \
  docker.io/port/freeipa-client:latest)
  for ENV_VAR in ${CONTAINER_CONFIG_DIR}/secrets/*; do
    docker cp $ENV_VAR ${FREEIPA_CLIENT_CONTAINER}:/var/run/harbor/secrets/$(basename $ENV_VAR)
    rm -f $ENV_VAR
    #echo "moved $ENV_VAR -> $(basename $ENV_VAR)"
  done

  docker start ${FREEIPA_CLIENT_CONTAINER}
}



start_container $1
