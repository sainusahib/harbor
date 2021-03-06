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
echo "${OS_DISTRO}: Configuring Neutron Lbaas Agent"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars NEUTRON_LBAAS_CONFIG_FILE \
                    NEUTRON_LBAAS_AGENT_CONFIG_FILE \
                    OS_DOMAIN \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    LBAAS_PROVIDER


################################################################################
crudini --set $cfg_lbaas service_auth auth_version "2"
crudini --set $cfg_lbaas service_auth admin_password "password"
crudini --set $cfg_lbaas service_auth admin_user "admin"
crudini --set $cfg_lbaas service_auth admin_tenant_name "admin"
crudini --set $cfg_lbaas service_auth auth_url "http://${KEYSTONE_API_SERVICE_HOST_SVC}/v2.0"


################################################################################
if [ "$LBAAS_PROVIDER" = "octavia" ]; then
  LBAAS_SERVICE_PROVIDER="LOADBALANCERV2:Octavia:neutron_lbaas.drivers.octavia.driver.OctaviaDriver:default"
elif [ "$LBAAS_PROVIDER" = "haproxy" ]; then
  LBAAS_SERVICE_PROVIDER="LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default"
fi;
check_required_vars LBAAS_SERVICE_PROVIDER
crudini --set $cfg_lbaas service_providers service_provider "${LBAAS_SERVICE_PROVIDER}"


################################################################################
crudini --set $cfg_lbaas_haproxy DEFAULT interface_driver "openvswitch"
crudini --set $cfg_lbaas_haproxy DEFAULT ovs_use_veth "False"
crudini --set $cfg_lbaas_haproxy haproxy loadbalancer_state_path "/var/lib/neutron/state/lbaas"
crudini --set $cfg_lbaas_haproxy haproxy user_group "haproxy"
