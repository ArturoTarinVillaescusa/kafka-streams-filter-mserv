package es.arturo.kafka.streams.constants;

import static java.util.Arrays.asList;

import java.util.List;

public final class SarSensitiveDataRemoverConstants {

    public static final String PASS_WORD_TAG = "Password";
    public static final String UMID_TAG = "UMID";
    public static final String START_DATE_TIME_TAG = "StartDateTime";
    public static final String END_DATE_TIME_TAG = "EndDateTime";
    public static final String OPERATION_ID_TAG = "OperationID";
    public static final String AGENCY_ID_TAG = "AgencyID";
    public static final String XML_IN_TAG = "XMLIn";
    public static final String XML_OUT_TAG = "XMLOut";
    public static final String SOURCE_TOPIC = "sar-req-res";
    public static final String DESTINATION_TOPIC = "sar-req-res-no-sensitive-data";
    // KAFKA BROKER STREAM SESSION INFORMATION
    public static final int GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID = 1250;
    public static final String DESERIALIZATION_EXCEPTION_HANDLER = "Error parsing Json";

    private SarSensitiveDataRemoverConstants() {
    }

    public static List<String> getSensitiveDataTags() {
        return asList("Customer", "CustomerName", "Name", "Surname", "Phone", "Phone2",
            "MobilePhone", "Sex", "Email", "AdministratorEmail", "ConfirmationsEmail", "CommunicationsEmail", "BillingEmail",
            "AdministrationEmail", "IncidencesEmail", "StopSalesEmail");
    }

}
