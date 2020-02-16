package com.goldcar;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class ExecuteShellCommand {

    private String FCommand = "";

    public static void main(String[] args) {

        ExecuteShellCommand obj = new ExecuteShellCommand();

        obj.setCommand("C:\\Redis\\redis-cli.exe dbsize");
        String cadena = obj.CommandOutput();

        System.out.println(cadena);

    }

    public void setCommand(String pCommand){
        FCommand = pCommand;
    }

    public String CommandOutput() {

        StringBuffer output = new StringBuffer();

        Process p;
        try {
            p = Runtime.getRuntime().exec(FCommand);
            p.waitFor();
            BufferedReader reader =
                    new BufferedReader(new InputStreamReader(p.getInputStream()));

            String line = "";
            while ((line = reader.readLine())!= null) {
                output.append(line + "\n");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return output.toString();

    }

}