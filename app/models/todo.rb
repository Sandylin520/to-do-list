class Todo < ApplicationRecord
  validates_presence_of :task, :due_date

  # 判斷是否能夠刪除
  # 判斷條件可能有很多，所以將各項判斷分拆到 private method
  def can_destroy?
    # 沒過期的話，回傳 true = 可刪除
    !overdue?
  end

  def overdue?
    due_date < Date.today
  end

end
