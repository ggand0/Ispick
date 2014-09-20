module OmniauthMacros
  def mock_auth_hash
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: 'twitter',
      uid: '12345678',
      info: { nickname: 'pentiumx' },
      credentials: OmniAuth::AuthHash.new({})
    })
    #OmniAuth.config.add_mock(:twitter, {:uid => '1234'})
  end
end