FROM confluentinc/cp-kafka-connect:7.9.2

USER root

RUN dnf update -y && \
    dnf install -y libaio && \
    dnf install -y unzip && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

ENV ORACLE_HOME="/opt/oracle"

RUN mkdir -p ${ORACLE_HOME}

COPY instantclient-basic-linux-arm64 ${ORACLE_HOME}/

WORKDIR ${ORACLE_HOME}

ENV LD_LIBRARY_PATH="${ORACLE_HOME}/instantclient_23_8:${LD_LIBRARY_PATH}"
ENV PATH="${ORACLE_HOME}/instantclient_23_8:${PATH}"
ENV TNS_ADMIN="${ORACLE_HOME}/network/admin"

RUN mkdir -p ${ORACLE_HOME}/network/admin
COPY tnsnames.ora ${ORACLE_HOME}/network/admin/

RUN chown -R appuser:appuser ${ORACLE_HOME}

USER appuser

WORKDIR ${ORACLE_HOME}
