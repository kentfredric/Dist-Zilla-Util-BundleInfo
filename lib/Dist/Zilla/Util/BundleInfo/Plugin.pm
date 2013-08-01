
use strict;
use warnings;

package Dist::Zilla::Util::BundleInfo::Plugin;
BEGIN {
  $Dist::Zilla::Util::BundleInfo::Plugin::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::BundleInfo::Plugin::VERSION = '0.1.0';
}

# ABSTRACT: Data about a single plugin instance in a bundle

use Moo 1.000008;

has name    => ( is => ro =>, required => 1 );
has module  => ( is => ro =>, required => 1 );
has payload => ( is => ro =>, required => 1 );

has _loaded_module => (
  is      => ro =>,
  lazy    => 1,
  builder => sub {
    require Module::Runtime;
    Module::Runtime::require_module( $_[0]->module );
    return $_[0]->module;
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

sub inflate_bundle_entry {
  my ( $self, $entry ) = @_;
  my ( $name, $module, $payload ) = @{$entry};
  return $self->new( name => $name, module => $module, payload => $payload );
}

sub to_bundle_entry {
  return [ $_[0]->name, $_[0]->module, $_[0]->payload ];
}

sub short_module {
  my ($self) = @_;
  my $name = $self->module;
  if ( $name =~ /^Dist::Zilla::Plugin::(.*$)/ ) {
    return "$1";
  }
  return "=$name";
}

sub to_dist_ini {
  my @out;
  push @out, sprintf '[%s / %s]', $_[0]->short_module, $_[0]->name;
  my $payload = $_[0]->payload;
  for my $key ( sort keys %{$payload} ) {
    my $value = $payload->{$key};
    if ( not ref $value ) {
      push @out, sprintf "%s = %s", $key, $value;
      next;
    }
    if ( ref $value eq 'ARRAY' ) {
      if ( not $_[0]->_property_is_mvp_multi($key) ) {
        require Carp;
        Carp::carp( "$key is not an MVP multi-value for " . $_[0]->module );
      }
      for my $element ( @{$value} ) {
        if ( not ref $element ) {
          push @out, sprintf "%s = %s", $key, $element;
          next;
        }
        require Carp;
        Carp::croak("2 Dimensional arrays cannot be exported to distini format");
      }
      next;
    }
  }
  return join qq{\n}, @out, q[], q[];
}

no Moo;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::Util::BundleInfo::Plugin - Data about a single plugin instance in a bundle

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
