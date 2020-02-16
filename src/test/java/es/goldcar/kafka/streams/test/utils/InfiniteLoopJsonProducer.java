package es.goldcar.kafka.streams.test.utils;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Properties;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InfiniteLoopJsonProducer {
    private static final Logger logger = Logger.getLogger( InfiniteLoopJsonProducer.class.getName() );

    public static void main(String[] args)  {
        Properties properties = new Properties();

        // kafka bootstrap server
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "alckafka01:9092");
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        // producer acks
        properties.setProperty(ProducerConfig.ACKS_CONFIG, "all"); // Maximum guarantee
        properties.setProperty(ProducerConfig.RETRIES_CONFIG, "3");
        properties.setProperty(ProducerConfig.LINGER_MS_CONFIG, "1");
        // We use Kafka's >=0.11 idempotence capability, to make sure the producer will not create duplicates
        properties.setProperty(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
        properties.put(ProducerConfig.CLIENT_ID_CONFIG, "SARProducer");


        Producer<String, String> kafkaProducer = new KafkaProducer<>(properties);
        // Don't use KafkaProducer.get() in production environments.
        // Use it in development environments just to check that writes in topics are sequential

        // THIS IS A BLOCKING COMMAND, SO IF YOU USE IT IN PRODUCTION, THEN YOU WILL BLOCK THE PRODUCTION STREAM


        String sourceTopic = "sar-req-res";

        int repeticiones = 200;
        int maxBatch = 100;

        for (int i = 1; i < repeticiones; i++) {
            for (int j = 1; j < maxBatch; j++) {

                final File folder = new File("src/test/resources/json");
                produceInKafkaAllTheJsonSamples(folder, maxBatch, sourceTopic, kafkaProducer, j);
            }
        }
        kafkaProducer.close();
    }

    public static void produceInKafkaAllTheJsonSamples(final File folder, int maxBatch, String topicoConDatosSensibles,
                                                       Producer<String, String> kafkaProducer, int j) {
        for (final File fileEntry : folder.listFiles()) {
            if (fileEntry.isDirectory()) {
                produceInKafkaAllTheJsonSamples(fileEntry, maxBatch, topicoConDatosSensibles, kafkaProducer, j);
            } else {

                String jsonSAR = readJsonSample(fileEntry.getAbsolutePath());


                ProducerRecord producerRecord = new ProducerRecord(topicoConDatosSensibles, null, jsonSAR);

                kafkaProducer.send(producerRecord);

                String message = "A batch of " + j + " " + fileEntry.getName() + " messages were sent";
                logger.log(Level.INFO, message);

            }
        }
    }


    public static String readJsonSample(String route) {


        String fileContent = "";
        try (Scanner input = new Scanner(new File(route))) {
            String line;
            StringBuilder bld = new StringBuilder();

            while(input.hasNextLine()) {
                line = input.nextLine();
                bld.append(line);
            }
            fileContent = bld.toString();

        } catch (FileNotFoundException e) {
            logger.log(Level.SEVERE, e.toString());
        }
        return fileContent;
    }

}
