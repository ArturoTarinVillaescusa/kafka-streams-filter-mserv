package es.goldcar.kafka.streams.service;

import com.google.inject.Inject;
import es.goldcar.kafka.streams.utils.SarSensitiveDataRemoverConfig;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.errors.StreamsException;

@Slf4j
public class SarSensitiveDataRemoverService implements Runnable {

    private SarSensitiveDataRemoverKafkaStreamsFactory kafkaStreamsFactory;
    private KafkaStreams streams;
    @Getter
    private Topology topology;
    private SarSensitiveDataRemoverConfig configuration;

    @Inject
    public SarSensitiveDataRemoverService(SarSensitiveDataRemoverConfig configuration, Topology topology,
        SarSensitiveDataRemoverKafkaStreamsFactory kafkaStreamsFactory) {
        this.topology = topology;
        this.kafkaStreamsFactory = kafkaStreamsFactory;
        this.configuration = configuration;
    }

    @Override
    public void run() {
        streams = kafkaStreamsFactory.createKafkaStreams(topology, configuration.getConfiguration());
        cleanUp();
        streams.start();
        log.info("Streams started!");

        // shutdown hook to correctly close the streams application
        Runtime.getRuntime().addShutdownHook(new Thread(this::stop));
    }

    private void cleanUp() {
        try {
            streams.cleanUp();
        } catch (StreamsException e) {
            log.error("Error while cleaning up", e);
        }
    }

    private void stop() {
        log.info("Closing streams...");
        streams.close();
        log.info("Streams closed!");
    }

}
