module Api
  class UsersController < ApplicationController
    before_filter :require_auth, :except => :create
    before_filter :require_correct_user, only: [
      :update,
      :android_apps_create,
      :android_apps_delete
    ]

    def index
      render :json => User.all
    end

    def show
      user = User.find(params[:id])
      render :json => user.to_json(:include => :elsewheres)
    end

    def create
      user_params = params.permit(
        :fb_uid,
        :name,
        :fb_access_token,
        :email
      )
      user = User.create_or_find_by_uid(user_params.delete(:fb_uid), user_params)

      user.update_facebook_friends
      user.update_facebook_avatar
      user.update_movies_from_facebook

      render :json => user.to_json(:include => :elsewheres)
    end

    def update
      user_params = params.permit(
        :push_id
      )
      if @user.update(user_params)
        render :json => @user
      else
        render :json => { errors: @user.errors }, status: 409
      end
    end

    def friends_index
      user = User.find(params[:id])

      # If has_item is provided, we need both.
      if params[:has_item_type].present? ^ params[:has_item_id].present?
        render plain: "Provide a pair of parameters, has_item_id and has_item_type", status: 400 and return
      end

      # If has_item_type exists, should be valid
      unless [nil, 'AndroidApp'].include?(params[:has_item_type])
        render plain: "Invalid has_item_type, should be AndroidApp", status: 400 and return
      end

      result = user.following

      if params[:has_item_type] && params[:has_item_id]
        result = result.each.map do |user|
          has_item = !user.android_apps.where(id: params[:has_item_id]).empty?
          user = user.serializable_hash
          user[:has_item] = has_item
          user
        end
      end

      render :json => result
    end

    def movies_index
      user = User.find(params[:id])

      render json: user.movies.to_json
    end

    def android_apps_index
      user = User.find(params[:id])
      render :json => user.android_apps.to_json
    end

    def android_apps_create
      render plain: "Send me an array, dumbass", status: 400 and return unless params[:apps].is_a?(Array)

      updated_apps = @user.update_apps(params['apps'])
      render :json => updated_apps.to_json
    end


    def android_apps_delete
      render plain: "Send me a uid param, dumbass!", status: 400 and return unless params[:uid]

      app = AndroidApp.find_by_uid(params[:uid])
      if @user.android_apps.include?(app)
        @user.android_apps.delete(app)
      end

      render :plain => "Deleted"
    end
   end
end

