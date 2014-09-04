class archive::params {
  if $::is_pe {
    $gem_provider = 'pe_gem'
  } else {
    $gem_provider = 'gem'
  }
}
