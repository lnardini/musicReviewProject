package com.company;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {
    static final String URL = "";
    static String user = "";
    static String pass = "";
    static Scanner input = new Scanner(System.in);
    static final String USAGE = " ";

    // Argument String constants
    static final String ALLGENRE = "-allGenre";
    static final String ANYGENRE = "-anyGenre";
    static final String AUTHOR = "-author";
    static final String SORT = "-sort";


    public static void main(String[] args) {
        System.out.println("Enter the MySql username");
        user = input.next();
        System.out.println("Enter the MySql password");
        pass = input.next();


        try(Connection conn = DriverManager.getConnection(URL, user, pass);
            Statement stmt = conn.createStatement()) {
            System.out.println("Connection successful!");


            // Beginning loop
            // Idea: repeatedly take in commands and exexute them until user logs out
            while (true) {
                System.out.println("Please enter your next command. Enter 'help' for usage information or 'quit' to terminate the application.");
                String command = input.next();

                if (command.equalsIgnoreCase("quit")) {
                    break;
                }
                else if (command.equalsIgnoreCase("help")) {
                    System.out.println(USAGE);
                    break;
                }
                Map<String, List<String>> arguments = Main.parseCommand(command);
                // TODO: Use arguments to construct query
            }


        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    static Map<String, List<String>> parseCommand(String command) {
        Map<String, List<String>> args = new HashMap<>();
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        // TODO: Parse arguments into usable map
        return args;
    }
}
