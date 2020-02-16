package com.goldcar;

import com.jayway.jsonpath.*;
import org.apache.commons.lang3.StringEscapeUtils;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.diff.Diff;
import org.xmlunit.diff.Difference;

import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ComplexValuesComparer {
    private static final Pattern PRE_FORMATTED_PATTERN = Pattern.compile("<pre>\\s*(.*?)\\s*</pre>", Pattern.DOTALL);

    public ComplexValuesComparer() {

    }

    public String parseJSONAndSearch(String jsonDataSource, String jsonPath) {
        String foundData = "ERROR";
        try {
            DocumentContext jsonContext = JsonPath.parse(jsonDataSource);
            if (jsonContext.read(jsonPath) == null) foundData = "null";
            else foundData = jsonContext.read(jsonPath).toString();
        }
        catch (Exception e) {
            foundData = e.toString();
        }
        return foundData;
    }

    public String compareXML(String xmlExpected, String xmlActual) {

        String xmlExpectedClean = cleanupPreFormatted(xmlExpected);
        String xmlActualClean = cleanupPreFormatted(xmlActual);
        String result = Boolean.TRUE.toString();

        Diff myDiff = DiffBuilder.compare(xmlActualClean).withTest(xmlExpectedClean).ignoreWhitespace().build();

        if (myDiff.hasDifferences()) {
            result = "ERROR: ";
            Iterator<Difference> iter = myDiff.getDifferences().iterator();
            int size = 0;
            while (iter.hasNext()) {
                result += iter.next().toString() + " ";
                size++;
            }
        }
        return result;
    }


    protected String cleanupPreFormatted(String value) {
        String result = value;
        if (value != null) {
            Matcher matcher = PRE_FORMATTED_PATTERN.matcher(value);
            if (matcher.matches()) {
                String escapedBody = matcher.group(1);
                result = StringEscapeUtils.unescapeHtml4(escapedBody);
            }
        }
        return result;
    }
    
}
