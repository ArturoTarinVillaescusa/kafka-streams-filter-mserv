import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.util.*;
import java.util.concurrent.TimeUnit;

public class KafkaSlimClient {
    private final KafkaConsumer<String, String> consumer;
    private final String topic;
    TopicPartition partition;

    public KafkaSlimClient( String kafkaUrl,
                            String groupId,
                            String topic) {
        this.topic = topic;
        Properties props = new Properties();
        props.put("bootstrap.servers", kafkaUrl);
        props.put("group.id", groupId);
        props.put("enable.auto.commit", "false");
        props.put("max.poll.records", 1);
        props.put("key.deserializer", StringDeserializer.class.getName());
        props.put("value.deserializer", StringDeserializer.class.getName());
        this.consumer = new KafkaConsumer <> (props);
        this.partition = new TopicPartition(this.topic, 0);
        consumer.assign(Arrays.asList(this.partition));
    }

    public void closeKafka() {
        consumer.close(1000, TimeUnit.MILLISECONDS);
    }

    public String consumeLastMessage() {
        return consumeMessage(this.getQueueSize() - 1);
    }

    public String consumeMessage(long position) {
        String result = "";
        int pollingTimeout = 100;
        int totalTimeout = 1000;
        boolean dataFound = false;

        try {
            //Es necesario hacer un poll para que envíe un heartbeat a kafka, sino, el método de posicionamiento no funciona
            //https://stackoverflow.com/a/45623878/2928690
            consumer.poll(0);
            consumer.seek(this.partition, position); //Long.valueOf(position));

            int timeWaiting = 0;
            while (timeWaiting <= totalTimeout && !dataFound ) {
                ConsumerRecords<String, String> records = consumer.poll(pollingTimeout);
                timeWaiting += pollingTimeout;

                for (ConsumerRecord<String, String> record : records) {
                    result += record.value();
                    dataFound = true;
                    break;
                }
            }

        } catch (Exception e) {
            result = e.toString();

        } finally {

        }
        return result;
    }


    protected long getQueueSize() {
        long result = -1;
        try {
            //Es necesario hacer un poll para que envíe un heartbeat a kafka, sino el método de posicionamiento no funciona
            //https://stackoverflow.com/a/45623878/2928690
            consumer.poll(0);
            consumer.seekToEnd(Collections.emptySet());
            consumer.poll(100);
            result = consumer.position(this.partition);

        } catch (Exception e) {

        } finally {

        }
        return result;
    }

}


