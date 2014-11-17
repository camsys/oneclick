@desktop
Feature: Traveler Home Page
  As a visitor to the website
  I want to see the actions I can take listed on the homepage
  so I can know what I can do there

  Scenario: Viewing home page actions, logged out
    Given I exist as a user
    When I look at the home page
    And I see "Log in"
    And I see "Sign up"

  Scenario: Viewing home page actions, logged in
    Given I exist as a user
      And I am not logged in
    When I sign in with valid credentials
    Then I see a successful sign in message
    When I look at the home page
    Then I see "Plan a Trip"
    And I see "Travel Profile"
    And I see "Trips"
