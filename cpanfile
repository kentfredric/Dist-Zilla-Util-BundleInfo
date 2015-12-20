requires "Carp" => "0";
requires "Dist::Zilla::Util" => "0";
requires "Module::Runtime" => "0";
requires "Moo" => "1.000008";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Dist::Zilla::Plugin::GatherDir" => "0";
  requires "Dist::Zilla::PluginBundle::Basic" => "0";
  requires "Dist::Zilla::PluginBundle::Classic" => "0";
  requires "Dist::Zilla::Role::Plugin" => "0";
  requires "Dist::Zilla::Role::PluginBundle" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "Moose" => "0";
  requires "Test::More" => "0.89";
  requires "Test::Warnings" => "0";
  requires "perl" => "5.006";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
  recommends "ExtUtils::MakeMaker" => "7.00";
  recommends "Moose" => "2.000";
  recommends "Test::More" => "0.99";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "5.006";
};

on 'configure' => sub {
  recommends "ExtUtils::MakeMaker" => "7.00";
};

on 'develop' => sub {
  requires "Dist::Zilla" => "5";
  requires "Dist::Zilla::Plugin::Author::KENTNL::CONTRIBUTING" => "0.001003";
  requires "Dist::Zilla::Plugin::Author::KENTNL::RecommendFixes" => "0.004002";
  requires "Dist::Zilla::Plugin::Author::KENTNL::TravisCI" => "0.001002";
  requires "Dist::Zilla::Plugin::Authority" => "1.006";
  requires "Dist::Zilla::Plugin::AutoPrereqs" => "0";
  requires "Dist::Zilla::Plugin::BumpVersionAfterRelease" => "0";
  requires "Dist::Zilla::Plugin::CPANFile" => "0";
  requires "Dist::Zilla::Plugin::ConfirmRelease" => "0";
  requires "Dist::Zilla::Plugin::CopyFilesFromBuild" => "0";
  requires "Dist::Zilla::Plugin::Git::Check" => "0";
  requires "Dist::Zilla::Plugin::Git::Commit" => "0";
  requires "Dist::Zilla::Plugin::Git::CommitBuild" => "0";
  requires "Dist::Zilla::Plugin::Git::Contributors" => "0.006";
  requires "Dist::Zilla::Plugin::Git::GatherDir" => "0";
  requires "Dist::Zilla::Plugin::Git::NextRelease" => "0.004000";
  requires "Dist::Zilla::Plugin::Git::Tag" => "0";
  requires "Dist::Zilla::Plugin::GithubMeta" => "0";
  requires "Dist::Zilla::Plugin::License" => "0";
  requires "Dist::Zilla::Plugin::MakeMaker" => "0";
  requires "Dist::Zilla::Plugin::Manifest" => "0";
  requires "Dist::Zilla::Plugin::ManifestSkip" => "0";
  requires "Dist::Zilla::Plugin::MetaConfig" => "0";
  requires "Dist::Zilla::Plugin::MetaJSON" => "0";
  requires "Dist::Zilla::Plugin::MetaProvides::Package" => "1.14000001";
  requires "Dist::Zilla::Plugin::MetaTests" => "0";
  requires "Dist::Zilla::Plugin::MetaYAML::Minimal" => "0";
  requires "Dist::Zilla::Plugin::MinimumPerl" => "0";
  requires "Dist::Zilla::Plugin::PodCoverageTests" => "0";
  requires "Dist::Zilla::Plugin::PodSyntaxTests" => "0";
  requires "Dist::Zilla::Plugin::PodWeaver" => "0";
  requires "Dist::Zilla::Plugin::Prereqs" => "0";
  requires "Dist::Zilla::Plugin::Prereqs::AuthorDeps" => "0";
  requires "Dist::Zilla::Plugin::Prereqs::Recommend::MatchInstalled" => "0";
  requires "Dist::Zilla::Plugin::Prereqs::Upgrade" => "0";
  requires "Dist::Zilla::Plugin::Readme::Brief" => "0";
  requires "Dist::Zilla::Plugin::ReadmeAnyFromPod" => "0";
  requires "Dist::Zilla::Plugin::RemovePrereqs::Provided" => "0";
  requires "Dist::Zilla::Plugin::RewriteVersion::Sanitized" => "0";
  requires "Dist::Zilla::Plugin::RunExtraTests" => "0";
  requires "Dist::Zilla::Plugin::Test::CPAN::Changes" => "0";
  requires "Dist::Zilla::Plugin::Test::Compile::PerFile" => "0";
  requires "Dist::Zilla::Plugin::Test::EOL" => "0";
  requires "Dist::Zilla::Plugin::Test::Kwalitee" => "0";
  requires "Dist::Zilla::Plugin::Test::MinimumVersion" => "0";
  requires "Dist::Zilla::Plugin::Test::Perl::Critic" => "0";
  requires "Dist::Zilla::Plugin::Test::ReportPrereqs" => "0";
  requires "Dist::Zilla::Plugin::TestRelease" => "0";
  requires "Dist::Zilla::Plugin::Twitter" => "0";
  requires "Dist::Zilla::Plugin::UploadToCPAN" => "0";
  requires "English" => "0";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Software::License::Perl_5" => "0";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::EOL" => "0";
  requires "Test::Kwalitee" => "1.21";
  requires "Test::More" => "0.96";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};

on 'develop' => sub {
  recommends "Test::More" => "0.99";
};

on 'develop' => sub {
  suggests "Dist::Zilla::App::Command::bakeini" => "0.002005";
  suggests "Dist::Zilla::PluginBundle::Author::KENTNL" => "2.025010";
};
