package es.goldcar.kafka.streams.test.unit;

import static org.junit.Assert.assertNull;

import es.goldcar.kafka.streams.exceptionhandler.SarSensitiveDataRemoverExceptionHandler;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.streams.processor.ProcessorContext;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class ExceptionHandlerTest {

    @Mock
    private Exception e;

    @Mock
    private ProcessorContext processorContext;

    @Mock
    private ConsumerRecord<byte[], byte[]> consumerRecord;

    @InjectMocks
    private SarSensitiveDataRemoverExceptionHandler exceptionHandler;
    
    @Test
    public void handleShouldWork() {
        Object result = exceptionHandler.handle(processorContext, consumerRecord, e);
        assertNull(result);
    }

}
