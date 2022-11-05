#!/usr/bin/with-contenv bashio
set -e

bashio::log.info "Setting host: $(bashio::config local_host)"
sed -i "s/LOCAL_HOST/$(bashio::config local_host)/g" /haproxy.cfg

bashio::log.info "Setting port: $(bashio::config local_port)"
sed -i "s/LOCAL_PORT/$(bashio::config local_port)/g" /haproxy.cfg

if $(bashio::config.true ssl.enabled); then
	bashio::log.info "SSL communitcation enabled"
	sed -i "s/USE_SSL/ssl/g" /haproxy.cfg

	if $(bashio::config.true ssl.verify); then
		bashio::log.info "SSL verification enabled"
		sed -i "s/VERIFY_SSL//g" /haproxy.cfg
	else
		bashio::log.info "SSL verification disabled"
		sed -i "s/VERIFY_SSL/verify none/g" /haproxy.cfg
	fi

else
	bashio::log.info "SSL communication not enabled"
	sed -i "s/USE_SSL VERIFY_SSL//g" /haproxy.cfg
fi

bashio::log.info "Server line: $(cat /haproxy.cfg | grep 'server local_proxy')"

bashio::log.info "Starting haproxy"
haproxy -W -db -f /haproxy.cfg
