require 'bundler'
require 'capybara'
require "selenium/webdriver"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

session = Capybara::Session.new(:chrome)

# Go to the start
session.visit "http://localhost:8082/login"

# Sign in
session.fill_in "Email address", with: "idamOwner@hmcts.net"
session.fill_in "Password", with: "Ref0rmIsFun"
session.click_button "Sign in"

# Manage services - Ensure there is the correct service present
session.click_link "Manage services"
if !session.has_selector?(:label, 'CCD Gateway As Instructed In ccd-docker (ccd_gateway)')
  session.choose 'Add a new Service', visible: false
  session.click_button 'Continue'
  session.fill_in "Label", with: 'ccd_gateway'
  session.fill_in "Description", with: 'CCD Gateway As Instructed In ccd-docker (ccd_gateway)'
  session.fill_in "Client Id", with: 'ccd_gateway'
  session.fill_in "Client Secret", with: 'ccd_gateway_secret'
  session.fill_in "New redirect URI", with: 'http://localhost:3451/oauth2redirect'
  session.click_button 'Add URI'
  sleep 2
  session.click_button "Save Service"
end
# Back to main menu
session.click_link "Return to main menu"

# Manage roles - ensure all roles are present
session.click_link "Manage roles"
session.choose('CCD Gateway As Instructed In ccd-docker (ccd_gateway)', visible: false)
session.click_button 'Continue'

add_role = ->(role, selecting: []) do
  next if session.has_selector?(:radio_button, role, visible: false)
  session.choose "Add a new role", visible: false
  session.click_button "Continue"
  session.fill_in "Role label", with: role
  session.fill_in "Description", with: role
  selecting.each do |role|
    session.check role, visible: false, name: 'assignableRoles'
  end
  session.click_button "Save this role"

end
add_role.call('ccd-import')
puts `../bin/idam-create-caseworker.sh ccd-import ccd.docker.default@hmcts.net Pa55word11 Default CCD_Docker`
add_role.call('caseworker')
add_role.call('caseworker-employment', selecting: ['caseworker'])
add_role.call('caseworker-employment-tribunal-glasgow', selecting: ['caseworker', 'caseworker-employment'])
add_role.call('caseworker-employment-tribunal-manchester', selecting: ['caseworker', 'caseworker-employment'])
add_role.call('caseworker-employment-tribunal-glasgow-caseofficer', selecting: ['caseworker', 'caseworker-employment', 'caseworker-employment-tribunal-glasgow'])
add_role.call('caseworker-employment-tribunal-manchester-caseofficer', selecting: ['caseworker', 'caseworker-employment', 'caseworker-employment-tribunal-manchester'])
add_role.call('caseworker-employment-tribunal-glasgow-casesupervisor', selecting: ['caseworker', 'caseworker-employment', 'caseworker-employment-tribunal-glasgow'])
add_role.call('caseworker-employment-tribunal-manchester-casesupervisor', selecting: ['caseworker', 'caseworker-employment', 'caseworker-employment-tribunal-manchester'])
puts `../bin/ccd-add-role.sh caseworker-employment`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-manchester-caseofficer`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-manchester-casesupervisor`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-manchester`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-glasgow-caseofficer`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-glasgow-casesupervisor`
puts `../bin/ccd-add-role.sh caseworker-employment-tribunal-glasgow`
puts `../bin/idam-create-caseworker.sh caseworker,caseworker-employment-tribunal-manchester-caseofficer,caseworker-employment-tribunal-manchester-casesupervisor,caseworker-employment,caseworker-employment-tribunal-manchester,caseworker-employment-tribunal-glasgow-caseofficer,caseworker-employment-tribunal-glasgow-casesupervisor,caseworker-employment-tribunal-glasgow m@m.com Pa55word11 Lightyear Buzz`

sleep 10
