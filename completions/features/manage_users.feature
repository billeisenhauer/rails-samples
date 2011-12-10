Feature: Manage Users
  
  So that I can control user access
  As an admin
  I want to create, show, update, delete, and list users
  
  Background:
    Given the system roles
      And the following users:
    |id | username    | password |
    | 1 | kellyh      | password |
    | 2 | beisenhauer | password |

	### LIST ###

  Scenario: Guest attempts to list users
  	Given I am signed in as "Guest" user
     When I go to the users page
		 Then I should see "You are not allowed to access this action."
		
  Scenario: Champion attempts to list users
  	Given I am signed in as "Champion" user
     When I go to the users page
		 Then I should see "You are not allowed to access this action."
		
  Scenario: Administrator attempts to list users
  	Given I am signed in as "Administrator" user
     When I go to the users page
		 Then I should see "kellyh"
		  And I should see "beisenhauer"
		
  Scenario: Support Administrator attempts to list users
  	Given I am signed in as "Support Administrator" user
     When I go to the users page
		 Then I should see "kellyh"
		  And I should see "beisenhauer"
		
	### SHOW ###

  Scenario: Guest attempts to show user
  	Given I am signed in as "Guest" user
     When I am requesting User page with username "kellyh"
		 Then I should see "You are not allowed to access this action."

  Scenario: Champion attempts to show user
  	Given I am signed in as "Champion" user
     When I am requesting User page with username "kellyh"
		 Then I should see "You are not allowed to access this action."

  Scenario: Administrator attempts to show user
  	Given I am signed in as "Administrator" user
     When I am requesting User page with username "kellyh"
		 Then I should see "kellyh"

  Scenario: Support Administrator attempts to show user
  	Given I am signed in as "Support Administrator" user
     When I am requesting User page with username "kellyh"
		 Then I should see "kellyh"
		
		
	### NEW / CREATE ###

	# ---( New )

  Scenario: Guest attempts to go to new user page
  	Given I am signed in as "Guest" user
     When I go to the new user page
		 Then I should see "You are not allowed to access this action."

  Scenario: Champion attempts to go to new user page
  	Given I am signed in as "Champion" user
     When I go to the new user page
		 Then I should see "You are not allowed to access this action."

  Scenario: Administrator attempts to go to new user page
  	Given I am signed in as "Administrator" user
     When I go to the new user page

  Scenario: Support Administrator attempts to go to new user page
  	Given I am signed in as "Support Administrator" user
     When I go to the new user page

	# ---( Create )

	Scenario: Create Valid User
	  Given I am signed in as "Administrator" user
	    And I am on the new user page
	    And I fill in "user[username]" with "new-user"
	    And I choose "user_role_id_2"
	    And I press "Create User"
	   Then I should see "Successfully created user."
	    And I should see "new-user"
	    And I should see "Champion"
	
	Scenario: Create invalid user with no username
	  Given I am signed in as "Administrator" user
	    And I am on the new user page
	    And I choose "user_role_id_2"
	    And I press "Create User"
	   Then I should see "errors prohibited this user from being saved"
	    And I should see "Username can't be blank"