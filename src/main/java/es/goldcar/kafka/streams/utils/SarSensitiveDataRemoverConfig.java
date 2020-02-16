package es.goldcar.kafka.streams.utils;

import es.goldcar.kafka.streams.exceptionhandler.SarSensitiveDataRemoverExceptionHandler;
import lombok.Getter;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.processor.WallclockTimestampExtractor;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class SarSensitiveDataRemoverConfig {

    @Getter
    private final Properties configuration;

    public SarSensitiveDataRemoverConfig() throws IOException {
        configuration = new Properties();

        final InputStream properties = getClass().getClassLoader().getResourceAsStream("application.properties");
        configuration.load(properties);
        configuration.put(StreamsConfig.DEFAULT_TIMESTAMP_EXTRACTOR_CLASS_CONFIG,
                WallclockTimestampExtractor.class);
        configuration.put(StreamsConfig.DEFAULT_DESERIALIZATION_EXCEPTION_HANDLER_CLASS_CONFIG,
            SarSensitiveDataRemoverExceptionHandler.class);
    }

}
