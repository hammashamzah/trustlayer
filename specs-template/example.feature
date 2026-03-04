@scope(example)
@priority(medium)
@retroactive
Feature: Example Feature

  As a user
  I want to see a welcome page
  So that I know the app is working

  Background:
    Given the application is running

  @happy-path
  Scenario: Welcome page loads
    Given I navigate to the home page
    Then I should see a welcome message
    And the page should load within 3 seconds
