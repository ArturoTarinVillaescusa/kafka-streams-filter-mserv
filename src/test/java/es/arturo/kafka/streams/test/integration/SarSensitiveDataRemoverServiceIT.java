package es.arturo.kafka.streams.test.integration;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import com.fasterxml.jackson.databind.JsonNode;
import com.google.inject.Guice;
import com.google.inject.Injector;
import es.arturo.kafka.streams.utils.SarSensitiveDataRemoverStreamTopology;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverKafkaStreamsFactory;
import es.arturo.kafka.streams.test.utils.TestDriverSuite;

import java.io.IOException;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.streams.Topology;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.boot.test.rule.OutputCapture;

@RunWith(MockitoJUnitRunner.class)
public class SarSensitiveDataRemoverServiceIT extends TestDriverSuite {


    @Rule
    public final OutputCapture capture = new OutputCapture();

    private Topology topology;
    private SarSensitiveDataRemoverKafkaStreamsFactory streamsFactory;

    @Before
    public void setUp() {
        setUpTopology();
        setUpTestDriver(topology);
    }

    @Test
    public void test() throws IOException {
        final JsonNode source = getSource(1150);
        final JsonNode expected = getSink();

        consume(INPUT_TOPIC, KEY, source, 1L);
        final ProducerRecord<String, JsonNode> record = getProducedRecord(OUTPUT_TOPIC);

        assertNotNull(record);
        assertEquals(KEY, record.key());
        assertEquals(record.value(), expected);
    }

    private void setUpTopology() {
        Injector container = Guice.createInjector();

        final SarSensitiveDataRemoverStreamTopology streamTopology = container
            .getInstance(SarSensitiveDataRemoverStreamTopology.class);

        topology = streamTopology.buildStreamTopology(INPUT_TOPIC, OUTPUT_TOPIC);

    }

}
