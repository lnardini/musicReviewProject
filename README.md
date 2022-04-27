# MusicReview Project
Our project is run using Java. The connector that we use is mysql-connector-java-8.0.28.jar (https://dev.mysql.com/downloads/connector/j/). We ran it using IntelliJ, but other Java IDEs should work fine.


## Usage instructions
1. Download and open the musicDB.sql file in the MySql editor. Run all the operations in the file to configure the database. Ensure the musicReview database exists in your schema.
2. Download and open the source code in a Java IDE. We use intelliJ but Eclipse will also work.
3. Edit the MySqlUsername and MySqlPassword variables at the top of main.java to match your local MySQL credentials.
4. Run the main method in main.java. If any errors come up about the project JDK, either specify your own Java 8 JDK or follow the prompts for installing the Coretta JDK specified.
5. When running, answer the prompts in the console regarding your MySQL username and password. 