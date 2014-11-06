class archive::faraday_middleware {
  package { 'faraday_middleware':
    ensure   => installed,
    provider => gem,
  }
}
