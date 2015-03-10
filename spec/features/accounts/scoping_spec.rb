require 'rails_helper'
require 'multitenacy/testing_support/factories/account_factory'
require 'multitenacy/testing_support/authentication_helpers'

feature 'Account Scoping' do
  let!(:account_a){FactoryGirl.create(:account, subdomain: 'testa')}
  let!(:account_b){FactoryGirl.create(:account, subdomain: 'testb')}
  before do
    Post.scoped_to(account_a).create(title: "Account A's post")
    Post.scoped_to(account_b).create(title: "Account B's post")
  end
  scenario 'display only account A records' do
    visit posts_url(subdomain: account_a.subdomain)
    expect(page).to have_content("Account A's post")
    expect(page).not_to have_content("Account B's post")
  end
  scenario 'display only account B records' do
    visit posts_url(subdomain: account_b.subdomain)
    expect(page).to have_content("Account B's post")
    expect(page).not_to have_content("Account A's post")
  end
  scenario 'account A post is visible on account A subdomain' do
    account_a_post = Post.scoped_to(account_a).first
    visit post_url(account_a_post, subdomain: account_a.subdomain)
    expect(page).to have_content("Account A's post")
  end
  scenario 'account B post is visible on account B subdomain' do
    account_b_post = Post.scoped_to(account_b).first
    visit post_url(account_b_post, subdomain: account_b.subdomain)
    expect(page).to have_content("Account B's post")
  end
  scenario 'account A post is invisible on account B subdomain' do
    account_a_post = Post.scoped_to(account_a).first
    expect do
      visit post_url(account_a_post, subdomain: account_b.subdomain)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end