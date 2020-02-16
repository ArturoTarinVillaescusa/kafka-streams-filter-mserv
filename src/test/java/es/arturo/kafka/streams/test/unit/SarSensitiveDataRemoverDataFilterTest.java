package es.arturo.kafka.streams.test.unit;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverDataFilter;
import es.arturo.kafka.streams.service.StringXMLSensitiveDataRemover;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.Silent.class)
public class SarSensitiveDataRemoverDataFilterTest {

    @Mock
    JsonNodeFactory jsonNodeFactory;

    @Mock
    StringXMLSensitiveDataRemover stringXMLSensitiveDataRemover;

    @InjectMocks
    SarSensitiveDataRemoverDataFilter sarSensitiveDataRemoverDataFilter;

    @Test
    public void FilterJsonWithNoSensitiveTagButPassword() {

        ObjectNode filteredJSon = mock(ObjectNode.class);
        JsonNode jsonNode = mock(JsonNode.class);

        when(jsonNodeFactory.objectNode()).thenReturn(filteredJSon);
        when(jsonNode.get(anyString())).thenReturn(jsonNode);
        when(jsonNode.asText()).thenReturn("");
        when(stringXMLSensitiveDataRemover.removeSensitiveData(anyInt(), anyString())).thenReturn("");

        sarSensitiveDataRemoverDataFilter.apply(jsonNode);

        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.UMID_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.START_DATE_TIME_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.END_DATE_TIME_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.OPERATION_ID_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.AGENCY_ID_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.XML_IN_TAG);
        verify(jsonNode, times(1)).get(SarSensitiveDataRemoverConstants.XML_OUT_TAG);

        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.UMID_TAG, "");
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.START_DATE_TIME_TAG, "");
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.END_DATE_TIME_TAG, "");
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.OPERATION_ID_TAG, 0);
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.AGENCY_ID_TAG, "");
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.XML_IN_TAG, "");
        verify(filteredJSon, times(1)).put(SarSensitiveDataRemoverConstants.XML_OUT_TAG, "");

        verify(stringXMLSensitiveDataRemover, times(2)).removeSensitiveData(0, "");
    }

}
