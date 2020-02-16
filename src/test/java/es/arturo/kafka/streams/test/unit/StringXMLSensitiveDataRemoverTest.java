package es.arturo.kafka.streams.test.unit;

import static es.arturo.kafka.streams.constants.SarSensitiveDataRemoverConstants.GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID;
import static org.junit.Assert.assertEquals;

import es.arturo.kafka.streams.service.StringXMLSensitiveDataRemover;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.Silent.class)
public class StringXMLSensitiveDataRemoverTest {

    @InjectMocks
    private StringXMLSensitiveDataRemover stringXMLSensitiveDataRemover;

    @Test
    public void testRemoveSensitiveData_NoSensitiveDataAndNoPassword() {
        String inputData = "<xml><tag1><tag2>value2</tag2><tag3>value3</tag3><tag4>value4</tag4></tag1>";
        String expectedOutput = "<xml><tag1><tag2>value2</tag2><tag3>value3</tag3><tag4>value4</tag4></tag1>";

        String filteredString = stringXMLSensitiveDataRemover
            .removeSensitiveData(GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID, inputData);

        assertEquals(expectedOutput, filteredString);
    }

    @Test
    public void testRemoveSensitiveData_NoSensitiveDataButPassword() {
        String inputData = "<xml><tag1><Password>value2</Password><tag3>value3</tag3><tag4>value4</tag4></tag1>";
        String expectedOutput = "<xml><tag1><tag3>value3</tag3><tag4>value4</tag4></tag1>";

        String filteredString = stringXMLSensitiveDataRemover
            .removeSensitiveData(GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID, inputData);

        assertEquals(expectedOutput, filteredString);
    }

    @Test
    public void testRemoveSensitiveData_SensitiveDataAndSensitiveOperation() {

        String inputData = "<xml><tag1><Password>value2</Password><Email>value3</Email><tag4>value4</tag4><ConfirmationsEmail><tag6>value6</tag6></ConfirmationsEmail></tag1>";
        String expectedOutput = "<xml><tag1><tag4>value4</tag4></tag1>";

        String filteredString = stringXMLSensitiveDataRemover.removeSensitiveData(1150, inputData);

        assertEquals(expectedOutput, filteredString);
    }

    @Test
    public void testRemoveSensitiveData_SensitiveDataButNoSensitiveOperation() {

        String inputData = "<xml><tag1><Password>value2</Password><Email>value3</Email><tag4>value4</tag4><ConfirmationsEmail><tag6>value6</tag6></ConfirmationsEmail></tag1>";
        String expectedOutput = "<xml><tag1><Email>value3</Email><tag4>value4</tag4><ConfirmationsEmail><tag6>value6</tag6></ConfirmationsEmail></tag1>";

        String filteredString = stringXMLSensitiveDataRemover
            .removeSensitiveData(GET_ALL_GROUPS_RESERVATION_AVAILABILITY_AND_RATES_OPERATION_ID, inputData);

        assertEquals(expectedOutput, filteredString);
    }
}
