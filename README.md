# CÓMO PROBAR EN UN ENTORNO DE DESARROLLO

Vamos a aprovechar la máquina que preparamos para el laboratorio de formación, formacionkafka, con ip 10.0.12.41.

usuario: administrador, clave: ver detalles en el Jira "OTD-158 Curso Kafka desarrolladores"

1) Creamos los tópicos. Al ser un entorno de test, en lugar de la retención de 28,8 minutos como tenemos en madkafka,
1728000 milisegundos, damos una retención de 2 minutos, 120000 milisegundos:

```
administrador@formacionkafka:~
10:31:10 $ df -h /
S.ficheros                        Tamaño Usados  Disp Uso% Montado en
/dev/mapper/kafkabroker1--vg-root    16G   9,0G  6,0G  61% /

administrador@formacionkafka:~
10:34:58 $ /opt/kafka/kafka/bin/kafka-topics.sh --create --topic sar-req-res \
                                     --replication-factor 1 --partitions 1 \
                                     --config retention.ms=120000 \
                                     --config message.timestamp.difference.max.ms=120000 \
                                     --zookeeper formacionkafka:2181
Created topic "sar-req-res".

administrador@formacionkafka:~
10:36:30 $ /opt/kafka/kafka/bin/kafka-topics.sh --create --topic sar-req-res-con-datos-filtrados \
                                     --replication-factor 1 --partitions 1 \
                                     --config retention.ms=120000 \
                                     --config message.timestamp.difference.max.ms=120000 \
                                     --zookeeper formacionkafka:2181
Created topic "sar-req-res-con-datos-filtrados".

```

2) Configuramos MirrorMaker:

Este es el servicio de arranque:

```
administrador@formacionkafka:~
10:47:41 $ sudo cat /etc/systemd/system/mirrormaker.service
[Unit]
Description=MirrorMaker Daemon
Documentation=http://kafka.apache.org/documentation.html
Requires=kafka.service

[Service]
WorkingDirectory=/opt/kafka/kafka
Environment="LOG_DIR=/var/log/mirrormaker"

User=kafka
ExecStart=/opt/kafka/kafka/bin/kafka-mirror-maker.sh --num.streams 3
                        --consumer.config /opt/kafka/kafka/config/consumermirrormaker.properties
                        --producer.config /opt/kafka/kafka/config/producermirrormaker.properties
                        --whitelist="sar-req-res"
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Esta es la configuración "consumer" de MirrorMaker: De qué cluster vamos a leer los datos

```
administrador@formacionkafka:~
10:52:55 $ cat /opt/kafka/kafka/config/consumermirrormaker.properties
# CONSUMER SOURCE: madkafka01, madkafka02, madkafka03 Kafka cluster
# Consumer config bootstrap.servers must point to source cluster
bootstrap.servers=172.30.72.100:9092,172.30.72.101:9092,172.30.72.102:9092
partition.assignment.strategy=org.apache.kafka.clients.consumer.RoundRobinAssignor
enable.auto.commit=false
auto.offset.reset=latest
exclude.internal.topics=true
group.id=MirrorMakerGroup
client.id=MirrorMakerClient_formacionkafka01
```

Esta es la configuración de destino: a qué cluster vamos a replicar los datos

```
administrador@formacionkafka:~
10:58:13 $ cat /opt/kafka/kafka/config/producermirrormaker.properties
# PRODUCER SOURCE: Local Kafka cluster
# Producer config bootstrap.servers should point to target cluster
producer.type=async
bootstrap.servers=formacionkafka:9092
acks=1
# batch.size=10
client.id=mirror_client_81
# https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=27846330#Kafkamirroring(MirrorMaker)-Consumerandsourceclustersocketbuffersizes
# NO RECONOCIDOS POR MirrorMaker
# socket.buffersize=102400
# socket.send.buffer=102400
# fetch.size=1512400

