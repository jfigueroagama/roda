require "roda"
require "sequel"
require "bcrypt"
require "rack/protection"

# DB configuration
database = "myroda_development"
user = ENV["PGUSER"]
password = ENV["PGPASSWORD"]
DB = Sequel.connect(adapter: "postgres", database: database, host: "127.0.0.1", user: user, password: password)

class MyRoda < Roda
  Sequel::Model.plugin :validation_helpers

  use Rack::Session::Cookie, secret: "some_nice_long_random_string_DSKJH4378EYR7EGKUFH", key: "_myapp_session"
  use Rack::Protection

  plugin :static, ["/images", "/css", "/js"]
  plugin :render
  plugin :head
  plugin :csrf

  require './models/user.rb'

  route do |r|
    r.root do
      # We tell Roda to use homepage.erb
      view("homepage")
    end
    r.get "about" do
      view("about")
    end
    r.get "contact" do
      view("contact")
    end

    r.get "login" do
      view("login")
    end
    r.post "login" do
      if user = User.authenticate(r["email"], r["password"])
        session[:user_id] = user.id
        r.redirect "/"
      else
        r.redirect "/login"
      end
    end
    r.post "logout" do
      session.clear
      r.redirect "/"
    end

    unless session[:user_id]
      r.redirect "/login"
    end

    r.on "users" do
      r.get "new" do
        @user = User.new
        view("users/new")
      end

      r.get ":id" do |id|
        @user = User[id]
        view("users/show")
      end

      r.is do
        r.get do
          @users = User.order(:id)
          view("users/index")
        end

        r.post do
          @user = User.new(r["user"])
          if @user.valid? && @user.save
            r.redirect "/users"
          else
            view("users/new")
          end
        end
      end
    end

  end
end
