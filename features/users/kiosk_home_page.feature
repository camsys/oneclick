@kiosk
Feature: Kiosk Home Page
  As a visitor to the kiosk
  I want to see the actions I can take listed on the homepage
  so I can know what I can do there

  Scenario: Viewing home page actions, logged out
    Given I exist as a user
    When I look at the home page
    Then I see "Touch to begin"
