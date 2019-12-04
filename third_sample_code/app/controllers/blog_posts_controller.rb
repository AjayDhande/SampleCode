# encoding: utf-8
class BlogPostsController < BaseController
  before_filter { Feature.enforce!(:weblogs) }

  before_filter :authorize_premium
  before_filter :fetch_models
  before_filter :only_allow_self, :only => [:new, :create, :edit, :update, :destroy]

  helper :users

  uses_tiny_mce

  def index
    if @user.self? && @user.blog_posts.count == 0
      flash[:notice] = t('blog_posts.index.make_your_first')
      redirect_to new_user_blog_post_url(@user)
    else
      @blog_posts = @user.blog_posts.newest_first.paginate(:page => params[:page])
    end
  end

  def show
  end

  def new
    @blog_post = @user.blog_posts.build
  end

  def create
    @blog_post = @user.blog_posts.build(blog_post_params)

    if @blog_post.save
      flash[:notice] = t('blog_posts.create.successful')
      redirect_to_index
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_post.update_attributes(blog_post_params)
      flash[:notice] = t('blog_posts.update.successful')
      redirect_to_index
    else
      render :edit
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to_index
  end

private

  def fetch_models
    @user = params[:user_id] == 'current' ? User.current : User.alive.find(params[:user_id])
    @blog_post = @user.blog_posts.find(params[:id]) if params[:id]
  end

  def redirect_to_index
    redirect_to user_blog_posts_path(@user)
  end

  def blog_post_params
    {}
    params.require(:blog_post).permit(:subject, :body,
                                      illustrations_attributes: [:photo_upload_file, :caption, :user_id, :id, :_destroy]
                                      ) if params[:blog_post]
  end
end
