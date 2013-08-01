use strict;
use warnings;

package Dist::Zilla::Util::BundleInfo;
BEGIN {
  $Dist::Zilla::Util::BundleInfo::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::BundleInfo::VERSION = '0.1.0';
}

# ABSTRACT: Load and interpret a bundle

use Moo 1.000008;

sub _coerce_bundle_name {
    require Dist::Zilla::Util;
    return Dist::Zilla::Util->expand_config_package_name($_[0]);
}
sub _isa_bundle {
    require Module::Runtime;
    Module::Runtime::require_module($_[0]);
    if ( not $_[0]->can('bundle_config') ) {
        require Carp;
        Carp::croak("$_[0] is not a bundle, as it does not have a bundle_config method");
    }
}


has bundle_name => ( 
    is => ro =>, required => 1, 
    coerce => sub { _coerce_bundle_name($_[0]) },
    isa    => sub { _isa_bundle($_[0] ) }
);

has bundle_payload => (
    is => ro =>, lazy => 1, builder => sub {
        {} 
    },
);

sub plugins {
    my $payload = $_[0]->bundle_payload;
    my $bundle  = $_[0]->bundle_name;
    require Dist::Zilla::Util::BundleInfo::Plugin;
    my @out;
    for my $plugin ( $bundle->bundle_config({ payload => $payload }) ) {
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

version 0.1.0

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
