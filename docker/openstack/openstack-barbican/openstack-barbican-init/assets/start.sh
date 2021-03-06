#!/bin/bash

# Copyright 2016 Port Direct
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

set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/barbican/vars.sh


################################################################################
check_required_vars BARBICAN_CONFIG_FILE \
                    OS_DOMAIN \
                    APP_COMPONENT \
                    DOGTAG_PLUGIN_ROOT \
                    SNAKEOIL_PLUGIN_ROOT \
                    APP_USER

echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Config Starting"
################################################################################
/opt/harbor/config-barbican.sh


echo "${OS_DISTRO}: Component specific config starting"
################################################################################
/opt/harbor/barbican/components/config-${APP_COMPONENT}.sh


echo "${OS_DISTRO}: Moving pod configs into place"
################################################################################
cp -rfav $(dirname ${BARBICAN_CONFIG_FILE})/* /pod$(dirname ${BARBICAN_CONFIG_FILE})/


echo "${OS_DISTRO}: Creating File structure"
################################################################################
mkdir -p /var/lib/barbican
chown -R ${APP_USER}:${APP_USER} /var/lib/barbican
# mkdir -p ${DOGTAG_PLUGIN_ROOT}
# chown -R ${APP_USER}:${APP_USER} ${DOGTAG_PLUGIN_ROOT}
mkdir -p ${SNAKEOIL_PLUGIN_ROOT}
chown -R ${APP_USER}:${APP_USER} ${SNAKEOIL_PLUGIN_ROOT}


echo "${OS_DISTRO}: Pod init finished"
################################################################################
