notice(artifactory_sha1('http://bit.ly/1Tfk4vQ'))

archive::artifactory { '/tmp/logo.png':
  url => 'https://repo.jfrog.org/artifactory/distributions/images/Artifactory_120x75.png',
}
