module RequestHelpers
  def fake_handle
    Fabricate.build('user').handle
  end
end
