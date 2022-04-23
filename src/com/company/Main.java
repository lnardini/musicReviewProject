package com.company;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {
    static final String URL = "";
    static String mySqlUser = "";
    static String mySqlPass = "";
    static Scanner input = new Scanner(System.in);
    static final String USAGE = " ";


    static String accountUsername = "";
    static String accountPassword = "";

    // Argument String constants
    static final String ALLGENRE = "--allGenre";
    static final String ANYGENRE = "--anyGenre";
    static final String AUTHOR = "--author";
    static final String SORT = "--sort";
    static final Date currentDate = new Date(System.currentTimeMillis());

    static final List<String> FLAGS = Arrays.asList(ALLGENRE, ANYGENRE, AUTHOR, SORT);


    public static void main(String[] args) {
        System.out.println("Enter the MySql username");
        mySqlUser = input.next();
        System.out.println("Enter the MySql password");
        mySqlPass = input.next();


        try(Connection conn = DriverManager.getConnection(URL, mySqlUser, mySqlPass);
            Statement stmt = conn.createStatement()) {
            System.out.println("Connection successful!");

            // Account
            ResultSet accounts = stmt.executeQuery("SELECT * FROM musicReview.reviewerUser;");
            List<String[]> accountInfo = new ArrayList<>(); // [username, userPassword, email]
            while (accounts.next()) {
                accountInfo.add(new String[]{
                        accounts.getString("username"),
                        accounts.getString("userPassword"),
                        accounts.getString("email"),
                        accounts.getString("name")
                });
            }

            System.out.println("Would you like to create a new account? (y/n) If not, you will be prompted to sign in with an existing one.");
            if (input.next().equalsIgnoreCase("y")) {
                String[] newAccount = createAccount(accountInfo);
                stmt.executeQuery(String.format("INSERT INTO reviewerUser VALUES(%s, %s, %s, %s, %s);",
                        newAccount[0],
                        newAccount[1],
                        newAccount[2],
                        currentDate,
                        newAccount[3]));
                accountInfo.add(newAccount);
            }

            // logging in
            boolean loggedIn = false;
            while (!loggedIn) {
                System.out.println("Enter the MySql username");
                accountUsername = input.next();
                System.out.println("Enter the MySql password");
                accountPassword = input.next();

                for (String[] account : accountInfo) {
                    if (account[0].equals(accountUsername) && account[1].equals(accountPassword)) {
                        loggedIn = true;
                        break;
                    }
                }
            }
            System.out.println("Logged in successfully");



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
     * Creates an account for the provided user, adding it to the provided list of accounts
     * @param accountInfo the information of the other accounts (to ensure no repeated usernames or emails)
     */
    static String[] createAccount(List<String[]> accountInfo) {
        return null;
        // TODO: Prompt user for username, password, email, and full name. Ensure username and email are unique. Return array of these items
    }

    /**
     * Takes in a review command and prompts the user for review input
     * @param command
     * @return The SQL command for adding a review
     */
    static String createReviewCommand(String command) {
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        String reviewStr = "INSERT INTO %s VALUES (%f, %s, %s, %t, %d)";
        String entityType = argList.get(1);
        String table = entityType.toLowerCase().concat("Review");
        String entityName = argList.get(2);

        System.out.println("What would you rate " + entityName + "?");
        double stars = 0.0;
        do {
            System.out.println("Enter the number of stars between 0.5 to 5");
            stars = input.nextDouble();
        } while (stars > 5.0 || stars < 0.5);

        System.out.println("Please enter a brief (<256 char) description of the " + entityType + " or press 'Enter' to skip.");
        String description = input.nextLine();
        String reviewer = accountUsername;
        int entityId = -1;//TODO
        return String.format(reviewStr, table, stars, description, reviewer, currentDate, entityId);
    }


    static Map<String, List<String>> parseCommand(String command) {
        Map<String, List<String>> args = new HashMap<>();
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
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
