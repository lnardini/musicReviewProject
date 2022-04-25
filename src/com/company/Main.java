package com.company;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {
    static final String URL = "jdbc:mysql://localhost/musicReview";
    static String mySqlUser = "root";
    static String mySqlPass = ""; // Enter your password here
    static Scanner input = new Scanner(System.in);
    static final String USAGE = "Temporary usage string";


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
        /**
        System.out.println("Enter the MySql username");
        mySqlUser = input.next();
        System.out.println("Enter the MySql password");
        mySqlPass = input.next();
         **/


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

            /**
            System.out.println("Would you like to create a new account? (y/n) If not, you will be prompted to sign in with an existing one.");
            if (input.next().equalsIgnoreCase("y")) {
                String[] newAccount = createAccount(accountInfo);
//                stmt.executeQuery(String.format("INSERT INTO reviewerUser VALUES(%s, %s, %s, %s, %s);",
//                        newAccount[0],
//                        newAccount[1],
//                        newAccount[2],
//                        currentDate,
//                        newAccount[3]));
                accountInfo.add(newAccount);
            }

            // logging in
            String name = "";
            boolean loggedIn = false;
            while (!loggedIn) {
                System.out.println("Enter the MySql username");
                accountUsername = input.next();
                System.out.println("Enter the MySql password");
                accountPassword = input.next();
                for (String[] account : accountInfo) {
                    if (account[0].equals(accountUsername) && account[1].equals(accountPassword)) {
                        loggedIn = true;
                        name = account[3];
                        break;
                    }
                }
            }
            System.out.println("Logged in successfully. Welcome " + name);
            **/


            // Beginning loop
            // Idea: repeatedly take in commands and execute them until user logs out
            while (true) {
                System.out.println("Please enter your next command. Enter 'help' for usage information or 'quit' to terminate the application.");
                String command = "";
                if (input.hasNextLine()) {
                    command = input.nextLine();
                }
                System.out.println("Command: " + command);

                if (command.toLowerCase().startsWith("quit")) {
                    break;
                }
                else if (command.toLowerCase().startsWith("help")) {
                    System.out.println(USAGE);
                    continue;
                }
                String query = "";
                Map<String, List<String>> arguments = Main.parseCommand(command);
                String operation = arguments.get("COMMAND").get(0).toLowerCase();
                switch(operation) {
                    case "writereview":
                        query = createReviewCommand(command);
                        break;
                    case "list":
                        query = ""; // TODO
                        break;

                    case "reviews":
                        query = "SELECT stars, reviewDescription, reviewDate FROM " + arguments.get("SUBJECT").get(0).toLowerCase().concat("Review");
                        if (arguments.containsKey(SORT)) {

                            query = query.concat("ORDER BY").concat(String.join(" ", arguments.get(SORT)));
                        }
                        break;
                }

                // Once query is finished, display everything
                System.out.println("Query: " + query);
                /**
                ResultSet results = stmt.executeQuery(query);
                ResultSetMetaData md = results.getMetaData();
                int colCount = md.getColumnCount();
                while (results.next()) {
                    for (int i = 1; i <= colCount; i++) {
                        if (i > 1) System.out.print(" | ");
                        System.out.print(md.getColumnName(i) + ": " + results.getString(i));
                    }
                    System.out.println();
                }
                **/
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
        // TODO: Prompt user for username, password, email, and full name. Ensure username and email are unique. Return array of these items
        String[] account = new String[4];
        //Username
        boolean repeatUsername = true;
        while (repeatUsername) {
            System.out.println("Enter the username for your new account.");
            account[0] = input.next();
            repeatUsername = false;
            for (String[] existingAccount : accountInfo) {
                if (existingAccount[0].equals(account[0])) {
                    repeatUsername = true;
                    break;
                }
            }
            if (repeatUsername) {
                System.out.println("Username " + account[0] + " already exists");
            }
        }
        System.out.println("Enter the password for your new account");
        account[1] = input.next();
        System.out.println("Enter the name for this account");
        account[3] = input.next();


        return account;
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
        System.out.println("Command: " + command);
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        System.out.println(argList);
        String baseCmd = argList.get(0);
        args.put("COMMAND", Collections.singletonList(baseCmd));
        args.put("SUBJECT", Collections.singletonList(argList.get(1)));
        // parsing options
        for (int i = 2; i < argList.size(); i++) {
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
