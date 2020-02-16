package es.arturo.kafka.streams.service;

import es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants;

import java.util.ArrayList;
import java.util.Optional;

public class StringXMLSensitiveDataRemover {

    private static boolean isSensitiveOperation(int operationId) {
        return operationId != SarSensitiveDataRemoverConstants.GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID;
    }

    private static String removeSensitiveTag(String xmlFiltrado, String tag) {
        final String beginTag = "<" + tag + ">";
        final String endTag = "</" + tag + ">";

        return xmlFiltrado.replaceAll(beginTag + "(.*?)" + endTag, "");
    }

    private static String removePassword(String xmlWithSensitiveData) {
        return removeSensitiveTag(xmlWithSensitiveData, SarSensitiveDataRemoverConstants.PASS_WORD_TAG);
    }

    public String removeSensitiveData(int operationId, String xmlWithSensitiveData) {

        String filteredXML = removePassword(xmlWithSensitiveData);

        if (isSensitiveOperation(operationId)) {
            ArrayList<String> arrayToReduce = new ArrayList<>(SarSensitiveDataRemoverConstants.getSensitiveDataTags());

            arrayToReduce.add(0, filteredXML);

            Optional<String> xmlWithoutSensibleData = arrayToReduce.stream().reduce(
                StringXMLSensitiveDataRemover::removeSensitiveTag);

            filteredXML = xmlWithoutSensibleData.orElse(filteredXML);
        }

        return filteredXML;
    }
}
