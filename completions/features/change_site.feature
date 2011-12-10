Feature: Change Site
  
  So that I can control site visibility
  As a user
  I want to change my default site

  Background:
    Given the system roles
      And the following users:
    |id | username    | password |
    | 1 | kellyh      | password |
    | 2 | beisenhauer | password |
    | 3 | seisenhauer | password |

      And the following sites:
    |id | name         | ancestry | 
    | 1 | Schlumberger |        0 |
    | 2 | NGC          |        1 |                
    | 3 | Completions  |      1/2 |
    | 4 | RMC          |    1/2/3 | 

		  And the following site memberships:
		| user_id | site_id |
		|       2 |       4 |
		|       3 |       2 |

  Scenario: User attempts to change site, but has no sites
  	Given I am signed in as "kellyh"
     When I go to the edit user sites page
		 Then I should see "You can only change sites if you are a member of two or more sites."
		
  Scenario: User attempts to change site, but has only one site.
  	Given I am signed in as "beisenhauer"
     When I go to the edit user sites page
		 Then I should see "You can only change sites if you are a member of two or more sites."
		
  Scenario: User attempts to change site, but has more than 1 visible site.
  	Given I am signed in as "seisenhauer"
     When I go to the edit user sites page
      And I select "Completions" from "site"
     When I press "Change Site"
		 Then I go to the dashboard page
		  And I should see "Completions"