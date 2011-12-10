Feature: Manage Users
  
  So that I can control tag access
  As an admin
  I want to create, show, update, delete, and list tags
  
  Background:
		Given the system roles
      And the following users:
    |id | username    | password |
    | 1 | kellyh      | password |
    | 2 | beisenhauer | password |

		And the following tags:
    | id | tag_number      |
    |  1 | 100.100.100.100 |
    |  2 | 100.100.100.101 |

	### LIST ###

  Scenario: Guest attempts to list tags
  	Given I am signed in as "Guest" user
     When I go to the tags page
		 Then I should see "You are not allowed to access this action."
		
  Scenario: Champion attempts to list tags
  	Given I am signed in as "Champion" user
     When I go to the tags page
		 Then I should see "You are not allowed to access this action."
		
  Scenario: Administrator attempts to list tags
  	Given I am signed in as "Administrator" user
     When I go to the tags page
		 Then I should see "100.100.100.100"
		  And I should see "100.100.100.101"

  Scenario: Support Administrator attempts to list tags
  	Given I am signed in as "Support Administrator" user
     When I go to the tags page
		 Then I should see "100.100.100.100"
		  And I should see "100.100.100.101"		
		
	### SHOW ###

  Scenario: Guest attempts to show tag
  	Given I am signed in as "Guest" user
      And a tag exists with id: 99, tag_number: "100.100.100.102"
     When I go to the show page for that tag
		 Then I should see "You are not allowed to access this action."

  Scenario: Champion attempts to show tag
  	Given I am signed in as "Champion" user
      And a tag exists with id: 99, tag_number: "100.100.100.102"
     When I go to the show page for that tag
		 Then I should see "You are not allowed to access this action."

  Scenario: Administrator attempts to show tag
  	Given I am signed in as "Administrator" user
      And a tag exists with id: 99, tag_number: "100.100.100.102"
     When I go to the show page for that tag
		 Then I should see "100.100.100.102"

  Scenario: Support Administrator attempts to show tag
  	Given I am signed in as "Support Administrator" user
      And a tag exists with id: 99, tag_number: "100.100.100.102"
     When I go to the show page for that tag
		 Then I should see "100.100.100.102"