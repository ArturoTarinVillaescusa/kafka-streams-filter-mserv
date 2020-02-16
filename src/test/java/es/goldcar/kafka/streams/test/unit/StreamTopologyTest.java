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

import static org.junit.Assert.assertNotNull;

import es.goldcar.kafka.streams.test.utils.InfiniteLoopJsonProducer;
import java.time.Duration;
import java.util.Properties;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.TopologyTestDriver;
import org.apache.kafka.streams.processor.Processor;
import org.apache.kafka.streams.processor.ProcessorContext;
import org.apache.kafka.streams.processor.ProcessorSupplier;
import org.apache.kafka.streams.processor.PunctuationType;
import org.apache.kafka.streams.state.KeyValueIterator;
import org.apache.kafka.streams.state.KeyValueStore;
import org.apache.kafka.streams.state.Stores;
import org.junit.Test;

public class StreamTopologyTest {

    private TopologyTestDriver testDriver;
    private KeyValueStore<String, String> dummyStream;

    private String jsonSAR = InfiniteLoopJsonProducer.readJsonSample("src/main/resources/json/JSONMensaje1250SAR.json");

    @Test
    public void buildStreamTopologyShouldWork() {
        Topology topology = new Topology();
        topology.addSource("sourceProcessor", "dummy-input-topic");
        topology.addProcessor("map", new CustomMapSupplier(), "sourceProcessor");
        topology.addStateStore(
            Stores.keyValueStoreBuilder(
                Stores.inMemoryKeyValueStore("jsonSARStore"),
                Serdes.String(),
                Serdes.String()).withLoggingDisabled(), // need to disable logging to allow dummyStream pre-populating
            "map");
        topology.addSink("sinkProcessor", "dummy-output-topic", "map");

        // setup test driver
        Properties props = new Properties();
        props.setProperty(StreamsConfig.APPLICATION_ID_CONFIG, "OfuscadorJsonSAR");
        props.setProperty(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "hostdummy:9092");
        props.setProperty(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        props.setProperty(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        testDriver = new TopologyTestDriver(topology, props);
        assertNotNull(testDriver);

        // pre-populate dummyStream
        dummyStream = testDriver.getKeyValueStore("jsonSARStore");
        dummyStream.put("record-1", jsonSAR);
        assertNotNull(dummyStream);
    }

    public static class CustomMapSupplier implements ProcessorSupplier<String, String> {

        @Override
        public Processor<String, String> get() {
            return new CustomMap();
        }
    }

    public static class CustomMap implements Processor<String, String> {

        ProcessorContext context;
        private KeyValueStore<String, String> store;

        @SuppressWarnings("unchecked")
        @Override
        public void init(ProcessorContext context) {
            this.context = context;
            context.schedule(Duration.ofSeconds(60), PunctuationType.WALL_CLOCK_TIME, time -> flushStore());
            context.schedule(Duration.ofSeconds(10), PunctuationType.STREAM_TIME, time -> flushStore());
            store = (KeyValueStore<String, String>) context.getStateStore("jsonSARStore");
        }

        @Override
        public void process(String key, String value) {
            String oldValue = store.get(key);
            if (oldValue == null) {
                store.put(key, value);
            }
        }

        private void flushStore() {
            KeyValueIterator<String, String> it = store.all();
            while (it.hasNext()) {
                KeyValue<String, String> next = it.next();
                context.forward(next.key, next.value);
            }
        }

        @Override
        public void close() {
        }
    }
}
