class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :follow, :unfollow, :followers, :followings ]
  before_action :authenticate_user, except: [ :new, :create ]
  
  
   def followers
     @users = @user.followers.page(params[:page])
  end
  
  def followings
     @users = @user.followed_users.page(params[:page])
  end

  
   def show
     @posts = @user.posts.page(params[:page])
  end
  
  # GET /users
  # GET /users.json
  def index
    if params[:search].blank?
      @users = User.all.page(params[:page])
	else
	  @users=User.search do
	    fulltext params[:page]
		paginate(page: params[:page])
		oder_by :creared_at, :desc
		end.results
	end
  end

  # GET /users/1
  # GET /users/1.json

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)
      flash[:success] = "Welcome, #{@user.name}!"
      redirect_to @user
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def follow
    if current_user.follow(@user)
      flash[:success] = "You are following #{@user.name}"
    else
      flash[:error] = "Something went wrong.  You cannot follow #{@user.name}"
    end
    redirect_to :back
  end
  
 
   def unfollow
    if current_user.unfollow(@user)
      flash[:success] = "You are no longer following #{@user.name}"
    else
      flash[:error] = "Something went wrong.  You cannot unfollow #{@user.name}"
    end
    redirect_to :back
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
