use strict;
use warnings;

package Dist::Zilla::Util::BundleInfo;

# ABSTRACT: Load and interpret a bundle

use Moo 1.000008;

sub _coerce_bundle_name {
  require Dist::Zilla::Util;
  return Dist::Zilla::Util->expand_config_package_name( $_[0] );
}

sub _isa_bundle {
  require Module::Runtime;
  Module::Runtime::require_module( $_[0] );
  if ( not $_[0]->can('bundle_config') ) {
    require Carp;
    Carp::croak("$_[0] is not a bundle, as it does not have a bundle_config method");
  }
}

has bundle_name => (
  is       => ro  =>,
  required => 1,
  coerce   => sub { _coerce_bundle_name( $_[0] ) },
  isa      => sub { _isa_bundle( $_[0] ) }
);

has bundle_dz_name => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    return $_[0]->bundle_name;
  },
);

has bundle_payload => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    {};
  },
);

sub plugins {
  my $payload        = $_[0]->bundle_payload;
  my $bundle         = $_[0]->bundle_name;
  my $bundle_dz_name = $_[0]->bundle_dz_name;
  require Dist::Zilla::Util::BundleInfo::Plugin;
  my @out;
  for my $plugin ( $bundle->bundle_config( { name => $bundle_dz_name, payload => $payload } ) ) {
    push @out, Dist::Zilla::Util::BundleInfo::Plugin->inflate_bundle_entry($plugin);
  }
  return @out;
}

no Moo;

1;
