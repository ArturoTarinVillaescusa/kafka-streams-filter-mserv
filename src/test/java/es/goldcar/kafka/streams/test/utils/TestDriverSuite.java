package es.goldcar.kafka.streams.test.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.io.IOException;
import java.util.Properties;
import org.apache.commons.io.FileUtils;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.kafka.connect.json.JsonDeserializer;
import org.apache.kafka.connect.json.JsonSerializer;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.TopologyTestDriver;
import org.apache.kafka.streams.errors.StreamsException;
import org.apache.kafka.streams.test.ConsumerRecordFactory;
import org.junit.After;

public class TestDriverSuite {

    public static final String INPUT_TOPIC = "dummy-input-topic";
    public static final String OUTPUT_TOPIC = "dummy-output-topic";
    protected static final String KEY = "KEY";
    private static final String APPLICATION_ID = "test";
    private static final String BOOTSTRAP_SERVERS = "localhost:9999";
    private final ConsumerRecordFactory<String, JsonNode> consumer = new ConsumerRecordFactory<>(new StringSerializer(),
        new JsonSerializer());
    private TopologyTestDriver testDriver;

    @After
    public void tearDown() throws IOException {
        closeTestDriver();
    }

    protected void closeTestDriver() throws IOException {
        try {
            testDriver.close();
        } catch (StreamsException e) {
            FileUtils.deleteDirectory(new File("\\tmp\\kafka-streams"));
        }
    }

    protected ProducerRecord<String, JsonNode> getProducedRecord(String topic) {
        return testDriver.readOutput(topic, new StringDeserializer(), new JsonDeserializer());
    }

    protected void consume(String topic, String key, JsonNode source, long timestampMs) {
        testDriver.pipeInput(consumer.create(topic, key, source, timestampMs));
    }

    protected void setUpTestDriver(Topology topology) {
        testDriver = new TopologyTestDriver(topology, getTestDriverConfiguration());
    }

    protected Properties getTestDriverConfiguration() {
        Properties props = new Properties();
        props.setProperty(StreamsConfig.APPLICATION_ID_CONFIG, APPLICATION_ID);
        props.setProperty(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.setProperty(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        props.setProperty(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        return props;
    }

    protected JsonNode getSource(final int operationId) throws IOException {
        return new ObjectMapper().readTree("{" +
            "\"UMID\": \"U1T10000000003324607\"," +
            "\"StartDateTime\": \"2017-09-19T17:41:46\"," +
            "\"EndDateTime\": \"2017-09-19T17:41:47\"," +
            "\"OperationID\": " + operationId + "," +
            "\"AgencyID\": \"02343-01\"," +
            "\"XMLIn\": \"<xml><tag1><Password>password</Password></tag1>\"," +
            "\"XMLOut\": \"<xml><tag1></tag1>\"" +
            "}");
    }

    protected JsonNode getSink() throws IOException {
        return new ObjectMapper().readTree("{" +
            "\"UMID\": \"U1T10000000003324607\"," +
            "\"StartDateTime\": \"2017-09-19T17:41:46\"," +
            "\"EndDateTime\": \"2017-09-19T17:41:47\"," +
            "\"OperationID\": 1150," +
            "\"AgencyID\": \"02343-01\"," +
            "\"XMLIn\": \"<xml><tag1></tag1>\"," +
            "\"XMLOut\": \"<xml><tag1></tag1>\"" +
            "}");
    }
}
