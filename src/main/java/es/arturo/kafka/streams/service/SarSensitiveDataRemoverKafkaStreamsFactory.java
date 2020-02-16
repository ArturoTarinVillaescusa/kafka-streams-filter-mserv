package es.arturo.kafka.streams.service;

import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.Topology;

import java.util.Properties;

public class SarSensitiveDataRemoverKafkaStreamsFactory {

    public final KafkaStreams createKafkaStreams(Topology topology, Properties config) {
        return new KafkaStreams(topology, config);
    }
}
