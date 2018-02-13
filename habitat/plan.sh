pkg_name="sandy-landfall"
pkg_version=$(cat "${PLAN_CONTEXT}/../VERSION")
pkg_origin="uafgina"
pkg_maintainer="UAF GINA <support+habitat@gina.alaska.edu>"
pkg_license=('MIT')
#pkg_source="https://github.com/gina-alaska/${pkg_name}/tree/${pkg_version}"
#pkg_source=${pkg_name}-${pkg_version}.tar.bz2
pkg_svc_user="processing"
pkg_svc_group="processing"
#pkg_scaffolding="core/scaffolding-ruby"
pkg_svc_user="processing"
pkg_svc_group="processing"


pkg_deps=(
  uafgina/conveyor
)
pkg_build_deps=(
  core/gcc
  core/make
  core/libffi
  uafgina/conveyor
)

do_build() {
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"
  local _bundler_dir=$(hab pkg path core/bundler)

  export GEM_HOME=${pkg_path}/vendor/bundler
  export GEM_PATH=${_bundler_dir}:${GEM_HOME}
  export PATH=${PATH}:$(hab pkg path core/bundler)/bin

  if [[ -z "`grep 'gem .*rb-readline.*' Gemfile`" ]]; then
    echo 'gem "rb-readline"' >> Gemfile
  fi

  build_line "Vendoring Gems"
  bundle install --jobs 2 --retry 5 --path vendor/bundle --without development test
}

do_install() {
  cp -R workers/ ${pkg_prefix}/workers
  cp -R vendor/ ${pkg_prefix}/vendor
}
