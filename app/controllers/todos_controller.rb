class TodosController < ApplicationController
    #在執行 show edit update destroy controller action 前，會先執行find_todo此action
      before_action :find_todo, :only => [:show, :edit, :update, :destroy]

      def index
        # 依到期日 (due_date) 近到遠，取得 todos
        @todos = Todo.order(due_date: :asc)
      end

      def status
         @todo.update(is_public: !(@todo.status))
       #status: nil, !nil =>true
       #is_public: true =>預設為true,代表預設為打勾
      end

      def new
        @todo = Todo.new
      end

      def create
        # 依傳入參數 new 一個 Todo 實例
        @todo = Todo.new(todo_params)

        # 如果驗證成功，則儲存，並回到列表頁，告知成功新增
        # 如果驗證失敗，則不儲存，並保留已填寫資訊，回到 new，繼續填寫
        if @todo.save
          # 跳出通知訊息，告知成功新增  flash[:notice] = 'List was successfully created !!'
          # 重新發出 request，導往列表頁。對瀏覽器來說會重整頁面
          flash[:notice] = 'List was successfully created!!'
          redirect_to todos_path
        else
          # 當驗證失敗時，將 @todo 傳入 new.html.erb 做 render
          # 以達成體驗上：「保留已填寫資料，讓使用者可以繼續填寫錯誤的部分」
          render :new
        end
      end


      def show;
      end


      def edit;
        #前面有先傳入id參數 直接入edit畫面，
        #另外加條件   若due_date < Date.today,則出現flash訊息,畫面跳轉回index頁面，
        if @todo.overdue?
           flash[:alert] = 'List is overdue, can not be edited !!'
           redirect_to todos_path
        end
      end

#
      def update
        # before_action :find_todo 取代
        # 如果驗證成功，則更新，並回到列表頁，告知成功更新
        # 如果驗證失敗，則不更新，並保留已填寫資訊，回到 edit，繼續填寫
        if @todo.update_attributes(todo_params)
           flash[:notice] = 'List was successfully updated!!'
          # 跳出通知訊息，告知成功更新  flash[:notice] = 'List was successfully updated !!'
          # 重新發出 request，導往列表頁。對瀏覽器來說會重整頁面
           redirect_to todos_path
        else
          # 當驗證失敗時，將 @todo 傳入 edit.html.erb 做 render
          # 以達成體驗上：「保留已填寫資料，讓使用者可以繼續填寫錯誤的部分」
           render :edit
        end
      end

      def destroy
        if @todo.can_destroy? #can_destroy定義在todo.rb
           @todo.destroy
           # 跳出警告訊息，告知成功刪除
           flash[:alert] = 'List was successfully deleted!!'
           # 重新發出 request，導往列表頁。對瀏覽器來說會重整頁面
           redirect_to todos_path
        else
           # 跳出警告訊息，告知過期
           flash[:alert] = 'List is overdue, can not be deleted !!'
           # 重新發出 request，導往列表頁。對瀏覽器來說會重整頁面
           redirect_to todos_path
        end
      end

#        if @todo.due_date.past?
#          flash[:alert] = 'List is overdue, can not be deleted !!'
#        else
#          @todo.destroy
#        end
#        redirect_to todos_url

      private

      # 在 #edit, #update, #destroy 都有找到特定 ID todo 的需求
      # 於是可以提取出 before_action :find_todo
      # 在以上三個 actions 執行之前，先找出特定 ID 的 todo
      # 方法命名 (find_todo) 只是慣用，實際上可自行決定
      def find_todo
        @todo = Todo.find(params[:id])
      end

      # Term: strong parameters, > Rails 4 only.
      # 基於安全性考量，不可以直接將未經允許 (permit) 的參數傳入 model 做新增或修改
      # 可視需求在各 controller 分開獨立指定允許的內容
      # 方法命名 (todo_params) 只是慣用，實際上可自行決定
      def todo_params
        # params 變數是 Rails 在消化完 http request 後，所留下的 controller 常用參數群
        # #require 方法裡的 symbol 與 form 送回的物件名稱相同
        # #permit  方法裡的 symbol 與 form 送回的物件欄位名稱相同
        params.require(:todo).permit(:task, :due_date, :note, :status)
      end

    end
