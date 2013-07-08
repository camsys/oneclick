Feature: Traveler Home Page
  As a visitor to the website
  I want to see the actions I can take listed on the homepage
  so I can know what I can do there

  Scenario: Viewing home page actions
    Given I exist as a user
    When I look at the home page
    Then I see "Plan a Trip"
    And I see "Identify Places"
    And I see "Change My Settings"
    And I see "Help & Support"
