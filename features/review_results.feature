Feature: Review results
  As a any user
  I want see history of uploaded results
  To make sure that results uploaded successfully to build compare report

Scenario: Uploaded results displayed on results page
  Given In system saved some results
  Then I visit results page
  And I see table with some results

Scenario: Table with results contains all information about results
  Given In system saved result with id "1", version "master", RPS "150", duration "600", profile "all_sites" and date "08.02.2016 10:12"
  Then I visit result page
  And I find result with id "1"
  Then I check that result information is correct