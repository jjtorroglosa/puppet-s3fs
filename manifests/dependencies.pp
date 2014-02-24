class s3fs::dependencies {
  ensure_packages([
    'build-essential',
    'automake',
    'libfuse-dev',
    'fuse-utils',
    'libcurl4-openssl-dev',
    'libxml2-dev',
    'mime-support'
  ])
}
