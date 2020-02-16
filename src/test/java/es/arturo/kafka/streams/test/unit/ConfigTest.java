/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package es.arturo.kafka.streams.test.unit;

import static org.apache.kafka.clients.consumer.ConsumerConfig.AUTO_OFFSET_RESET_CONFIG;
import static org.apache.kafka.clients.consumer.ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG;
import static org.apache.kafka.streams.StreamsConfig.APPLICATION_ID_CONFIG;
import static org.apache.kafka.streams.StreamsConfig.CACHE_MAX_BYTES_BUFFERING_CONFIG;
import static org.apache.kafka.streams.StreamsConfig.EXACTLY_ONCE;
import static org.apache.kafka.streams.StreamsConfig.PROCESSING_GUARANTEE_CONFIG;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import es.arturo.kafka.streams.utils.SarSensitiveDataRemoverConfig;

import java.io.IOException;
import java.util.Properties;
import org.junit.Before;
import org.junit.Test;

public class ConfigTest {

    private Properties config;

    @Before
    public void setup() throws IOException {
        config = new SarSensitiveDataRemoverConfig().getConfiguration();
        assertNotNull(config);
    }

    @Test
    public void getConfigShouldWork() {
        assertEquals("SARSENSITIVEDATAREMOVER", config.getProperty(APPLICATION_ID_CONFIG));
        assertEquals("localhost:9092", config.getProperty(BOOTSTRAP_SERVERS_CONFIG));
        assertEquals("earliest", config.getProperty(AUTO_OFFSET_RESET_CONFIG));
        assertEquals("0", config.getProperty(CACHE_MAX_BYTES_BUFFERING_CONFIG));
        assertEquals(EXACTLY_ONCE, config.getProperty(PROCESSING_GUARANTEE_CONFIG));
    }

}
