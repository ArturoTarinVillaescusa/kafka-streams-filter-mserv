package com.goldcar;

import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
import static com.github.tomakehurst.wiremock.client.WireMock.equalToJson;
import static com.github.tomakehurst.wiremock.client.WireMock.get;
import static com.github.tomakehurst.wiremock.client.WireMock.post;
import static com.github.tomakehurst.wiremock.client.WireMock.urlMatching;
import static com.github.tomakehurst.wiremock.client.WireMock.urlPathMatching;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.wireMockConfig;
import static com.github.tomakehurst.wiremock.http.RequestMethod.POST;
import static org.apache.commons.lang3.StringUtils.strip;
import static org.wiremock.webhooks.Webhooks.webhook;

import com.github.tomakehurst.wiremock.WireMockServer;
import com.github.tomakehurst.wiremock.client.MappingBuilder;
import org.wiremock.webhooks.Webhooks;

public class MockServerFitnesse {

    private WireMockServer wireMockServer;

    public MockServerFitnesse(String port) {
        wireMockServer = new WireMockServer(wireMockConfig().port(Integer.parseInt(port)).extensions(new Webhooks()));
        startMockServer();
    }

    private void startMockServer() {
        wireMockServer.start();
    }

    public void stopMockServer() {
        wireMockServer.stop();
    }

    public void getRequestWithPathAndResponseAndStatus(String path, String response, int status) {
        wireMockServer.stubFor(
                get(urlMatching(path))
                        .willReturn(
                                aResponse().withBody(response)
                                        .withStatus(status)
                        )
        );
    }

    public void postRequestWithPathAndResponseBodyAndStatus(String path, String response, int status) {
        wireMockServer.stubFor(postWithPathAndResponseBodyAndStatus(path, response, status));
    }

    public void postRequestWithPathAndRequestBodyAndResponseBodyAndStatus(String path, String jsonRequestBody, String response,
        String status) {
        wireMockServer.stubFor(post(urlMatching(path))
            .withRequestBody(equalToJson(jsonRequestBody, true, true))
            .willReturn(aResponse().withBody(response).withStatus(Integer.parseInt(status))));
    }

    public void postRequestWithPathAndResponseBodyAndStatusAndScheduleRequestToWithBody(String path, String response,
        String status, String webHookTargetUrl, String webHookRequestBody) {

        wireMockServer.stubFor(postWithPathAndResponseBodyAndStatus(path, response, Integer.parseInt(status))
            .withPostServeAction("webhook",
                webhook()
                    .withMethod(POST)
                    .withUrl(webHookTargetUrl)
                    .withHeader("Content-Type", "application/json")
                    .withBody(trimJson(webHookRequestBody))
            )
        );
    }

    private String trimJson(String webHookRequestBody) {
        String json = webHookRequestBody;
        json = strip(json, "<pre>");
        json = strip(json, "</pre>");
        json = strip(json, "<br/>");
        return json;
    }

    private MappingBuilder postWithPathAndResponseBodyAndStatus(String path, String response, int status) {
        return post(urlMatching(path))
            .willReturn(aResponse().withBody(response).withStatus(status));
    }
}
