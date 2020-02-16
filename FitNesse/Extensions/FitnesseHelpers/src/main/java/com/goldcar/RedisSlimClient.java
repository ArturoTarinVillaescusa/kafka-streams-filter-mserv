package com.goldcar;

import com.lambdaworks.redis.RedisClient;
import com.lambdaworks.redis.RedisURI;
import com.lambdaworks.redis.api.StatefulRedisConnection;
import com.lambdaworks.redis.api.async.RedisAsyncCommands;

/**
 * Created by alejandroaguilar on 26/10/2017.
 */
public class RedisSlimClient {

    private StatefulRedisConnection<String, String> connection = null;
    private String FKey = "";
    private int FTimeout = 10000;

    public RedisSlimClient(String ip, int port) {
        RedisClient redisClient = new RedisClient(
                RedisURI.create("redis://"+ip+":"+port));

        connection = redisClient.connect();
    }

    public void setKey(String pKey) {
        FKey = pKey;
    }

    public String Value() {
        return getValueFromKey(FKey);
    }

    public String TryValue() {
        String redisValue = null;
        int counter = 0;

        while (redisValue == null &&  counter < FTimeout) {
            redisValue = getValueFromKey(FKey);
            if (redisValue == null) {
                try
                {
                    Thread.sleep(250);
                }
                catch(InterruptedException ex)
                {
                    Thread.currentThread().interrupt();
                }
                counter += 250;
            }
        }
        return redisValue;
    }

    public String getValueFromKey(String pKey) {
        return connection.sync().get(pKey);
    }

    public void setValueFromKey(String pKey, String pValue) {
        RedisAsyncCommands<String, String> redisCmd = connection.async();
        redisCmd.set(pKey, pValue);
    }

    public String flushDB() {
        RedisAsyncCommands<String, String> redisCmd = connection.async();
        redisCmd.flushdb();
        return "OK";
    }

    public String getDBSize() {
        return connection.sync().dbsize().toString();
    }


}
