package com.company;

import com.mysql.cj.x.protobuf.MysqlxPrepare;

import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {
    static final String URL = "";
    static String user = "";
    static String pass = "";
    static Scanner input = new Scanner(System.in);
    static final String USAGE = " ";

    // Argument String constants
    static final String ALLGENRE = "--allGenre";
    static final String ANYGENRE = "--anyGenre";
    static final String AUTHOR = "--author";
    static final String SORT = "--sort";

    static final List<String> FLAGS = Arrays.asList(ALLGENRE, ANYGENRE, AUTHOR, SORT);


    public static void main(String[] args) {
        System.out.println("Enter the MySql username");
        user = input.next();
        System.out.println("Enter the MySql password");
        pass = input.next();


        try(Connection conn = DriverManager.getConnection(URL, user, pass);
            Statement stmt = conn.createStatement()) {
            System.out.println("Connection successful!");


            // Beginning loop
            // Idea: repeatedly take in commands and execute them until user logs out
            while (true) {
                System.out.println("Please enter your next command. Enter 'help' for usage information or 'quit' to terminate the application.");
                String command = input.next();

                if (command.equalsIgnoreCase("quit")) {
                    break;
                }
                else if (command.equalsIgnoreCase("help")) {
                    System.out.println(USAGE);
                    continue;
                }
                Map<String, List<String>> arguments = Main.parseCommand(command);
                // TODO: Use arguments to construct query
            }


        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Takes in a review command and prompts the user for review input
     * @param command
     * @return The SQL command for adding a review
     */
    static String createReviewCommand(String command) {
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        String reviewStr = "INSERT INTO %s VALUES (%f, %s, %s, %t, %d)";


        return reviewStr;
    }


    static Map<String, List<String>> parseCommand(String command) {
        Map<String, List<String>> args = new HashMap<>();
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        // TODO: Parse arguments into usable map
        String baseCmd = argList.get(0);
        args.put("COMMAND", Arrays.asList(baseCmd));
        // parsing options
        for (int i = 1; i < argList.size(); i++) {
            String arg = argList.get(i);
            if (!arg.startsWith("--")) { // not flag argument
                continue;
            }
            List<String> values = new ArrayList<>();
            int j = i + 1;
            while (j < argList.size() && !argList.get(j).startsWith("--")) {
                values.add(argList.get(j));
                j+= 1;
            }
            if (FLAGS.contains(arg)) {
                args.put(arg, values);
            } else {
                   //TODO: Unrecognized flag
            }
        }

        return args;
    }
}
