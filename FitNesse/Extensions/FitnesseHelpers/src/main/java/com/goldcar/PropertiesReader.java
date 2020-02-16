package com.goldcar;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class PropertiesReader {

    private Properties properties;

    public PropertiesReader(String file) throws IOException {
        properties = new Properties();
        properties.load(new FileInputStream(file));
    }

    public String getProperty(String property) {
        return properties.getProperty(property);
    }
}
