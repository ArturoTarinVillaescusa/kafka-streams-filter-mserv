package es.arturo.kafka.streams.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.inject.Inject;
import es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants;
import org.apache.kafka.streams.kstream.ValueMapper;

public class SarSensitiveDataRemoverDataFilter implements ValueMapper<JsonNode, JsonNode> {

    private JsonNodeFactory jsonNodeFactory;
    private StringXMLSensitiveDataRemover stringXMLSensitiveDataRemover;

    @Inject
    public SarSensitiveDataRemoverDataFilter(JsonNodeFactory jsonNodeFactory,
        StringXMLSensitiveDataRemover stringXMLSensitiveDataRemover) {
        this.jsonNodeFactory = jsonNodeFactory;
        this.stringXMLSensitiveDataRemover = stringXMLSensitiveDataRemover;
    }

    @Override
    public JsonNode apply(JsonNode jsonSARWithSensitiveData) {

        ObjectNode jsonSARFiltrado = jsonNodeFactory.objectNode();

        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.UMID_TAG,
            jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.UMID_TAG).asText());
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.START_DATE_TIME_TAG,
            jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.START_DATE_TIME_TAG).asText());
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.END_DATE_TIME_TAG,
            jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.END_DATE_TIME_TAG).asText());
        int operationId = jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.OPERATION_ID_TAG).asInt();
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.OPERATION_ID_TAG, operationId);
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.AGENCY_ID_TAG,
            jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.AGENCY_ID_TAG).asText());
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.XML_IN_TAG,
            stringXMLSensitiveDataRemover.removeSensitiveData(operationId,
                jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.XML_IN_TAG).asText()));
        jsonSARFiltrado.put(SarSensitiveDataRemoverConstants.XML_OUT_TAG,
            stringXMLSensitiveDataRemover.removeSensitiveData(operationId,
                jsonSARWithSensitiveData.get(SarSensitiveDataRemoverConstants.XML_OUT_TAG).asText()));

        return jsonSARFiltrado;
    }

}
