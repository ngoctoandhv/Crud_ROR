class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,:following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page],per_page: 10)
  end

  def show
    @user = User.find_by id: params[:id]
    @micropost = current_user.microposts.build if logged_in?
    @microposts = @user.microposts.paginate(page: params[:page],per_page: 10)
    @users = @user.following.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      #@user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following
      .paginate(page: params[:page])
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers
      .paginate(page: params[:page])
    render "show_follow"
  end

  private
  def user_params
    params.require(:user).permit(:name, :yob, :email, :password, :password_confirmation) 
  end

  #   # Before filters
  # # Confirms a logged-in user.
  # def logged_in_user
  #   unless logged_in?
  #     flash[:danger] = "Please log in."
  #     redirect_to login_url
  #   end
  # end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      flash[:danger] = "Have no permission"
      redirect_to(root_url) 
    end
  end
    # Confirms an admin user.
  #xem co phai admin khong.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
