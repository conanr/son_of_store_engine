class UsersController < ApplicationController
  before_filter :lookup_user, :only => [:show, :edit, :destroy, :update]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :require_admin, :only => [:index, :destroy, :create]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @notice = 'Welcome Aboard'
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to root_url, notice: @notice }
      else
        format.html { render action: "new" }
      end
    end
  end

  def destroy
    User.destroy(@user)
    redirect_to users_path
  end

  def edit
  end

  def update
    @user.update_attributes(params[:user])
    redirect_to user_path(@user)
  end

  private

  def lookup_user
    @user = User.find(params[:id])
  end

end