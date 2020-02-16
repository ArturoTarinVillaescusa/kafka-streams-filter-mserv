package es.goldcar.kafka.streams.exceptionhandler;

import static es.goldcar.kafka.streams.constants.SarSensitiveDataRemoverConstants.DESERIALIZATION_EXCEPTION_HANDLER;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.streams.errors.LogAndFailExceptionHandler;
import org.apache.kafka.streams.processor.ProcessorContext;

@Slf4j
public class SarSensitiveDataRemoverExceptionHandler extends LogAndFailExceptionHandler {

    @Override
    public DeserializationHandlerResponse handle(ProcessorContext processorContext, ConsumerRecord<byte[], byte[]> consumerRecord,
        Exception e) {
        log.error(DESERIALIZATION_EXCEPTION_HANDLER);
        return null;
    }

}
