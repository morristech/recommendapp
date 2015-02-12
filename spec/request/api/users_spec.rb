require 'rails_helper'

describe "API", :type => :request do

  describe "GET /users" do
    it "lists all users" do
      user = FactoryGirl.create(:user)
      get '/api/users', {
        api_access_token: user.api_access_token
      }
      expect(json.count).to eq(User.count)
    end

    include_examples "auth", :get,  '/api/users'
  end

  describe "POST /users" do
    it "creates user" do
      post '/api/users', {
        fb_uid: "uid1",
        fb_access_token: "access_token1",
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.count).to eq(1)
      expect(json["elsewheres"].size).to eq(1)
    end

    it "doesn't create user if elsewhere exists" do
      user = FactoryGirl.create(:user)
      post '/api/users', {
        fb_uid: user.elsewheres.first.uid,
        fb_access_token: user.elsewheres.first.uid,
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.count).to eq(1)
      expect(json["elsewheres"][0]["uid"]).to eq(user.elsewheres.first.uid)
    end
  end

  describe "GET /user/:id/android_apps" do
    let(:user) {
      FactoryGirl.create(:user,
        :android_apps => [
          FactoryGirl.create(:android_app),
          FactoryGirl.create(:android_app)
        ]
      )
    }

    it "returns all the users apps" do
      get "/api/user/#{user.id}/android_apps", {
        api_access_token: user.api_access_token
      }
      expect(json.size).to eq(2)
    end

    include_examples "auth", :get, "/api/user/1/android_apps"
  end

  describe "POST /user/:id/android_apps" do
    let(:user) { FactoryGirl.create(:user) }
    let(:valid_params) {
      [
          { uid: "1234", display_name: "Angry Birds" },
          { uid: "2345", display_name: "Temple Run" }
      ]
    }

    it "creates apps if they don't exist" do
      post "/api/user/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        apps: valid_params
      }
      expect(json.size).to eq(2)
    end

    it "doesn't create apps again if they exist" do
      FactoryGirl.create(:android_app,
        uid: valid_params[0][:uid],
        display_name: valid_params[0][:display_name]
      )
      post "/api/user/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        apps: valid_params
      }
      expect(json.size).to eq(2)
    end

    it "returns same number of apps for two identical requests" do
      3.times do
        post "/api/user/#{user.id}/android_apps", {
          api_access_token: user.api_access_token,
          apps: valid_params
        }
        expect(json.size).to eq(2)
      end
    end

    it "doesn't let other users edit" do
      other_user = FactoryGirl.create(:user)
      post "/api/user/#{user.id}/android_apps", {
        api_access_token: other_user.api_access_token,
        apps: valid_params
      }
      expect(response.status).to eq(401)
    end

    include_examples "auth", :post, "/api/user/1/android_apps"
  end

  describe "PUT /user/:id" do
    let(:user) { FactoryGirl.create(:user) }

    it "updates push_id for user" do
      put "/api/user/#{user.id}", {
        api_access_token: user.api_access_token,
        push_id: "abcd"
      }
      expect(response.status).to eq(200)
      expect(json["push_id"]).to eq("abcd")
      user.reload
      expect(user.push_id).to eq("abcd")
    end

    it "doesn't let user change other user's ID" do
      put "/api/user/#{user.id}", {
        api_access_token: FactoryGirl.create(:user).api_access_token,
        push_id: "abcd"
      }
      expect(response.status).to eq(401)
    end

    include_examples "auth", :put, "/api/user/1"
  end
end