# https://engineering.salesforce.com/mirrormaker-performance-tuning-63afaed12c21
batch.size = 50000
buffer.memory = 2000000000
# Si hemos de transmitir mensajes grandes activaremos este parámetro
compression.type = gzip
linger.ms = 15000
max.request.size = 1000000
```

3) Lanzamos MirrorMaker desde línea de comando

```
administrador@formacionkafka:~
11:17:00 $ /opt/kafka/kafka/bin/kafka-mirror-maker.sh --num.streams 3 \
                                   --consumer.config /opt/kafka/kafka/config/consumermirrormaker.properties \
                                   --producer.config /opt/kafka/kafka/config/producermirrormaker.properties \
                                   --whitelist='sar-req-res'
```

y vemos que funciona lanzando un consumer en una ventana diferente:

```
administrador@formacionkafka:~
11:05:29 $ /opt/kafka/kafka/bin/kafka-console-consumer.sh \
                     --bootstrap-server localhost:9092 --topic sar-req-res

ate><CarGroupAvailabilityAndRate><CarGroup>K</CarGroup><Availability>NotAvailable</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>678.688</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate><CarGroupAvailabilityAndRate><CarGroup>L</CarGroup><Availability>Available</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>69.672</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate><CarGroupAvailabilityAndRate><CarGroup>R</CarGroup><Availability>Available</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>61.475</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate></GetAllGroupsReservationAvailabilityAndRatesByLocationRS>" }

```


4) Habilitamos el servicio de MirrorMaker lo arrancamos y comprobamos que funciona:

```
administrador@formacionkafka:/etc/systemd/system
11:13:04 $ sudo systemctl enable mirrormaker

administrador@formacionkafka:/etc/systemd/system
11:13:21 $ sudo systemctl start mirrormaker

administrador@formacionkafka:/etc/systemd/system
11:13:25 $ sudo systemctl status mirrormaker
● mirrormaker.service - MirrorMaker Daemon
   Loaded: loaded (/etc/systemd/system/mirrormaker.service; enabled; vendor preset: enabled)
   Active: active (running) since lun 2019-03-04 11:13:40 CET; 186ms ago
     Docs: http://kafka.apache.org/documentation.html
 Main PID: 7119 (kafka-run-class)
    Tasks: 12
   Memory: 660.0K
      CPU: 204ms
   CGroup: /system.slice/mirrormaker.service
           ├─7119 /bin/bash /opt/kafka/kafka/bin/kafka-run-class.sh kafka.tools.MirrorMaker --num.streams 3 --consum
           ├─7219 /bin/bash /opt/kafka/kafka/bin/kafka-run-class.sh kafka.tools.MirrorMaker --num.streams 3 --consum
           └─7221 grep -E (-(test|src|scaladoc|javadoc)\.jar|jar.asc)$

mar 04 11:13:40 formacionkafka systemd[1]: Started MirrorMaker Daemon.
```

4) Verificamos que MirrorMaker está replicando los mensajes producidos el tópico sar-req-res de madkafka01,
madkafka02, madkafka03 al tópico de mismo nombre el servidor 'formacionkafka':

```
administrador@formacionkafka:~
11:05:29 $ /opt/kafka/kafka/bin/kafka-console-consumer.sh \
                     --bootstrap-server localhost:9092 --topic sar-req-res

ate><CarGroupAvailabilityAndRate><CarGroup>K</CarGroup><Availability>NotAvailable</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>678.688</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate><CarGroupAvailabilityAndRate><CarGroup>L</CarGroup><Availability>Available</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>69.672</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate><CarGroupAvailabilityAndRate><CarGroup>R</CarGroup><Availability>Available</Availability><RentalNetRate><FuelPolicy>FullFuelSDC</FuelPolicy><RentalNetRatePrice>61.475</RentalNetRatePrice><VATPercentage>0.22</VATPercentage></RentalNetRate></CarGroupAvailabilityAndRate></GetAllGroupsReservationAvailabilityAndRatesByLocationRS>" }

