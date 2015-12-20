
use strict;
use warnings;

use Test::More;

# FILENAME: array_nonmvp.t
# CREATED: 10/17/14 10:44:31 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test a non-mvp attribute being passed an array

use Dist::Zilla::Util::BundleInfo::Plugin;
use Dist::Zilla::Plugin::GatherDir;

my $plugin = Dist::Zilla::Util::BundleInfo::Plugin->new(
  name    => 'GatherDir',
  module  => 'Dist::Zilla::Plugin::GatherDir',
  payload => {
    root => ['./'],
  },
);

my $out = $plugin->to_dist_ini;
note $out;

done_testing;

