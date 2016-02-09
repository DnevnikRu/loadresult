Feature: Upload load result
  As a load testing engineer
  I want save csv files with load test result
  So that let handle it later

  Scenario: Visit upload page from homepage
    When I visit homepage
    And I click on Upload results
    Then I see page with title "Upload results"


  Scenario: Visit upload page using navigation bar
    When I visit homepage
    And Click menu Upload results in navigation bar
    Then I see page with title "Upload results"

  Scenario: Upload test result with filled additional information
    When I visit upload results page
    And I fill all field about results
    And I choose summary file
    And I choose perfmon file
    And I Upload results
    Then I see success message

  Scenario: Upload test result without perfmon file
    When I visit upload results page
    And I fill all field about results
    And I choose summary file
    And I Upload results
    Then I see success message "Results successfully uploaded"

  Scenario: Can not upload result without additional information
    When I visit upload results page
    And I choose summary file
    And I choose perfmon file
    And I Upload results
    Then I see error message "You should fill additional information about results"

  Scenario: Can not upload result without summary file
    When I visit upload results page
    And I fill all field about results
    And I choose perfmon file
    And I Upload results
    Then I see error message "Choose summary file for upload"



