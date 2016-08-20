#!/bin/sh
set -x
set -e
mkdir -p /opt/stack

git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP}

pip --no-cache-dir install /opt/stack/${OS_COMP}

mkdir -p /etc/${OS_COMP}/volumes
mkdir -p  /opt/stack/${OS_COMP}/etc/${OS_COMP}/
cp -rf /opt/stack/${OS_COMP}/etc/${OS_COMP}/* /etc/${OS_COMP}/

mkdir -p /var/log/${OS_COMP}
mkdir -p /var/lib/${OS_COMP}/lock
mkdir -p /var/lib/${OS_COMP}/instances

if [ "$OS_DISTRO" = "HarborOS-Alpine" ]; then
  addgroup ${OS_COMP} -g 1000
  adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP}
  ln -s /usr/sbin/iscsid /sbin/iscsid
else
  groupadd ${OS_COMP} -g 1000
  adduser -u 1000 -g ${OS_COMP} --system  ${OS_COMP}
fi;

chown -R ${OS_COMP}:${OS_COMP} /etc/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}