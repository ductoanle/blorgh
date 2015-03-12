require 'rails_helper'
require 'multitenacy/testing_support/factories/account_factory'
require 'multitenacy/testing_support/authentication_helpers'

feature 'Accounts' do
  include Multitenacy::TestingSupport::AuthenticationHelpers
  let(:account){ FactoryGirl.create(:account) }
  let(:root_url) { "http://#{account.subdomain}.example.com"}

  context 'as the account owner' do
    before do
      sign_in_as(user: account.owner, account: account)
    end

    scenario 'updating an account' do
      visit root_url
      click_link 'Edit Account'
      fill_in 'Name', with: 'A new name'
      click_button 'Update Account'
      expect(page).to have_content('Account updated successfully.')
      expect(account.reload.name).to eq 'A new name'
    end

    scenario 'update account with invalid attributes' do
      visit root_url
      click_link 'Edit Account'
      fill_in 'Name', with: ''
      click_button 'Update Account'
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Account could not be updated.")
    end
  end

  context 'as a normal user' do
    before do
      user = FactoryGirl.create(:user)
      sign_in_as(user: user, account: account)
    end

    scenario "Cannot edit account's information" do
      visit multitenacy.edit_account_url(subdomain: account.subdomain)
      expect(page).to have_content('You are not allowed to do that.')
    end
  end
end