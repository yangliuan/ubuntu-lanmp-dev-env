#!/bin/bash
#https://www.elastic.co/guide/en/elasticsearch/reference/8.4/deb.html#deb-repo
Install_Elasticsearch() {
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    apt-get install apt-transport-https
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/${elasticsearch_ver}/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-${elasticsearch_ver}.list
    apt-get update && apt-get install elasticsearch && apt-get install kibana && apt-get install logstash
}

Install_Cerebro() {
    pushd ${oneinstack_dir}/src > /dev/null
    echo "Download cerebro ..."
    src_url="http://mirror.yangliuan.cn/cerebro-${cerebo_ver}.tgz" && Download_src
    tar zxvf cerebro-${cerebo_ver}.tgz
    mkdir /etc/cerebro
    cp -r cerebro-${cerebo_ver}/conf/* /etc/cerebro
    mv cerebro-${cerebo_ver} /usr/share/cerebro
    #create group and user
    id -g cerebro >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd cerebro
    id -u cerebro >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -g cerebro -M -s /sbin/nologin cerebro
    #created systemd cerebro.service
    cp ${oneinstack_dir}/init.d/cerebro.service /lib/systemd/system/
    chown -R cerebro.cerebro /usr/share/cerebro
    systemctl daemon-reload
}

Uninstall_Elasticsearch() {
    apt-get autoremove elasticsearch kibana logstash
    rm -rf /etc/apt/sources.list.d/elastic-${elasticsearch_ver}.list
    rm -rf /etc/apt/sources.list.d/elastic-${elasticsearch_ver}.list.save
    apt-get update
}

Uninstall_Cerebro() {
    rm -rf /lib/systemd/system/cerebro.service
    rm -rf /usr/share/cerebro
    systemctl daemon-reload
}

Install_Config() {
    echo "config"
    #chmod -R 777 /etc/elasticsearch
    sed -i "s/## -Xms4g/-Xms1g/g" /etc/elasticsearch/jvm.options
    sed -i "s/## -Xmx4g/-Xmx1g/g" /etc/elasticsearch/jvm.options
}