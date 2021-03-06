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
echo "${OS_DISTRO}: Setting environment Vars For Keystone"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_NEUTRON_KEYSTONE_REGION \
                    AUTH_NEUTRON_KEYSTONE_DOMAIN \
                    AUTH_NEUTRON_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_NEUTRON_KEYSTONE_PROJECT \
                    AUTH_NEUTRON_KEYSTONE_USER \
                    AUTH_NEUTRON_KEYSTONE_PASSWORD


################################################################################
unset OS_AUTH_URL
unset OS_REGION_NAME
unset OS_CACERT
unset OS_IDENTITY_API_VERSION
unset OS_PROJECT_NAME
unset OS_PROJECT_DOMAIN_NAME
unset OS_DOMAIN_NAME
unset OS_PASSWORD
unset OS_USERNAME
unset OS_USER_DOMAIN_NAME


################################################################################
export OS_AUTH_URL="https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000/v3"
export OS_REGION_NAME="${AUTH_NEUTRON_KEYSTONE_REGION}"
export OS_CACERT="${NEUTRON_DB_CA}"
export OS_IDENTITY_API_VERSION="3"
export OS_PROJECT_NAME="${AUTH_NEUTRON_KEYSTONE_PROJECT}"
export OS_PROJECT_DOMAIN_NAME="${AUTH_NEUTRON_KEYSTONE_PROJECT_DOMAIN}"
export OS_DOMAIN_NAME="${AUTH_NEUTRON_KEYSTONE_DOMAIN}"
export OS_PASSWORD="${AUTH_NEUTRON_KEYSTONE_PASSWORD}"
export OS_USERNAME="${AUTH_NEUTRON_KEYSTONE_USER}"
export OS_USER_DOMAIN_NAME="${AUTH_NEUTRON_KEYSTONE_DOMAIN}"


echo "${OS_DISTRO}: testing ${OS_USERNAME}:${OS_PROJECT_NAME}@${OS_DOMAIN_NAME}"
################################################################################
openstack token issue
