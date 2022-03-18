FROM moc-xdmod-base

#COPY assets /tmp/assets
#RUN /tmp/assets/copy-caches.sh
#COPY bin /root/bin

WORKDIR /root


# This installs a barebones 9.5 instance of XDmod
RUN mkdir -p /root/rpmbuild/RPMS/noarch \
    && mkdir /tmp/supremm \
    && yum -y install openssh-server openssh-clients pcp pcp-manager pcp-conf pcp-libs python-pcp perl-PCP-PMDA pcp-system-tools pcp-pmda-gpfs pcp-pmda-lustre pcp-pmda-infiniband pcp-pmda-mic pcp-pmda-nvidia-gpu \
    pcp-pmda-nfsclient pcp-pmda-perfevent pcp-pmda-json python3 \
    && pip3 install --upgrade pip \
    && pip3 install keystoneauth python-keystoneclient python-novaclient python-cinderclient cryptography python-openstacksdk mysql-connector-python

# RPM install of XDMod
COPY ./httpd.conf /etc/httpd/conf/httpd.conf
COPY ./portal_settings.ini /etc/xdmod/portal_settings.ini
RUN chmod 777 /etc/xdmod/portal_settings.ini
COPY ./etc-xdmod-resources.json /etc/xdmod/resources.json
COPY ./etc-xdmod-resource_specs.json /etc/xdmod/resource_specs.json
COPY ./etc-xdmod-organization.json /etc/xdmod/organization.json
COPY ./openstack.2018-04-17T00-00-00_2018-04-30T23-59-59.json /root/test/openstack/2018-04-17T00-00-00_2018-04-30T23-59-59.json

# am copying the xdmod-httpd conf file to ssl.conf as both use *:443
# and this is easier than just deleting the ssl.conf
COPY ./xdmod-httpd.conf /etc/httpd/conf.d/ssl.conf
RUN cd /root/rpmbuild/RPMS/noarch \
    && wget -nv https://github.com/ubccr/xdmod/releases/download/v9.5.0/xdmod-9.5.0-1.0.el7.noarch.rpm \
    && yum -y install xdmod-9.5.0-1.0.el7.noarch.rpm

COPY ./hypervisor_facts.py /usr/bin/xdmod-openstack-hypervisor
COPY ./moc_openstack_api_reporting.py /usr/bin/xdmod-openstack-reporting
RUN chmod 777 /usr/bin/xdmod-openstack-hypervisor \
    && sed -i -e 's/\r$//' /usr/bin/xdmod-openstack-hypervisor \
    && chmod 777 /usr/bin/xdmod-openstack-reporting \
    && sed -i -e 's/\r$//' /usr/bin/xdmod-openstack-reporting

# This is done to work-a-round xdmod-setup and supremm-setup being interactive
# RUN pip install pexpect
# pexpect-xdmod-setup runs xdmod-setup non-interactively
# haven't written this yet
# COPY ./pexpect-xdmod-setup.py /root/pexpect-xdmod-setup.py


# This is a work-a-round as the xdmod-setup script need to be fixed
# still need to run xdmod-setup in a non-interactive mode - may need to be implemented
# need to import fake data
# need to inguest fake data


# RPM install of supremm
# COPY ./supremmconfig.json /etc/xdmod/supremmconfig.json
# RUN cd /root/rpmbuild/RPMS/noarch \
#  && wget -nv https://github.com/ubccr/xdmod-supremm/releases/download/v9.5.0/xdmod-supremm-9.5.0-1.0.el7.noarch.rpm \
#  yum -y install xdmod-supremm-9.5.0-1.0.el7.noarch.rpm 
# need to figure out how to install supremm-setup utility




WORKDIR /
