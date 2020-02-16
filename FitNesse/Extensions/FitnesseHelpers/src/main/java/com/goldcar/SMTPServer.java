package com.goldcar;

import static com.icegreen.greenmail.util.ServerSetup.PROTOCOL_SMTP;

import com.icegreen.greenmail.configuration.GreenMailConfiguration;
import com.icegreen.greenmail.util.GreenMail;
import com.icegreen.greenmail.util.ServerSetup;

public class SMTPServer {

    private GreenMail greenMailServer;

    public SMTPServer(String port) {
        greenMailServer = new GreenMail(new ServerSetup(Integer.parseInt(port), null, PROTOCOL_SMTP))
            .withConfiguration(new GreenMailConfiguration().withDisabledAuthentication());
    }

    public void startSMTPServer() {
        greenMailServer.start();
    }

    public void stopSMTPServer() {
        greenMailServer.stop();
    }
}
