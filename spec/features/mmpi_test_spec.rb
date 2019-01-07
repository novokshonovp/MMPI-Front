require 'simplecov'
SimpleCov.start
require './mmpi-main'
require 'capybara'
require 'capybara/rspec'

Capybara.app = Main

feature "MMPI", type: :feature do
  let(:root_path) { '/' }
  scenario "visit root page " do
    visit root_path
    expect(page).to have_css('h2', :text => 'Стандартизированный многофакторный метод исследования личности (СМИЛ)')
  end
  scenario "visit root page fill form and start test", js: true do
    visit root_path
    choose('sex', id: 'male')
    fill_in('firstname', with: 'rspec_test_user')
    select('20', from: 'age')
    select('Основное общее образование (школа)', from: 'grade')
    click_on('submit')
    expect(page.has_content?('Я люблю читать научно-техническую литературу')).to be true
  end
end
