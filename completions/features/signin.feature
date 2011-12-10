Feature: User Authentication
  
  So that I can prove I am really me and prevent unauthenticated access to my account details
  As a User
  I want to sign in using my username and password and I want to sign out
  
  Background:
    Given the system roles
      And the following users:
    | id | username | password |
    |  1 | kellyh   | password |
  
  Scenario: Successful Signin
    Given I am on the signin page
    And I fill in "Username" with "kellyh"
    And I fill in "Password" with "password"
    When I press "Sign In"
    Then I should see "Sign in successful!"

  Scenario: Signin failed, bad username
  # this variant shows we can also use form field id if needed
    Given I am on the signin page
    And I fill in "user_session[username]" with "unknown"
    And I fill in "user_session[password]" with "password"
    When I press "user_session_submit"
    Then I should see "Couldn't sign you in as 'unknown'"

  Scenario: Signin failed, bad password
    Given I am on the signin page
    And I fill in "Username" with "kellyh"
    And I fill in "Password" with "invalid"
    When I press "Sign In"
    Then I should see "Couldn't sign you in as 'kellyh'"

  Scenario: Successful Signout
    Given I am a registered user
    And I am signed in
    When I follow "Sign Out"
    Then I should see "Sign out successful!"