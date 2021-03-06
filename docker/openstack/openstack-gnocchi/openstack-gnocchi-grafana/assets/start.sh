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
cp -v /run/harbor/auth/user/tls.ca /etc/pki/ca-trust/source/anchors/grafana-db.pem
update-ca-trust


echo "${OS_DISTRO}: Starting container application"
################################################################################
exec su -s /bin/sh -c "exec /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana cfg:default.paths.plugins=/var/lib/grafana/plugins" grafana
