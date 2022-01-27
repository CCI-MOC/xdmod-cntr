FROM moc-xdmod-base

#COPY assets /tmp/assets
#RUN /tmp/assets/copy-caches.sh
#COPY bin /root/bin

WORKDIR /root

# This installs a barebones 9.5 instance of XDmod
RUN mkdir -p /root/rpmbuild/RPMS/noarch \
 && cd /root/rpmbuild/RPMS/noarch \
 && wget -nv https://github.com/ubccr/xdmod/releases/download/v9.5.0/xdmod-9.5.0-1.0.el7.noarch.rpm \
 && yum install -y xdmod-9.5.0-1.0.el7.noarch.rpm \
 && cd /root


# From the original Dockerfile
#RUN mkdir -p /root/rpmbuild/RPMS/noarch \
#    && wget -nv -P /root/rpmbuild/RPMS/noarch https://github.com/ubccr/xdmod/releases/download/v$REL/xdmod-$REL-$BUILD.el7.noarch.rpm \
#    && git clone --single-branch https://github.com/ubccr/xdmod/ --branch $BRANCH /root/xdmod \
#    && /root/xdmod/tests/ci/bootstrap.sh \
#    && ~/bin/services stop \
#    && yum clean all \
#    && rm -rf /var/cache/yum /root/xdmod /root/rpmbuild

WORKDIR /
