package es.arturo.kafka.streams;

import static es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants.DESTINATION_TOPIC;
import static es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants.SOURCE_TOPIC;

import com.google.inject.Guice;
import com.google.inject.Injector;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverServiceFactory;

public class MSSARSensitiveDataRemoverApplication {

    public static void main(String[] args) {
        Injector container = Guice.createInjector();

        SarSensitiveDataRemoverServiceFactory factory = container.getInstance(SarSensitiveDataRemoverServiceFactory.class);

        factory.create(SOURCE_TOPIC, DESTINATION_TOPIC).run();
    }
}
