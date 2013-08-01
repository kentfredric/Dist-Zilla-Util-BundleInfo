use strict;
use warnings;

package Dist::Zilla::Util::BundleInfo;
BEGIN {
  $Dist::Zilla::Util::BundleInfo::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::BundleInfo::VERSION = '0.1.1';
}

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
  isa      => sub { _isa_bundle( $_[0] ) },
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
  },
);

has _mvp_alias_rmap => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    my ($self) = @_;
    return {} unless $self->_loaded_module->can('mvp_aliases');
    my $rmap = {};
    my $fmap = $self->_loaded_module->mvp_aliases;
    for my $key ( keys %{$fmap} ) {
      my $value = $fmap->{$key};
      $rmap->{$value} = [] if not exists $rmap->{$value};
      push @{ $rmap->{$value} }, $key;
    }
    return $rmap;
  },
);

sub _mvp_alias_for {
  my ( $self, $alias ) = @_;
  return unless exists $self->_mvp_alias_rmap->{$alias};
  return @{ $self->_mvp_alias_rmap->{$alias} };
}
has _mvp_multivalue_args => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    return {} unless $_[0]->_loaded_module->can('mvp_multivalue_args');
    my $map = {};
    for my $arg ( $_[0]->_loaded_module->mvp_multivalue_args ) {
      $map->{$arg} = 1;
      for my $alias ( $_[0]->_mvp_alias_for($arg) ) {
        $map->{$alias} = 1;
      }
    }
    return $map;
  },
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
      require Carp;
      Carp::carp( "Multiple specification of non-multivalue key $key for bundle" . $self->bundle_name );
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

__END__

=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::Util::BundleInfo - Load and interpret a bundle

=head1 VERSION

version 0.1.1

=head1 SYNOPSIS

    use Dist::Zilla::Util::BundleInfo;

    # [@RJBS]
    # -myparam = foo
    # param = bar
    # param = quux
    #
    my $info = Dist::Zilla::Util::BundleInfo->new(
        bundle_name => '@RJBS',
        bundle_payload => [
            '-myparam' => 'foo',
            'param'    => 'bar',
            'param'    => 'quux'
        ]
    );
    for my $plugin ( $info->plugins ) {
        print $plugin->to_dist_ini; # emit each plugin in order in dist.ini format.
    }

=head1 METHODS

=head2 C<plugins>

Returns a list of L<< C<::BundleInfo::Plugin>|Dist::Zilla::Util::BundleInfo::Plugin >> instances
representing the configuration data for each section returned by the bundle.

=head1 ATTRIBUTES

=head2 C<bundle_name>

The name of the bundle to get info from

    ->new( bundle_name => '@RJBS' )
    ->new( bundle_name => 'Dist::Zilla::PluginBundle::RJBS' )

=head2 C<bundle_dz_name>

The name to pass to the bundle in the C<name> parameter.

This is synonymous to the value of C<Foo> in

    [@Bundle / Foo]

=head2 C<bundle_payload>

The parameter list to pass to the bundle.

This is synonymous with the properties passed in C<dist.ini>

    {
        foo => 'bar',
        quux => 'do',
        multivalue => [ 'a' , 'b', 'c' ]
    }

C<==>

    [
        'foo' => 'bar',
        'quux' => 'do',
        'multivalue' => 'a',
        'multivalue' => 'b',
        'multivalue' => 'c',
    ]

C<==>

    foo = bar
    quux = do
    multivalue = a
    multivalue = b
    multivalue = c

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Util::BundleInfo",
    "interface":"class",
    "inherits":"Moo::Object"
}


=end MetaPOD::JSON

=p_func C<_coerce_bundle_name>

    _coerce_bundle_name('@Foo') # Dist::Zilla::PluginBundle::Foo

=p_func C<_isa_bundle>

    _isa_bundle('Foo::Bar::Baz') # fatals if Foo::Bar::Baz can't do ->bundle_config

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