```

5) Generamos el FatJar:

```
mvn clean package

[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ mssarsensitivedataremover ---
[INFO] Building jar: C:\Users\atarin.mistralbs\Documents\2019-02-20 BD-1103 Ofuscar datos de peticiones de SAR con Kafka Streams\BitBucket\mssarsensitivedataremover\target\mssarsensitivedataremover.jar
[INFO]
[INFO] --- maven-assembly-plugin:2.4.1:single (make-assembly) @ mssarsensitivedataremover ---
[INFO] Building jar: C:\Users\atarin.mistralbs\Documents\2019-02-20 BD-1103 Ofuscar datos de peticiones de SAR con Kafka Streams\BitBucket\mssarsensitivedataremover\target\mssarsensitivedataremover-jar-with-dependencies.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 20.027 s
[INFO] Finished at: 2019-03-04T19:57:44+01:00
[INFO] Final Memory: 17M/67M
[INFO] ------------------------------------------------------------------------
```

6) Lo subimos al servidor 'formacionkafka' y probamos que funciona desde línea de comando:

```
atarin.mistralbs@PORTATIL-192~/Documents/2019-02-20 BD-1103 Ofuscar datos de peticiones de SAR con Kafka Streams/BitBucket/mssarsensitivedataremover
  (master) $ java -jar target/mssarsensitivedataremover-jar-with-dependencies.jar
20:02:49,903 INFO  org.apache.kafka.streams.StreamsConfig                        - StreamsConfig values:
        application.id = OfuscadorJsonSAR
        application.server =
        bootstrap.servers = [localhost:9092]
        buffered.records.per.partition = 1000
        cache.max.bytes.buffering = 0
        client.id =
        commit.interval.ms = 100
        connections.max.idle.ms = 540000
        default.deserialization.exception.handler = class org.apache.kafka.streams.errors.LogAndFailExceptionHandler
        default.key.serde = class org.apache.kafka.common.serialization.Serdes$ByteArraySerde
        default.production.exception.handler = class org.apache.kafka.streams.errors.DefaultProductionExceptionHandler
        default.timestamp.extractor = class org.apache.kafka.streams.processor.FailOnInvalidTimestamp
        default.value.serde = class org.apache.kafka.common.serialization.Serdes$ByteArraySerde
        max.task.idle.ms = 0
        metadata.max.age.ms = 300000
        metric.reporters = []
        metrics.num.samples = 2
        metrics.recording.level = INFO
        metrics.sample.window.ms = 30000
        num.standby.replicas = 0
        num.stream.threads = 1
        partition.grouper = class org.apache.kafka.streams.processor.DefaultPartitionGrouper
        poll.ms = 100
        processing.guarantee = exactly_once
        receive.buffer.bytes = 32768
        reconnect.backoff.max.ms = 1000
        reconnect.backoff.ms = 50
        replication.factor = 1
        request.timeout.ms = 40000
        retries = 0
        retry.backoff.ms = 100
        rocksdb.config.setter = null
        security.protocol = PLAINTEXT
        send.buffer.bytes = 131072
        state.cleanup.delay.ms = 600000
        state.dir = /tmp/kafka-streams
        topology.optimization = none
        upgrade.from = null
        windowstore.changelog.additional.retention.ms = 86400000

20:02:50,365 INFO  org.apache.kafka.clients.admin.AdminClientConfig              - AdminClientConfig values:
        bootstrap.servers = [localhost:9092]
        client.dns.lookup = default
        client.id = OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-admin
        connections.max.idle.ms = 300000
        metadata.max.age.ms = 300000
        metric.reporters = []
        metrics.num.samples = 2
        metrics.recording.level = INFO
        metrics.sample.window.ms = 30000
        receive.buffer.bytes = 65536
        reconnect.backoff.max.ms = 1000
        reconnect.backoff.ms = 50
        request.timeout.ms = 120000
        retries = 5
        retry.backoff.ms = 100
        sasl.client.callback.handler.class = null
        sasl.jaas.config = null
        sasl.kerberos.kinit.cmd = /usr/bin/kinit
        sasl.kerberos.min.time.before.relogin = 60000
        sasl.kerberos.service.name = null
        sasl.kerberos.ticket.renew.jitter = 0.05
        sasl.kerberos.ticket.renew.window.factor = 0.8
        sasl.login.callback.handler.class = null
        sasl.login.class = null
        sasl.login.refresh.buffer.seconds = 300
        sasl.login.refresh.min.period.seconds = 60
        sasl.login.refresh.window.factor = 0.8
        sasl.login.refresh.window.jitter = 0.05
        sasl.mechanism = GSSAPI
        security.protocol = PLAINTEXT
        send.buffer.bytes = 131072
        ssl.cipher.suites = null
        ssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]
        ssl.endpoint.identification.algorithm = https
        ssl.key.password = null
        ssl.keymanager.algorithm = SunX509
        ssl.keystore.location = null
        ssl.keystore.password = null
        ssl.keystore.type = JKS
        ssl.protocol = TLS
        ssl.provider = null
        ssl.secure.random.implementation = null
        ssl.trustmanager.algorithm = PKIX
        ssl.truststore.location = null
        ssl.truststore.password = null
        ssl.truststore.type = JKS

