Feature: Localization
  As a visitor to the website
  I want to change the language of the application
  so I can use it in my native language

  Scenario: Localization links exist
    Given I am not logged in
    When I look at the home page
    Then I see "English"
    And I see "Español"

  Scenario: Click the spanish link switches language
    Given I am not logged in
    When I look at the home page
    And I click "Español"
    Then I see "Planear un Viaje"

  Scenario: Language selection persists while I navigate
    Given I am not logged in
    When I look at the home page
    And I click "Español"
    And I click "Planear un Viaje"
    Then I see "From in spanish"


