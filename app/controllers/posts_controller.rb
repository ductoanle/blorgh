class PostsController < ApplicationController
  def index
    @posts = Post.scoped_to(current_account).all
  end

  def show
    @post = Post.scoped_to(current_account).find(params[:id])
  end
end
