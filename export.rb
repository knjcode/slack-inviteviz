# This script is licensed under CC BY-NC 3.0 (http://creativecommons.org/licenses/by-nc/3.0/deed.en)
# Reference https://github.com/oti/slack-reaction-decomoji/blob/master/import.rb

require 'mechanize'
require 'highline/import'
require 'json'

# Accepted invites Exporter
class Exporter
  attr_accessor :page, :agent

  def initialize
    @page = nil
    @agent = Mechanize.new
  end

  def save_accepted_invites
    move_to_invites_page
    save_json
  end

  private

  def login
    team_name  = ask('Your slack team name(subdomain): ')
    email      = ask('Login email: ')
    password   = ask('Login password(hidden): ') { |q| q.echo = false }

    invites_page_url = "https://#{team_name}.slack.com/admin/invites"

    page = agent.get(invites_page_url)
    return if page.title.include?('Invitations')

    page.form.email = email
    page.form.password = password
    @page = page.form.submit
  end

  def enter_two_factor_authentication_code
    page.form['2fa_code'] = ask('Your two factor authentication code: ')
    @page = page.form.submit
  end

  def move_to_invites_page
    login
    loop do
      break if page.title.include?('Invitations')
      if page.form && page.form['signin_2fa']
        enter_two_factor_authentication_code
      else
        puts 'Login failure. Please try again.'
        puts
        login
      end
    end
  end

  def reduce_user_info(invites)
    invites.map do |invite|
      user = {
        id: invite['user']['id'],
        name: invite['user']['name'],
        real_name: invite['user']['real_name'],
        profile: {
          image_32: invite['user']['profile']['image_32'],
          title: invite['user']['profile']['title']
        }
      }
      inviter = {
        id: invite['inviter']['id'],
        name: invite['inviter']['name'],
        real_name: invite['inviter']['real_name'],
        profile: {
          image_32: invite['inviter']['profile']['image_32'],
          title: invite['inviter']['profile']['title']
        }
      }
      { user: user, inviter: inviter }
    end
  end

  def save_json
    accepted_invites = page.body.scan(/boot_data.accepted_invites = (.+?);/)
    invites = JSON.parse(accepted_invites[0][0])
    reduced_invites = reduce_user_info(invites)
    File.write('accepted_invites.json', reduced_invites.to_json)
  end
end

exporter = Exporter.new
exporter.save_accepted_invites
puts 'Saved!'
