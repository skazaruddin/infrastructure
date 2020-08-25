FROM confluentinc/cp-kafka-connect-base:5.5.0
ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN confluent-hub install --no-prompt debezium/debezium-connector-mongodb:1.2.1
RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:0.9.4
RUN confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:0.9.4
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:0.9.4
