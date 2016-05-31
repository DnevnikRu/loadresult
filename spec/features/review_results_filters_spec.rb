require 'feature_helper'
require 'active_support/time_with_zone'

feature 'Review results with filters and sorting' do

  describe 'Filters' do
    before(:all) do
      DatabaseCleaner.clean
      create(:result, release_date: '01.01.1978', test_run_date: '01.01.1978', project_id: 2, version: 'root')
      create(:result, release_date: '02.01.1978', test_run_date: '02.01.1978', project_id: 1, version: 'rootnot')
      create(:result, release_date: '03.01.1978', test_run_date: '03.01.1978', project_id: 1)
      create(:result, release_date: '04.01.1978', test_run_date: '04.01.1978', project_id: 1)
    end

    scenario 'Select results with specific project' do
      visit '/results/'
      click_on 'Reset filters'
      wait_for_ajax
      select 'Contingent', from: 'filterrific_with_project_id'
      wait_for_ajax
      results_projects_versions = []
      sleep 1
      page.all('table#results-table tr.result_row').each do |row|
        project = row.find('td.project').text
        version = row.find('td.version').text
        results_projects_versions.push [version, project]
      end
      expect(results_projects_versions).to contain_exactly(['root', 'Contingent'])
    end

    scenario 'Search result by version' do
      visit '/results/'
      click_on 'Reset filters'
      wait_for_ajax
      fill_in 'filterrific_version_search_query', with: 'not'
      wait_for_ajax
      results_projects_versions = []
      sleep 1
      page.all('table#results-table tr.result_row').each do |row|
        project = row.find('td.project').text
        version = row.find('td.version').text
        results_projects_versions.push [version, project]
      end
      expect(results_projects_versions).to contain_exactly(['rootnot', 'Dnevnik'])
    end

    scenario 'Filter results with release date from and to parameters' do
      visit '/results/'
      click_on 'Reset filters'
      wait_for_ajax
      fill_in 'filterrific_release_date_gte', with: '01.01.1978'
      wait_for_ajax
      fill_in 'filterrific_release_date_lt', with: '03.01.1978'
      wait_for_ajax
      results_projects_versions = []
      sleep 1
      page.all('table#results-table tr.result_row').each do |row|
        release_date = Time.zone.parse(row.find('td.release_date').text).strftime('%d.%m.%Y')
        version = row.find('td.version').text
        results_projects_versions.push [version, release_date]
      end
      expect(results_projects_versions).to contain_exactly(['root', '01.01.1978'], ['rootnot', '02.01.1978'])
    end

    scenario 'Filter results with release date from and to parameters' do
      visit '/results/'
      click_on 'Reset filters'
      wait_for_ajax
      fill_in 'filterrific_test_run_date_gte', with: '01.01.1978'
      wait_for_ajax
      fill_in 'filterrific_test_run_date_lt', with: '03.01.1978'
      wait_for_ajax
      results_projects_versions = []
      sleep 1
      page.all('table#results-table tr.result_row').each do |row|
        test_run_date = Time.zone.parse(row.find('td.test_run_date').text).strftime('%d.%m.%Y')
        version = row.find('td.version').text
        results_projects_versions.push [version, test_run_date]
      end
      expect(results_projects_versions).to contain_exactly(['root', '01.01.1978'], ['rootnot', '02.01.1978'])
    end
  end

  describe 'Sorting' do
    before(:all) do
      DatabaseCleaner.clean
      create(:result, version: 'second', project_id: 1, rps: 23, duration: 0, profile: 'all_sites',
             data_version: 'old', test_run_date: '01.01.2015', time_cutting_percent: 10, smoothing_percent: 0, release_date: '02.01.2015', comment: nil)
      create(:result, version: 'first', project_id: 2, rps: 230, duration: 1, profile: 'all_sites_only',
             data_version: nil, test_run_date: '02.01.2015', time_cutting_percent: 0, smoothing_percent: 9, release_date: '01.01.2015', comment: 'текст')
    end

    scenario 'Sort by Project asc' do
      visit '/results/'
      click_on 'Project'
      wait_for_ajax
      expect(page.all('.project').map(&:text)).to eql(['Contingent', 'Dnevnik'])
    end

    scenario 'Sort by Project desc' do
      visit '/results/'
      click_on 'Project'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.project').map(&:text)).to eql(['Dnevnik', 'Contingent'])
    end

    scenario 'Sort by version asc' do
      visit '/results/'
      click_on 'Version'
      wait_for_ajax
      expect(page.all('.version').map(&:text)).to eql(['first', 'second'])
    end

    scenario 'Sort by version desc' do
      visit '/results/'
      click_on 'Version'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.version').map(&:text)).to eql(['second', 'first'])
    end

    scenario 'Sort by Rps asc' do
      visit '/results/'
      click_on 'Rps'
      wait_for_ajax
      expect(page.all('.rps').map(&:text)).to eql(['23', '230'])
    end

    scenario 'Sort by Rps asc' do
      visit '/results/'
      click_on 'Rps'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.rps').map(&:text)).to eql(['230', '23'])
    end

    scenario 'Sort by Duration asc' do
      visit '/results/'
      click_on 'Duration'
      wait_for_ajax
      expect(page.all('.duration').map(&:text)).to eql(['0', '1'])
    end

    scenario 'Sort by Duration desc' do
      visit '/results/'
      click_on 'Duration'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.duration').map(&:text)).to eql(['1', '0'])
    end

    scenario 'Sort by Profile asc' do
      visit '/results/'
      click_on 'Profile'
      wait_for_ajax
      expect(page.all('.profile').map(&:text)).to eql(['all_sites', 'all_sites_only'])
    end

    scenario 'Sort by Profile desc' do
      visit '/results/'
      click_on 'Profile'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.profile').map(&:text)).to eql(['all_sites_only', 'all_sites'])
    end

    scenario 'Sort by Data version asc' do
      visit '/results/'
      click_on 'Data version'
      wait_for_ajax
      expect(page.all('.data_version').map(&:text)).to eql(['', 'old'])
    end

    scenario 'Sort by Data version desc' do
      visit '/results/'
      click_on 'Data version'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.data_version').map(&:text)).to eql(['old', ''])
    end

    scenario 'Sort by Test run date asc' do
      visit '/results/'
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.test_run_date').map { |e| Time.parse(e.text).strftime('%d.%m.%Y') }).to eql(['01.01.2015', '02.01.2015'])
    end

    scenario 'Sort by Test run date desc' do
      visit '/results/'
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.test_run_date').map { |e| Time.parse(e.text).strftime('%d.%m.%Y') }).to eql(['02.01.2015', '01.01.2015'])
    end

    scenario 'Sort by Time cutting percent asc' do
      visit '/results/'
      click_on 'Time cutting percent'
      wait_for_ajax
      expect(page.all('.time_cutting_percent').map(&:text)).to eql(['0', '10'])
    end

    scenario 'Sort by Time cutting percent desc' do
      visit '/results/'
      click_on 'Time cutting percent'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.time_cutting_percent').map(&:text)).to eql(['10', '0'])
    end

    scenario 'Sort by Smoothing percent asc' do
      visit '/results/'
      click_on 'Smoothing percent'
      wait_for_ajax
      expect(page.all('.smoothing_percent').map(&:text)).to eql(['0', '9'])
    end

    scenario 'Sort by Smoothing percent desc' do
      visit '/results/'
      click_on 'Smoothing percent'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.smoothing_percent').map(&:text)).to eql(['9', '0'])
    end

    scenario 'Sort by Release date asc' do
      visit '/results/'
      click_on 'Release date'
      wait_for_ajax
      expect(page.all('.release_date').map { |e| Time.parse(e.text).strftime('%d.%m.%Y') }).to eql(['01.01.2015', '02.01.2015'])
    end

    scenario 'Sort by Release date desc' do
      visit '/results/'
      click_on 'Release date'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      expect(page.all('.release_date').map { |e| Time.parse(e.text).strftime('%d.%m.%Y') }).to eql(['02.01.2015', '01.01.2015'])
    end

    scenario 'Sort by Comment asc' do
      visit '/results/'
      click_on 'Comment'
      wait_for_ajax
      comments = []
      page.all('table#results-table tr.result_row').each do |row|
        comment = row.find('td.comment')
        comments.push comment
      end
      expect(comments[1].find('.glyphicon')[:title]).to eql('текст')
    end


    scenario 'Sort by Comment desc' do
      visit '/results/'
      click_on 'Comment'
      wait_for_ajax
      page.find('.filterrific_current_sort_column').click
      wait_for_ajax
      comments = []
      page.all('table#results-table tr.result_row').each do |row|
        comment = row.find('td.comment')
        comments.push comment
      end
      expect(comments[0].find('.glyphicon')[:title]).to eql('текст')
    end

  end
end
