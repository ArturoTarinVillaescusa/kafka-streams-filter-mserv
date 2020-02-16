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
package es.goldcar.kafka.streams.test.unit;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import es.goldcar.kafka.streams.service.SarSensitiveDataRemoverKafkaStreamsFactory;
import es.goldcar.kafka.streams.service.SarSensitiveDataRemoverService;
import es.goldcar.kafka.streams.utils.SarSensitiveDataRemoverConfig;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.Topology;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class SarSensitiveDataRemoverServiceTest {

    @Mock
    private SarSensitiveDataRemoverConfig configuration;
    @Mock
    private Topology topology;
    @Mock
    private SarSensitiveDataRemoverKafkaStreamsFactory kafkaStreamsFactory;
    @Mock
    private KafkaStreams streams;

    @InjectMocks
    private SarSensitiveDataRemoverService service;

    @Before
    public void setUp() {
        when(kafkaStreamsFactory.createKafkaStreams(any(), any())).thenReturn(streams);
    }

    @Test
    public void testRun() {
        service.run();

        verify(streams, times(1)).start();
    }

}
