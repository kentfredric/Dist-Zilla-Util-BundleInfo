use strict;
use warnings;

package Dist::Zilla::Util::BundleInfo;

# ABSTRACT: Load and interpret a bundle

use Moo 1.000008;

=head1 SYNOPSIS

    use Dist::Zilla::Util::BundleInfo;

    my $info = Dist::Zilla::Util::BundleInfo->new(
        bundle_name => '@RJBS',
        bundle_payload => {

        }
    );

=cut

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
    [];
  },
);
has _loaded_module => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    require Module::Runtime;
    Module::Runtime::require_module( $_[0]->bundle_name );
    return $_[0]->bundle_name;
  }
);
has _mvp_multivalue_args => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    return {} unless $_[0]->_loaded_module->can('mvp_multivalue_args');
    return { map { ( $_, 1 ) } $_[0]->_loaded_module->mvp_multivalue_args };
  }
);

sub _property_is_mvp_multi {
  my ( $self, $property ) = @_;
  return exists $self->_mvp_multivalue_args->{$property};
}

sub _array_to_hash {
  my ( $self, @orig_payload ) = @_;
  my $payload = {};
  my ( $key_i, $value_i ) = ( 0, 1 );
  while ( $value_i <= $#orig_payload ) {
    my ($key)   = $orig_payload[$key_i];
    my ($value) = $orig_payload[$value_i];
    if ( $self->_property_is_mvp_multi($key) ) {
      $payload->{$key} = [] if not exists $payload->{$key};
      push @{ $payload->{$key} }, $value;
      next;
    }
    if ( exists $payload->{$key} ) {
      warn "Multiple specification of non-multivalue key $key for bundle" . $self->bundle_name;
      if ( not ref $payload->{$key} ) {
        $payload->{$key} = [ $payload->{$key} ];
      }
      push @{ $payload->{$key} }, $value;
      next;
    }
    $payload->{$key} = $value;
  }
  continue {
    $key_i   += 2;
    $value_i += 2;
  }
  return $payload;
}

sub plugins {
  my $self           = $_[0];
  my $payload        = $self->bundle_payload;
  my $bundle         = $self->bundle_name;
  my $bundle_dz_name = $self->bundle_dz_name;
  require Dist::Zilla::Util::BundleInfo::Plugin;
  my @out;
  if ( ref $payload eq 'ARRAY' ) {
    $payload = $self->_array_to_hash( @{$payload} );
  }
  for my $plugin ( $bundle->bundle_config( { name => $bundle_dz_name, payload => $payload } ) ) {
    push @out, Dist::Zilla::Util::BundleInfo::Plugin->inflate_bundle_entry($plugin);
  }
  return @out;
}

no Moo;

1;
