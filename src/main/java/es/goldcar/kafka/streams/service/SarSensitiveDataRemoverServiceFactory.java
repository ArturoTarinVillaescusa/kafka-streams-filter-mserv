package es.goldcar.kafka.streams.service;

import com.google.inject.Inject;
import es.goldcar.kafka.streams.utils.SarSensitiveDataRemoverConfig;
import es.goldcar.kafka.streams.utils.SarSensitiveDataRemoverStreamTopology;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.Topology;

@Slf4j
public class SarSensitiveDataRemoverServiceFactory {

    private SarSensitiveDataRemoverConfig configuration;
    private SarSensitiveDataRemoverStreamTopology streamTopology;
    private SarSensitiveDataRemoverKafkaStreamsFactory kafkaStreamsFactory;

    @Inject
    public SarSensitiveDataRemoverServiceFactory(SarSensitiveDataRemoverConfig configuration,
        SarSensitiveDataRemoverStreamTopology streamTopology,
        SarSensitiveDataRemoverKafkaStreamsFactory kafkaStreamsFactory) {
        this.configuration = configuration;
        this.streamTopology = streamTopology;
        this.kafkaStreamsFactory = kafkaStreamsFactory;
    }

    public SarSensitiveDataRemoverService create(String sourceTopic, String sinkTopic){
        final Topology topology = streamTopology.buildStreamTopology(sourceTopic, sinkTopic);
        return new SarSensitiveDataRemoverService(configuration, topology, kafkaStreamsFactory);
    }

}
