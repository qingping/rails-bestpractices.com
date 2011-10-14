class PostsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update, :destroy]
  has_scope :implemented
  respond_to :xml, :only => :index

  def new
    if params[:answer_id]
      @post = Answer.find_cached(params[:answer_id]).to_post
    else
      @post = Post.new
      @post.build_post_body
    end
  end

  def show
    if params[:id] != @post.to_param
      redirect_to post_path(@post), :status => 301
      return false
    end
    show! do |format|
      Post.increment_counter(:view_count, @post.id)
      @comment = @post.comments.build
    end
  end

  create! do |success, failure|
    success.html { redirect_to posts_path }
    failure.html { render :new }
  end

  def archive
    @posts = Post.published
  end

  protected
    def begin_of_association_chain
      current_user
    end

    def resource
      @post = params[:action] == "update" ? Post.find(params[:id]) : Post.find_cached(params[:id])
      @post = PostDecorator.new(@post)
    end

    def collection
      @posts = Post.published
      @posts = @posts.where(:implemented => true) if params[:nav] == 'implemented'
      @posts = @posts.order(nav_order).page(params[:page].to_i)
    end

    def nav_order
      params[:nav] = "created_at" unless %w(created_at vote_points comments_count implemented).include?(params[:nav])
      params[:order] = "desc" unless %w(desc asc).include?(params[:order])
      "posts.#{params[:nav] == 'implemented' ? 'created_at' : params[:nav]} #{params[:order]}"
    end
end