20:02:50,465 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka version : 2.1.0
20:02:50,467 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka commitId : eec43959745f444f
20:02:50,477 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Creating restore consumer client
20:02:50,487 INFO  org.apache.kafka.clients.consumer.ConsumerConfig              - ConsumerConfig values:
        auto.commit.interval.ms = 5000
        auto.offset.reset = none
        bootstrap.servers = [localhost:9092]
        check.crcs = true
        client.dns.lookup = default
        client.id = OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1-restore-consumer
        connections.max.idle.ms = 540000
        default.api.timeout.ms = 60000
        enable.auto.commit = false
        exclude.internal.topics = true
        fetch.max.bytes = 52428800
        fetch.max.wait.ms = 500
        fetch.min.bytes = 1
        group.id =
        heartbeat.interval.ms = 3000
        interceptor.classes = []
        internal.leave.group.on.close = false
        isolation.level = read_committed
        key.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
        max.partition.fetch.bytes = 1048576
        max.poll.interval.ms = 2147483647
        max.poll.records = 1000
        metadata.max.age.ms = 300000
        metric.reporters = []
        metrics.num.samples = 2
        metrics.recording.level = INFO
        metrics.sample.window.ms = 30000
        partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
        receive.buffer.bytes = 65536
        reconnect.backoff.max.ms = 1000
        reconnect.backoff.ms = 50
        request.timeout.ms = 30000
        retry.backoff.ms = 100
        sasl.client.callback.handler.class = null
        sasl.jaas.config = null
        sasl.kerberos.kinit.cmd = /usr/bin/kinit
        sasl.kerberos.min.time.before.relogin = 60000
        sasl.kerberos.service.name = null
        sasl.kerberos.ticket.renew.jitter = 0.05
        sasl.kerberos.ticket.renew.window.factor = 0.8
        sasl.login.callback.handler.class = null
        sasl.login.class = null
        sasl.login.refresh.buffer.seconds = 300
        sasl.login.refresh.min.period.seconds = 60
        sasl.login.refresh.window.factor = 0.8
        sasl.login.refresh.window.jitter = 0.05
        sasl.mechanism = GSSAPI
        security.protocol = PLAINTEXT
        send.buffer.bytes = 131072
        session.timeout.ms = 10000
        ssl.cipher.suites = null
        ssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]
        ssl.endpoint.identification.algorithm = https
        ssl.key.password = null
        ssl.keymanager.algorithm = SunX509
        ssl.keystore.location = null
        ssl.keystore.password = null
        ssl.keystore.type = JKS
        ssl.protocol = TLS
        ssl.provider = null
        ssl.secure.random.implementation = null
        ssl.trustmanager.algorithm = PKIX
        ssl.truststore.location = null
        ssl.truststore.password = null
        ssl.truststore.type = JKS
        value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer

