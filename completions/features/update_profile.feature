Feature: Update Profile
  
  So that I can update my user profile
  As a user
  I want to change my profile

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
		
  Scenario: User fails to update profile.
  	Given I am signed in as "beisenhauer"
     When I go to the edit profile page
      And I fill in "user[username]" with ""
     When I press "Update Profile"
		 Then I should see "Username can't be blank"
		
  Scenario: User successfully updates profile.
  	Given I am signed in as "seisenhauer"
     When I go to the edit profile page
      And I fill in "user[username]" with "beisenhauer3"
     When I press "Update Profile"
		 Then I should see "beisenhauer3"