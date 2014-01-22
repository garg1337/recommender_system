class UsersController < ApplicationController
  
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :show]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  before_filter :signed_out_user, only: [:new, :create]


  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @gen_recs = params[:gen_recs]
    @game_ratings = @user.game_ratings.paginate(page: params[:page])



    if @gen_recs == 'true'
      PygmentsWorker.perform_async(@user.id)

    end
    
  end

  def create
    @user = User.new(params[:user])

    @reccomendation = @user.create_reccommendation()

    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    # @reccomendation = @user.create_reccommendation()

    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def admin_user
      @target_user = User.find(params[:id])
      redirect_to(root_path) unless (current_user.admin? && !(target_user.admin?))
    end

    def signed_out_user
      if signed_in?
        redirect_to root_path
      end
    end
  end