20:02:50,565 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka version : 2.1.0
20:02:50,565 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka commitId : eec43959745f444f
20:02:50,584 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Creating consumer client
20:02:50,588 INFO  org.apache.kafka.clients.consumer.ConsumerConfig              - ConsumerConfig values:
        auto.commit.interval.ms = 5000
        auto.offset.reset = earliest
        bootstrap.servers = [localhost:9092]
        check.crcs = true
        client.dns.lookup = default
        client.id = OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1-consumer
        connections.max.idle.ms = 540000
        default.api.timeout.ms = 60000
        enable.auto.commit = false
        exclude.internal.topics = true
        fetch.max.bytes = 52428800
        fetch.max.wait.ms = 500
        fetch.min.bytes = 1
        group.id = OfuscadorJsonSAR
        heartbeat.interval.ms = 3000
        interceptor.classes = []
        internal.leave.group.on.close = false
        isolation.level = read_committed
        key.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
        max.partition.fetch.bytes = 1048576
        max.poll.interval.ms = 2147483647
        max.poll.records = 1000
        metadata.max.age.ms = 300000
        metric.reporters = []
        metrics.num.samples = 2
        metrics.recording.level = INFO
        metrics.sample.window.ms = 30000
        partition.assignment.strategy = [org.apache.kafka.streams.processor.internals.StreamsPartitionAssignor]
        receive.buffer.bytes = 65536
        reconnect.backoff.max.ms = 1000
        reconnect.backoff.ms = 50
        request.timeout.ms = 30000
        retry.backoff.ms = 100
        sasl.client.callback.handler.class = null
        sasl.jaas.config = null
        sasl.kerberos.kinit.cmd = /usr/bin/kinit
        sasl.kerberos.min.time.before.relogin = 60000
        sasl.kerberos.service.name = null
        sasl.kerberos.ticket.renew.jitter = 0.05
        sasl.kerberos.ticket.renew.window.factor = 0.8
        sasl.login.callback.handler.class = null
        sasl.login.class = null
        sasl.login.refresh.buffer.seconds = 300
        sasl.login.refresh.min.period.seconds = 60
        sasl.login.refresh.window.factor = 0.8
        sasl.login.refresh.window.jitter = 0.05
        sasl.mechanism = GSSAPI
        security.protocol = PLAINTEXT
        send.buffer.bytes = 131072
        session.timeout.ms = 10000
        ssl.cipher.suites = null
        ssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]
        ssl.endpoint.identification.algorithm = https
        ssl.key.password = null
        ssl.keymanager.algorithm = SunX509
        ssl.keystore.location = null
        ssl.keystore.password = null
        ssl.keystore.type = JKS
        ssl.protocol = TLS
        ssl.provider = null
        ssl.secure.random.implementation = null
        ssl.trustmanager.algorithm = PKIX
        ssl.truststore.location = null
        ssl.truststore.password = null
        ssl.truststore.type = JKS
        value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer

20:02:50,630 WARN  org.apache.kafka.clients.consumer.ConsumerConfig              - The configuration 'admin.retries' was supplied but isn't a known config.
20:02:50,630 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka version : 2.1.0
20:02:50,631 INFO  org.apache.kafka.common.utils.AppInfoParser                   - Kafka commitId : eec43959745f444f
20:02:50,649 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Starting
20:02:50,650 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] State transition from CREATED to RUNNING
20:02:50,651 INFO  org.apache.kafka.streams.KafkaStreams                         - stream-client [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29] Started Streams client
Topologies:
   Sub-topology: 0
    Source: KSTREAM-SOURCE-0000000000 (topics: [sar-req-res])
      --> KSTREAM-MAP-0000000001
    Processor: KSTREAM-MAP-0000000001 (stores: [])
      --> KSTREAM-SINK-0000000002
      <-- KSTREAM-SOURCE-0000000000
    Sink: KSTREAM-SINK-0000000002 (topic: sar-req-res-con-datos-filtrados)
      <-- KSTREAM-MAP-0000000001


