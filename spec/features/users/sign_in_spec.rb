require 'rails_helper'
require 'multitenacy/testing_support/subdomain_helpers'
require 'multitenacy/testing_support/factories/account_factory'

feature 'User Sign in' do
  extend Multitenacy::TestingSupport::SubdomainHelpers
  let!(:account){FactoryGirl.create(:account)}
  let(:sign_in_url){"http://#{account.subdomain}.example.com/sign_in"}
  let(:root_url){"http://#{account.subdomain}.example.com/"}
  within_account_subdomain do
    scenario 'sign in as account owner successfully' do
      visit root_url
      click_link 'Sign in'
      fill_in 'Email', with: account.owner.email
      fill_in 'Password', with: 'password'
      click_button 'Sign in'
      expect(page).to have_content 'You are now signed in.'
      expect(page.current_url).to eq root_url
    end
  end
end