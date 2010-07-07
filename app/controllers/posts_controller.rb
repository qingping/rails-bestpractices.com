class PostsController < InheritedResources::Base
  before_filter :require_user, :only => [:new, :edit, :create, :update, :destroy]
  has_scope :recent, :only => :index
  
  protected
    def begin_of_association_chain
      @current_user
    end
end