ThreadMetadata{threadName=OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1, threadState=RUNNING, activeTasks=[], standbyTasks=[]}
20:02:51,488 WARN  org.apache.kafka.clients.NetworkClient                        - [AdminClient clientId=OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-admin] Connection to node -1 (localhost/127.0.0.1:9092) could not be established. Broker may not be available.
20:02:51,876 WARN  org.apache.kafka.clients.NetworkClient                        - [Consumer clientId=OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1-consumer, groupId=OfuscadorJsonSAR] Connection to node -1 (localhost/127.0.0.1:9092) could not be established. Broker may not be available.
20:02:52,432 INFO  org.apache.kafka.streams.KafkaStreams                         - stream-client [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29] State transition from RUNNING to PENDING_SHUTDOWN
20:02:52,438 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Informed to shut down
20:02:52,438 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] State transition from RUNNING to PENDING_SHUTDOWN
20:02:52,514 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Shutting down
20:02:52,514 INFO  org.apache.kafka.clients.consumer.KafkaConsumer               - [Consumer clientId=OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1-restore-consumer, groupId=] Unsubscribed all topics or patterns and assigned partitions
20:02:52,527 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] State transition from PENDING_SHUTDOWN to DEAD
20:02:52,527 INFO  org.apache.kafka.streams.processor.internals.StreamThread     - stream-thread [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-StreamThread-1] Shutdown complete
20:02:52,528 INFO  org.apache.kafka.clients.admin.internals.AdminMetadataManager  - [AdminClient clientId=OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29-admin] Metadata update failed
org.apache.kafka.common.errors.TimeoutException: Timed out waiting to send the call.
20:02:52,542 INFO  org.apache.kafka.streams.KafkaStreams                         - stream-client [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29] State transition from PENDING_SHUTDOWN to NOT_RUNNING
20:02:52,542 INFO  org.apache.kafka.streams.KafkaStreams                         - stream-client [OfuscadorJsonSAR-cb037dd0-826a-4242-85f5-b9e2d1e21a29] Streams client stopped completely

```

7) Creamos carpeta de logs, creamos scripts de arranque y parada de Kafka Streams, los incluímos en un servicio, habilitamos y arrancamos el servicio:

```
administrador@formacionkafka:~
10:47:41 $ sudo mkdir /var/log/kafkastreams
```

```
administrador@formacionkafka:~
12:03:30 $ cat /opt/kafka/kafka/bin/arranca-kafka-streams.sh
#!/bin/bash
java -jar /opt/kafka/kafka/bin/mssarsensitivedataremover-jar-with-dependencies.jar > /var/log/kafkastreams/mssarsensitivedataremover.log
```
```
administrador@formacionkafka:~
12:01:45 $ cat /opt/kafka/kafka/bin/para-kafka-streams.sh
#!/bin/bash
for i in `ps -ef | grep mssarsensitivedataremover-jar-with-dependencies.jar | awk '{print $2}'`; do kill -9 $i; done
```

```
administrador@formacionkafka:~
10:47:41 $ sudo cat /etc/systemd/system/kafkastreams.service
[Unit]
Description=Kafka Streams Daemon
Documentation=http://kafka.apache.org/documentation.html
Requires=mirrormaker.service

[Service]
WorkingDirectory=/opt/kafka/kafka

User=kafka
ExecStart=/opt/kafka/kafka/bin/arranca-kafka-streams.sh
ExecStop=/opt/kafka/kafka/bin/para-kafka-streams.sh
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```
administrador@formacionkafka:~
11:51:16 $ sudo systemctl enable kafkastreams.service
Created symlink from /etc/systemd/system/multi-user.target.wants/kafkastreams.service to /etc/systemd/system/kafkastreams.service.
```

