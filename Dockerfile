FROM ubuntu

MAINTAINER txhsl <teumessian@qq.com>

WORKDIR /root

COPY config /tmp/

# install openssh-server, openjdk and wget

RUN apt update && apt install -y openssh-server openjdk-8-jdk wget nano --fix-missing

# install hadoop 3.0.3
RUN wget http://apache.org/dist/hadoop/common/hadoop-3.0.3/hadoop-3.0.3.tar.gz && \
    tar -xzvf hadoop-3.0.3.tar.gz && \
    mv hadoop-3.0.3 /opt/hadoop && \
    rm hadoop-3.0.3.tar.gz

# install hive 2.3.3
RUN wget http://apache.org/dist/hive/hive-2.3.3/apache-hive-2.3.3-bin.tar.gz && \
    tar -xzvf apache-hive-2.3.3-bin.tar.gz && \
    mv apache-hive-2.3.3-bin /opt/hive && \
    rm apache-hive-2.3.3-bin.tar.gz

# install hive-mysql driver
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz && \
    tar -xzvf mysql-connector-java-5.1.45.tar.gz && \
     mv mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar /opt/hive/lib/ && \
    rm -rf mysql-connector-java-5.1.45*
    
# install zookeeper 3.4.12
RUN wget http://apache.org/dist/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz && \
    tar -xzvf zookeeper-3.4.12.tar.gz && \
    mv zookeeper-3.4.12 /opt/zookeeper && \
    rm zookeeper-3.4.12.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive 
ENV ZK_HOME=/opt/zookeeper 
ENV PATH=$PATH:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/hive/bin:/opt/zookeeper/bin

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys

RUN sh -c 'echo "password\npassword" | passwd' && \ 
    mkdir -p ~/hadoop/namenode && \ 
    mkdir -p ~/hadoop/datanode && \
    mkdir -p ~/hadoop/zkdata && \
    mkdir -p ~/hadoop/zklog && \
    mkdir -p ~/hadoop/mapred && \
    mkdir -p ~/hadoop/journaldata && \
    mkdir -p ~/hadoop/tmp && \
    mkdir $HADOOP_HOME/logs

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-conf/* $HADOOP_HOME/etc/hadoop/ && \
    mv /tmp/zoo.cfg /opt/zookeeper/conf/ && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    rm $HADOOP_HOME/sbin/*.cmd && \
    rm $HADOOP_HOME/etc/hadoop/*.cmd && \
    rm $ZK_HOME/bin/*.cmd

CMD [ "sh", "-c", "service ssh start; bash"]