package es.arturo.kafka.streams.test.integration;

import static org.awaitility.Awaitility.await;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.JsonNode;
import com.google.inject.Guice;
import com.google.inject.Injector;
import es.arturo.kafka.streams.utils.SarSensitiveDataRemoverStreamTopology;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverKafkaStreamsFactory;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverService;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverServiceFactory;
import es.arturo.kafka.streams.test.utils.TestDriverSuite;
import es.arturo.kafka.streams.utils.SarSensitiveDataRemoverConfig;

import java.io.IOException;
import java.util.concurrent.TimeUnit;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.boot.test.rule.OutputCapture;

@RunWith(MockitoJUnitRunner.class)
public class SarSensitiveDataRemoverKafkaStreamsFactoryIT extends TestDriverSuite {

    @Rule
    public final OutputCapture capture = new OutputCapture();
    @Mock
    private SarSensitiveDataRemoverConfig configuration;
    private SarSensitiveDataRemoverService service;

    @Before
    public void setUp() {
        Injector container = Guice.createInjector();

        final SarSensitiveDataRemoverStreamTopology streamTopology = container
            .getInstance(SarSensitiveDataRemoverStreamTopology.class);
        when(configuration.getConfiguration()).thenReturn(getTestDriverConfiguration());
        final SarSensitiveDataRemoverKafkaStreamsFactory streamsFactory = container
            .getInstance(SarSensitiveDataRemoverKafkaStreamsFactory.class);

        service = new SarSensitiveDataRemoverServiceFactory(configuration, streamTopology, streamsFactory)
            .create(INPUT_TOPIC, OUTPUT_TOPIC);

        setUpTestDriver(service.getTopology());
    }

    @Test
    public void test() throws IOException {
        final Thread thread = new Thread(service);
        thread.run();
        await().atMost(3, TimeUnit.SECONDS).until(() -> capture.toString().contains("Streams started!"));

        consume(INPUT_TOPIC, KEY, getSource(1150), 1L);
        final ProducerRecord<String, JsonNode> record = getProducedRecord(OUTPUT_TOPIC);

        assertNotNull(record);
        assertEquals(KEY, record.key());
        assertEquals(record.value(), getSink());
    }
}