```
administrador@formacionkafka:~
11:51:16 $ sudo systemctl start kafkastreams.service
```

```
administrador@formacionkafka:/usr/local/intellij/ProyectosIntelliJ/mssarsensitivedataremover
12:28:30 $ sudo systemctl status kafkastreams
● kafkastreams.service - Kafka Streams Daemon
   Loaded: loaded (/etc/systemd/system/kafkastreams.service; e
   Active: active (running) since mar 2019-03-05 12:28:30 CET;
     Docs: http://kafka.apache.org/documentation.html
  Process: 19747 ExecStop=/opt/kafka/kafka/bin/para-kafka-stre
 Main PID: 22361 (arranca-kafka-s)
    Tasks: 21
   Memory: 441.9M
      CPU: 32.893s
   CGroup: /system.slice/kafkastreams.service
           ├─22361 /bin/bash /opt/kafka/kafka/bin/arranca-kafk
           └─22363 java -jar /opt/kafka/kafka/bin/mssarsensiti

mar 05 12:28:30 formacionkafka systemd[1]: Started Kafka Strea
```

```
administrador@formacionkafka:/usr/local/intellij/ProyectosIntelliJ/mssarsensitivedataremover
12:32:00 $ sudo tail -f /var/log/kafkastreams/mssarsensitivedataremover.log
```

# CÓMO PROBAR EL ENTORNO EN TU PC

1) Descarga kafka.apache.org o confluent.io


2) Si usas Windows puede que debas Limpiar el entorno

```
atarin.mistralbs@PORTATIL-192/
  $ rm -rf /c/tmp
```


3) Arranca Zookeeper y Kafka

```
cd Downloads/kafka_2.12-2.1.0
atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/zookeeper-server-start.sh -daemon config/zookeeper.properties

atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/kafka-server-start.sh -daemon config/server.properties
```


4) Crea los tópicos y listalos

```
atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic sar-req-res --replication-factor 1 --partitions 1

Created topic "sar-req-res-con-datos-sensibles".

atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic sar-req-res-no-sensitive-data --replication-factor 1 --partitions 1

Created topic "sar-req-res-no-sensitive-data".

atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
      $ bin/kafka-topics.sh --zookeeper localhost:2181 --list

sar-req-res
sar-req-res-no-sensitive-data
```

5) Lanza ProductorJsonSAR.java y consume del tópico sar-req-res-con-datos-sensibles para asegurarte de que se están creando mensajes:

```
atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sar-req-res-no-sensitive-data --from-beginning
```

6) Lanza OfuscadorJsonSAR.java y consume del tópico sar-req-res-con-datos-filtrados para asegurarte de que se están creando mensajes:

```
atarin.mistralbs@PORTATIL-192~/Downloads/kafka_2.12-2.1.0
  $ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sar-req-res-no-sensitive-data --from-beginning
```


7) Lanza todo con copy paste, me va a permitir acelerar el tiempo de desarrollo y pruebas:

```
rm -rf /c/tmp
cd /c/Users/atarin.mistralbs/Downloads/kafka_2.12-2.1.0
bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
bin/kafka-server-start.sh -daemon config/server.properties
bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic sar-req-res --replication-factor 1 --partitions 1
bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic sar-req-res-no-sensitive-data --replication-factor 1 --partitions 1
bin/kafka-topics.sh --zookeeper localhost:2181 --list
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sar-req-res-no-sensitive-data
```

Arranca OfuscadorJsonSAR.java

A continuación lanza estas líneas en una ventana independiente:

```
cd /c/Users/atarin.mistralbs/Downloads/kafka_2.12-2.1.0
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sar-req-res-con-datos-filtrados --from-beginning
```

Finalmente, lanza ProductorJsonSAR.java

Verás que los mensajes van llegando al tópico sar-req-res-con-datos-sensibles y al tópico sar-req-res-con-datos-filtrados en sus ventanas kafka-console-consumer.sh correspondientes.