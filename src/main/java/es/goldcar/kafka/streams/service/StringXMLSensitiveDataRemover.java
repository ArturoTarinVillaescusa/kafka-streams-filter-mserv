package es.goldcar.kafka.streams.service;

import static es.goldcar.kafka.streams.constants.SarSensitiveDataRemoverConstants.GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID;
import static es.goldcar.kafka.streams.constants.SarSensitiveDataRemoverConstants.PASS_WORD_TAG;
import static es.goldcar.kafka.streams.constants.SarSensitiveDataRemoverConstants.getSensitiveDataTags;

import java.util.ArrayList;
import java.util.Optional;

public class StringXMLSensitiveDataRemover {

    private static boolean isSensitiveOperation(int operationId) {
        return operationId != GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID;
    }

    private static String removeSensitiveTag(String xmlFiltrado, String tag) {
        final String beginTag = "<" + tag + ">";
        final String endTag = "</" + tag + ">";

        return xmlFiltrado.replaceAll(beginTag + "(.*?)" + endTag, "");
    }

    private static String removePassword(String xmlWithSensitiveData) {
        return removeSensitiveTag(xmlWithSensitiveData, PASS_WORD_TAG);
    }

    public String removeSensitiveData(int operationId, String xmlWithSensitiveData) {

        String filteredXML = removePassword(xmlWithSensitiveData);

        if (isSensitiveOperation(operationId)) {
            ArrayList<String> arrayToReduce = new ArrayList<>(getSensitiveDataTags());

            arrayToReduce.add(0, filteredXML);

            Optional<String> xmlWithoutSensibleData = arrayToReduce.stream().reduce(
                StringXMLSensitiveDataRemover::removeSensitiveTag);

            filteredXML = xmlWithoutSensibleData.orElse(filteredXML);
        }

        return filteredXML;
    }
}
