class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  

  # GET /books
  # GET /books.json
  def index
    #@books = Book.limit(100)
    @books = Book.page(params[:page]).per(10).order(:id)
    @books = @books.joins(:categories).where(categories: {id: params[:category][:category_id]})  if params.include? :category
    @books = @books.where("title LIKE ? ",  "%#{params[:search]}%" )  if params.include? :search
    @categories = Category.limit(100).pluck(:name, :id)    
   end

  # GET /books/1
  # GET /books/1.json
  def show
    respond_to do |format|
      format.js{}
      format.html{}
    end
  end

  # GET /books/new
  def new
    @book = Book.new
    @categories = Category.limit(100)
    respond_to do |format|
      format.js{}
      format.html{}
    end
  end

  # GET /books/1/edit
  def edit
    respond_to do |format|
      format.js{}
      format.html{}
    end
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)
    set_categories
    @book.save
    respond_to do |format|
      if @book.save
        format.js { }
        format.json { render :show, status: :created, location: @book }
      else
        @categories = Category.limit(100)
        format.js { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    @book.categories.clear
    set_categories
    respond_to do |format|
      if @book.update(book_params)
        format.js {flash[:notice] = "successfully updated book!"}
        # format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render :show, status:ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # def borrow
  #  @book = Book.find(params[:book_id])
  #  @book.update_attribute(:borrower, current_user.email)
  #  UserMailer.with(user: current_user, book: @book).welcome_email.deliver_later    # Tell the UserMailer to send a welcome email after save   
  #  #ManageBorrowersJob.perform_later 
  #  redirect_to books_url
  # end

  def borrow
   @book = Book.find(params[:book_id])
    if @book.borrow(current_user)
      redirect_to books_url, notice: 'Book was succesfully updated'
    end
      #@book.borrower ? [@book.update_attribute(:borrower, current_user.email), UserMailer.with(user: current_user, book: @book).welcome_email.deliver_later ] : @book.update_attribute(:borrower, nil)
  end

  def email_query
    @book = Book.find(params[:book_id])
    UserMailer.with(borrower: @book.borrower, book: @book, querier: current_user).enquiry_email.deliver_later
    redirect_to books_url
  end

  def book_by_category
    @categories = Category.limit(100)
    @books = Book.limit(100).where('categories.id': 2)
    render 'index'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
      @categories = Category.limit(100)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params    
     params.require(:book).permit(:title, :description, :image, :borrower, :categories)
  
    end

    def set_categories
      if params[:book][:categories]
        params[:book][:categories].each do |c|
            @book.categories << Category.find(c.to_i) 
        end  
      end
    end

end
