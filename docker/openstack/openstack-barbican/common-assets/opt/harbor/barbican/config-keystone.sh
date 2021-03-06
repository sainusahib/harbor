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
echo "${OS_DISTRO}: Configuring keystone"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/barbican/vars.sh


################################################################################
check_required_vars BARBICAN_PASTE_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_REGION \
                    AUTH_BARBICAN_KEYSTONE_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_USER \
                    AUTH_BARBICAN_KEYSTONE_PASSWORD \
                    AUTH_BARBICAN_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_PROJECT \
                    BARBICAN_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    MEMCACHE_SERVICE_HOST_SVC


################################################################################
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'pipeline:barbican_api' pipeline "barbican-api-keystone"


################################################################################
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' memcached_servers "${MEMCACHE_SERVICE_HOST_SVC}:11211"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' auth_uri "https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' project_domain_name "${AUTH_BARBICAN_KEYSTONE_PROJECT_DOMAIN}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' project_name "${AUTH_BARBICAN_KEYSTONE_PROJECT}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' user_domain_name "${AUTH_BARBICAN_KEYSTONE_DOMAIN}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' region_name "${AUTH_BARBICAN_KEYSTONE_REGION}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' password "${AUTH_BARBICAN_KEYSTONE_PASSWORD}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' username "${AUTH_BARBICAN_KEYSTONE_USER}"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' auth_url "https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' auth_type "password"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' auth_version "v3"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' signing_dir "/var/cache/barbican"
crudini --set ${BARBICAN_PASTE_CONFIG_FILE} 'filter:authtoken' cafile "${BARBICAN_DB_CA}"
