class AccountActivationsController < ApplicationController

  before_action :check_expiration_active, only: :edit

  def create
    @user = User.find_by email: params[:account_activation][:email].downcase
    if @user
      @user.create_activation_sent_at_digest
      @user.send_activation_email
      flash[:info] = "Email sent active account"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render :new
    end
  end

  def edit
    @user = User.find_by email: params[:email]
    if @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
      @user.activate
      # user.update_attribute :activated, true
      # user.update_attribute :activated_at, Time.zone.now
      log_in @user
      flash[:success] = "Account activated!"
      redirect_to @user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

  def new
    
  end
  # def resend_email
    
  # end


  private

  def check_expiration_active
    @user = User.find_by email: params[:email].downcase
    if @user.account_activation_expired?
      flash[:danger] = "Active account has expired."
      redirect_to root_url
    end
  end
end
