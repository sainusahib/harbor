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

LOCAL_ENV=/tmp/$(uuidgen).env
rm -f ${LOCAL_ENV}
touch ${LOCAL_ENV}

cfg_auth=/etc/harbor/auth.conf
cfg_harbor_auth=/etc/harbor/harbor-auth.conf
cfg_images=/etc/harbor/images.conf
cfg_network=/etc/harbor/network.conf
cfg_node=/etc/harbor/node.conf
cfg_roles=/etc/harbor/roles.conf

LOCAL_ENV_LIST=""


load_node_config () {
  for CONF_SECTION in DEFAULT; do
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
}


load_image_config () {
  SERVICE=$@
  for CONF_SECTION in DEFAULT ${SERVICE}; do
    if [ "${CONF_SECTION}" = "DEFAULT" ]; then
      IMAGE_REPO=$(crudini --get $cfg_images ${CONF_SECTION} repo)
      IMAGE_NAMESPACE=$(crudini --get $cfg_images ${CONF_SECTION} namespace)
      IMAGE_TAG=$(crudini --get $cfg_images ${CONF_SECTION} tag)
      IMAGE_PULL_POLICY=$(crudini --get $cfg_images ${CONF_SECTION} pull_policy)
      LOCAL_ENV_LIST="${LOCAL_ENV_LIST} IMAGE_PULL_POLICY"
      echo "IMAGE_PULL_POLICY=${IMAGE_PULL_POLICY}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
    else
        IMAGE_NAME_PREFIX=$CONF_SECTION
        for COMPONENT in $(crudini --get $cfg_images ${CONF_SECTION}); do
          IMAGE_NAME="$(crudini --get $cfg_images ${CONF_SECTION} ${COMPONENT})"
          VALUE="${IMAGE_REPO}/${IMAGE_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"
          NAME="$(echo IMAGE_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
          LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
          echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
          source ${LOCAL_ENV}
          rm -f ${LOCAL_ENV}
        done
    fi;
  done
}

load_network_config () {
  for CONF_SECTION in $(crudini --get $cfg_network); do
    for COMPONENT in $(crudini --get $cfg_network ${CONF_SECTION}); do
      VALUE="$(crudini --get $cfg_network ${CONF_SECTION} ${COMPONENT})"
      NAME="$(echo NETWORK_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
      LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
      echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
    done
  done
}

load_auth_config () {
  SERVICE=$@
  for CONF_SECTION in freeipa ${SERVICE}; do
    if [ "${CONF_SECTION}" = "DEFAULT" ]; then
      DEBUG=$(crudini --get $cfg_harbor_auth ${CONF_SECTION} debug)
      HARBOR_ROLES=$(crudini --get $cfg_harbor_auth ${CONF_SECTION} roles)
      LOCAL_ENV_LIST="${LOCAL_ENV_LIST} DEBUG HARBOR_ROLES"
      echo "DEBUG=${DEBUG}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
      echo "HARBOR_ROLES=${HARBOR_ROLES}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
    else
        for COMPONENT in $(crudini --get $cfg_harbor_auth ${CONF_SECTION}); do
          VALUE="$(crudini --get $cfg_harbor_auth ${CONF_SECTION} ${COMPONENT})"
          NAME="$(echo AUTH_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
          LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
          echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
          source ${LOCAL_ENV}
          rm -f ${LOCAL_ENV}
        done
    fi;
  done
}
