package es.arturo.kafka.streams.test.integration;

import static org.junit.Assert.assertEquals;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.inject.Guice;
import com.google.inject.Injector;
import es.arturo.kafka.streams.service.SarSensitiveDataRemoverDataFilter;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;

public class SarSensitiveDataRemoverDataFilterIntegrationTest {

    private static final String INPUT_DATA = "{\n" +
        "    \"UMID\": \"U1T10000000003324607\",\n" +
        "    \"StartDateTime\": \"2017-09-19T17:41:46\",\n" +
        "    \"EndDateTime\": \"2017-09-19T17:41:47\",\n" +
        "    \"OperationID\": 1150,\n" +
        "    \"AgencyID\": \"02343-01\",\n" +
        "    \"XMLIn\": \"<?xml version='1.0'?><BookReservationRQ xmlns='http://sarsis.goldcar.es/SARSISD/Esquemas' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://sarsis.goldcar.es/SARSISD/Esquemas http://sarsis.goldcar.es/SARSISD/Esquemas/GOLDCAR_BookReservation.xsd'><Authentication><Code>50000-00</Code><Password>clavedelmensaje1150</Password><Encrypted>true</Encrypted></Authentication><Reservation><AgencyVoucherReference>WG3004791E</AgencyVoucherReference><PromotionalCode>CARNIVAL2019</PromotionalCode><Customer><CustomerName><Name>Graham</Name><Surname>Chivers</Surname></CustomerName><GeneralAddress><Address>28 lane end road</Address><Town>high wycombe</Town><PostCode>hp124jf</PostCode><Country>GB</Country></GeneralAddress><Passport><Number>605360512436178</Number></Passport><Nationality>GB</Nationality><Language>EN</Language><Birth><Date>1949-03-08</Date> <Country>GB</Country></Birth><Email>gchivs@btopenworld.com</Email><Phone></Phone><IDGoldcarMember>3900056830</IDGoldcarMember></Customer><Vehicle><CarGroup>D</CarGroup></Vehicle><PickUp><Location><Place>ALC</Place><Date>2019-06-19</Date><Time>09:30</Time></Location><Type>Flight</Type><FlightNumber>ezy2223</FlightNumber><ExpressService>false</ExpressService></PickUp><DropOff><Place>ALC</Place><Date>2019-07-06</Date><Time>22:00</Time></DropOff><Remarks> - MIEMBRO CLUB GOLDCAR 3900056830</Remarks><Market>Inbound</Market><EconomicData><AgencyPrice>79.592</AgencyPrice><RentalNetRateWithTaxes>79.592</RentalNetRateWithTaxes><AgencyPriceNoCommissionable>0</AgencyPriceNoCommissionable><FuelPolicy>FlexFuelSDR</FuelPolicy></EconomicData><ExtrasPackages><PackageReservationData><PackageReference>15091</PackageReference><AgencyPrice>0</AgencyPrice></PackageReservationData></ExtrasPackages></Reservation></BookReservationRQ>\",\n" +
        "    \"XMLOut\": \"<?xml version='1.0' encoding='ISO-8859-1'?><BookReservationRS xmlns='http://sarsis.goldcar.es/SARSISD/Esquemas' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://sarsis.goldcar.es/SARSISD/Esquemas http://sarsis.goldcar.es/SARSISD/Esquemas/GOLDCAR_BookReservation.xsd'><UMID>U1E30000000164791723</UMID><AgencyVoucherReference>IT521288390</AgencyVoucherReference><Status><Code>Confirmed</Code><BookingConfirmation><SearchQuery><UMID>U1F80000000089351083</UMID></SearchQuery><CustomerName><Name>Greco</Name><Surname>Esterino</Surname></CustomerName><GoldcarReference>15970644</GoldcarReference><Arrival><Place>BGY</Place><Date>2019-04-17</Date><Time>14:30</Time></Arrival><Return><Place>BGY</Place><Date>2019-04-18</Date><Time>21:00</Time></Return><Vehicle><CarGroup>D</CarGroup></Vehicle><PickUpConfirmation><PickUp>WalkIn</PickUp><ExpressService>false</ExpressService></PickUpConfirmation><RentalDays>2</RentalDays><RentalPrice>0</RentalPrice><Remarks></Remarks><Market>Domestic</Market><ReservationDateTime>2019-02-21T12:27:43</ReservationDateTime><FuelPolicy>FullFuelSDC</FuelPolicy></BookingConfirmation></Status></BookReservationRS>\"\n" +
        "}";
    private static final String OUTPUT_DATA = "{\n" +
        "    \"UMID\": \"U1T10000000003324607\",\n" +
        "    \"StartDateTime\": \"2017-09-19T17:41:46\",\n" +
        "    \"EndDateTime\": \"2017-09-19T17:41:47\",\n" +
        "    \"OperationID\": 1150,\n" +
        "    \"AgencyID\": \"02343-01\",\n" +
        "    \"XMLIn\": \"<?xml version='1.0'?><BookReservationRQ xmlns='http://sarsis.goldcar.es/SARSISD/Esquemas' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://sarsis.goldcar.es/SARSISD/Esquemas http://sarsis.goldcar.es/SARSISD/Esquemas/GOLDCAR_BookReservation.xsd'><Authentication><Code>50000-00</Code><Encrypted>true</Encrypted></Authentication><Reservation><AgencyVoucherReference>WG3004791E</AgencyVoucherReference><PromotionalCode>CARNIVAL2019</PromotionalCode><Vehicle><CarGroup>D</CarGroup></Vehicle><PickUp><Location><Place>ALC</Place><Date>2019-06-19</Date><Time>09:30</Time></Location><Type>Flight</Type><FlightNumber>ezy2223</FlightNumber><ExpressService>false</ExpressService></PickUp><DropOff><Place>ALC</Place><Date>2019-07-06</Date><Time>22:00</Time></DropOff><Remarks> - MIEMBRO CLUB GOLDCAR 3900056830</Remarks><Market>Inbound</Market><EconomicData><AgencyPrice>79.592</AgencyPrice><RentalNetRateWithTaxes>79.592</RentalNetRateWithTaxes><AgencyPriceNoCommissionable>0</AgencyPriceNoCommissionable><FuelPolicy>FlexFuelSDR</FuelPolicy></EconomicData><ExtrasPackages><PackageReservationData><PackageReference>15091</PackageReference><AgencyPrice>0</AgencyPrice></PackageReservationData></ExtrasPackages></Reservation></BookReservationRQ>\",\n" +
        "    \"XMLOut\": \"<?xml version='1.0' encoding='ISO-8859-1'?><BookReservationRS xmlns='http://sarsis.goldcar.es/SARSISD/Esquemas' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://sarsis.goldcar.es/SARSISD/Esquemas http://sarsis.goldcar.es/SARSISD/Esquemas/GOLDCAR_BookReservation.xsd'><UMID>U1E30000000164791723</UMID><AgencyVoucherReference>IT521288390</AgencyVoucherReference><Status><Code>Confirmed</Code><BookingConfirmation><SearchQuery><UMID>U1F80000000089351083</UMID></SearchQuery><GoldcarReference>15970644</GoldcarReference><Arrival><Place>BGY</Place><Date>2019-04-17</Date><Time>14:30</Time></Arrival><Return><Place>BGY</Place><Date>2019-04-18</Date><Time>21:00</Time></Return><Vehicle><CarGroup>D</CarGroup></Vehicle><PickUpConfirmation><PickUp>WalkIn</PickUp><ExpressService>false</ExpressService></PickUpConfirmation><RentalDays>2</RentalDays><RentalPrice>0</RentalPrice><Remarks></Remarks><Market>Domestic</Market><ReservationDateTime>2019-02-21T12:27:43</ReservationDateTime><FuelPolicy>FullFuelSDC</FuelPolicy></BookingConfirmation></Status></BookReservationRS>\"\n" +
        "}";
    private SarSensitiveDataRemoverDataFilter sarSensitiveDataRemoverDataFilter;
    private ObjectMapper mapper;

    @Before
    public void setUp() {
        Injector container = Guice.createInjector();
        sarSensitiveDataRemoverDataFilter = container.getInstance(SarSensitiveDataRemoverDataFilter.class);
        mapper = new ObjectMapper();
    }

    @Test
    public void testFilterJsonSAR_SensitiveDataAndSensitiveOperation() throws IOException {
        JsonNode input = mapper.readValue(INPUT_DATA, JsonNode.class);
        JsonNode expected = mapper.readValue(OUTPUT_DATA, JsonNode.class);

        JsonNode actual = sarSensitiveDataRemoverDataFilter.apply(input);

        assertEquals(expected, actual);
    }
}
