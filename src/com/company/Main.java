package com.company;

import java.sql.*;
import java.sql.Date;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {
    static final String URL = "jdbc:mysql://localhost/musicReview";
    static String mySqlUser = "root";
    static String mySqlPass = "Tugboat1812"; // Enter your password here
    static Scanner input = new Scanner(System.in);
    static final String USAGE = "Usage:\n" +
            "List [entity type] [options] \n" +
            "    - Lists the provided entity types with the following filters\n" +
            "Reviews [entity type] [entity name] [options]\n" +
            "    - Lists the reviews for the given entity with the following filters\n" +
            "writeReview [entity type] [entity name]\n" +
            "    - Starts providing prompts for a review of the provided entity \n" +
            "deleteReview [entityType] [entityName]\n" +
            "    - Deletes the review left by this user on the specified entity, if it exists.\n" +
            "\n" +
            "Entity types:\n" +
            "- Song\n" +
            "- Album\n" +
            "- Artist\n" +
            "\n" +
            "Review Options:\n" +
            "—sort [criteria ASC/DESC] \n" +
            "    - Determines how to order the results\n" +
            "—stars [<, >, =] [bound]\n" +
            "    - Filters for reviews with the provided star count condition \n" +
            "\n" +
            "Listing Options:\n" +
            "—genre [genre]\n" +
            "    - Filters for entities that fall under the listed genre\n" +
            "—author [name]\n" +
            "    - Filters for songs or albums with the given author\n" +
            "—sort [criteria ASC/DESC] \n" +
            "    - Determines how to order the results. \n" +
            "—instrument [instrument]\n" +
            "    - Filters for songs performed with or artists that play the given instrument";


    static String accountUsername = "";
    static String accountPassword = "";

    // Argument String constants
    static final String GENRE = "--genre";
    static final String AUTHOR = "--author";
    static final String SORT = "--sort";
    static final String STARS = "--stars";
    static final String DATE = "--date";
    static final Date currentDate = new Date(System.currentTimeMillis());

    static final List<String> FLAGS = Arrays.asList(GENRE, AUTHOR, SORT, STARS, DATE);


    public static void main(String[] args) {

//        System.out.println("Enter the MySql username");
//        mySqlUser = input.next();
//        System.out.println("Enter the MySql password");
//        mySqlPass = input.next();



        try(Connection conn = DriverManager.getConnection(URL, mySqlUser, mySqlPass);
            Statement stmt = conn.createStatement()) {
            System.out.println("Connection successful!");

            // Account
            ResultSet accounts = stmt.executeQuery("SELECT * FROM musicReview.reviewerUser;");
            List<String[]> accountInfo = new ArrayList<>(); // [username, userPassword, email, name ]
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
                };

                if (command.toLowerCase().startsWith("quit")) {
                    break;
                }
                else if (command.toLowerCase().startsWith("help")) {
                    System.out.println(USAGE);
                    continue;
                }
                String query;
                Map<String, List<String>> arguments = Main.parseCommand(command);
                String operation = arguments.get("COMMAND").get(0).toLowerCase();
                String entityType = arguments.get("entityType").get(0).toLowerCase();
                String entityName = arguments.containsKey("entityName")? arguments.get("entityName").get(0) : "";
                PreparedStatement statementToExecute = null;
                switch(operation) {
                    case "writereview": //seemingly done, needs testing
                        query = createReviewCommand(command);
                        statementToExecute = conn.prepareStatement(query);
                        break;
                    case "list": //TODO: Most of it. Need to formulate query with sorting and stars
                        boolean anyListOptions = arguments.containsKey(STARS) || arguments.containsKey(GENRE) || arguments.containsKey(AUTHOR) || arguments.containsKey(DATE);
                        query = "SELECT * FROM " + entityType.concat(anyListOptions? "WHERE" : "");
//                        if (arguments.containsKey(STARS)) {
//                            List<String> bounds = arguments.get(STARS);
//                            String starsCond = String.format("stars %s %s", bounds.get(0), bounds.get(1));
//                            query = query.concat(starsCond)
//                        }

                        break;
                    case "reviews":
                        boolean anyReviewOptions = arguments.containsKey(STARS) || arguments.containsKey(DATE);
                        query = "SELECT * FROM " + entityType.concat("Review").concat(anyReviewOptions? " WHERE " : "");
                        if (arguments.containsKey(STARS)) {
                            query = query.concat("stars ")
                                    .concat(String.join(" ", arguments.get(STARS)))
                                    .concat(arguments.containsKey(DATE)? " AND " : "");
                        }
                        if (arguments.containsKey(DATE)) {
                            query = query.concat("reviewDate ")
                                    .concat(String.join(" ", arguments.get(DATE)));
                        }
                        if (arguments.containsKey(SORT)) {
                            query = query.concat("ORDER BY ")
                                    .concat(String.join(" ", arguments.get(SORT)));
                        }
                        statementToExecute = conn.prepareStatement(query);
                        System.out.println(statementToExecute);
                        break;
                    case "deletereview": // Done
                        String deleteId = entityType.concat("_id");
                        String deleteTable = entityType.concat("Review");
                        String statementStr = String.format("SELECT * FROM %s WHERE %s = '%s';", entityType, entityType.concat("Name"), entityName);
                        System.out.println(statementStr);
                        PreparedStatement entityStmt = conn.prepareStatement(statementStr);
                        ResultSet entityResult = entityStmt.executeQuery();
                        int entityId = entityResult.getInt(deleteId);

                        statementToExecute = conn.prepareStatement("DELETE FROM ? WHERE reviewer = ? AND ? = ?;");
                        statementToExecute.setString(1, deleteTable);
                        statementToExecute.setString(2, accountUsername);
                        statementToExecute.setString(3, deleteId);
                        statementToExecute.setInt(4, entityId);
                        System.out.println("Delete query: " + statementToExecute);
                        break;
                    default:
                        throw new IllegalArgumentException("Unidentified command: " + command);
                }


                //ResultSet results = statementToExecute.executeQuery();

                // Once query is finished, display everything
                /**;
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
        //TODO: Check emails are unique, ask for email
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
        int entityId = -1;//TODO: Add subquery to get entity ID
        return String.format(reviewStr, table, stars, description, reviewer, currentDate, entityId);
    }


    static Map<String, List<String>> parseCommand(String command) {
        Map<String, List<String>> args = new HashMap<>();
        System.out.println("Command: " + command);
        List<String> argList = Stream.of(command.split(" ")).collect(Collectors.toList());
        System.out.println(argList);
        String baseCmd = argList.get(0);
        args.put("COMMAND", Collections.singletonList(baseCmd));
        args.put("entityType", Collections.singletonList(argList.get(1)));
        args.put("entityName", Collections.singletonList((argList.get(2))));
        // parsing options
        for (int i = 3; i < argList.size(); i++) {
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
