module TestFunctionalHelpers

  def setup(user = nil)
    xhr_readers
    login(user)
  end

  def login(user = nil)
    user = users(user) if user.is_a?(Symbol)
    session[:user] = user || users(:advocate)
  end

  def logout
    session.delete(:user)
  end

  def teardown
    logout
  end

  def xhr_readers
    @request.headers['Accept'] = 'application/json, text/plain, */*'
    @request.headers['X-Requested-With'] = 'XMLHttpRequest'
  end

end