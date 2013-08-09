use strict;
use ExtUtils::MakeMaker 6.31;

my $meta = {
  "abstract"           => "a distinctly Dist-Inkt-flavoured distribution mint",
  "author"             => ["Toby Inkster <tobyink\@cpan.org>"],
  "dynamic_config"     => 0,
  "generated_by"       => "Dist::Inkt::Profile::TOBYINK version 0.001, CPAN::Meta::Converter version 2.120921",
  "keywords"           => [],
  "license"            => ["perl_5"],
  "meta-spec"          => {
                            url => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
                            version => 2,
                          },
  "name"               => "Dist-Inktly-Minty",
  "no_index"           => { directory => ["eg", "examples", "inc", "t", "xt"] },
  "prereqs"            => {
                            configure => { requires => { "ExtUtils::MakeMaker" => 6.31 } },
                            runtime   => {
                                           requires => {
                                             "Getopt::ArgvFile" => 0,
                                             "Path::Tiny" => 0,
                                             "perl" => 5.010001,
                                             "Software::License" => 0,
                                             "Text::Template" => 0,
                                             "URI::Escape" => 0,
                                           },
                                         },
                          },
  "provides"           => {
                            "Dist::Inktly::Bovine"  => { file => "lib/Dist/Inktly/Bovine.pm", version => 0.001 },
                            "Dist::Inktly::Cervine" => { file => "lib/Dist/Inktly/Cervine.pm", version => 0.001 },
                            "Dist::Inktly::Minty"   => { file => "lib/Dist/Inktly/Minty.pm", version => 0.001 },
                          },
  "release_status"     => "stable",
  "resources"          => {
                            bugtracker => {
                                            web => "http://rt.cpan.org/Dist/Display.html?Queue=Dist-Inktly-Minty",
                                          },
                            homepage   => "https://metacpan.org/release/Dist-Inktly-Minty",
                            license    => ["http://dev.perl.org/licenses/"],
                            repository => {
                                            type => "git",
                                            web  => "https://github.com/tobyink/p5-dist-inktly-minty",
                                          },
                          },
  "version"            => 0.001,
  "x_contributors"     => [],
  "x_provides_scripts" => { "distinkt-mint" => { file => "bin/distinkt-mint" } },
};

my %dynamic_config;

my %WriteMakefileArgs = (
	ABSTRACT           => $meta->{abstract},
	AUTHOR             => $meta->{author},
	DISTNAME           => $meta->{name},
	DISTVNAME          => sprintf('%s-%s', $meta->{name}, $meta->{version}),
	EXE_FILES          => [ map $_->{file}, values %{ $meta->{x_provides_scripts} || {} } ],
	LICENSE            => $meta->{license}[0],
	NAME               => do { my $n = $meta->{name}; $n =~ s/-/::/g; $n },
	VERSION            => $meta->{version},
	%dynamic_config,
);

sub deps
{
	my %r;
	for my $stage (@_)
	{
		for my $dep (keys %{$meta->{prereqs}{$stage}{requires}})
		{
			my $ver = $meta->{prereqs}{$stage}{requires}{$dep};
			$r{$dep} = $ver if !exists($r{$dep}) || $ver >= $r{$dep};
		}
	}
	\%r;
}

my ($build_requires, $configure_requires, $runtime_requires, $test_requires);
if ('ExtUtils::MakeMaker'->VERSION >= 6.6303)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure');
	$WriteMakefileArgs{TEST_REQUIRES}      ||= deps('test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');
}
elsif ('ExtUtils::MakeMaker'->VERSION >= 6.5503)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure', 'test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');	
}
elsif ('ExtUtils::MakeMaker'->VERSION >= 6.52)
{
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure', 'build', 'test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');	
}
else
{
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('configure', 'build', 'test', 'runtime');	
}

{
	my $minperl = delete $WriteMakefileArgs{PREREQ_PM}{perl};
	exists($WriteMakefileArgs{$_}) && delete($WriteMakefileArgs{$_}{perl})
		for qw(BUILD_REQUIRES TEST_REQUIRES CONFIGURE_REQUIRES);
	if ($minperl and 'ExtUtils::MakeMaker'->VERSION >= 6.48)
	{
		$WriteMakefileArgs{MIN_PERL_VERSION} ||= $minperl;
	}
	elsif ($minperl)
	{
		die "Need Perl >= $minperl" unless $] >= $minperl;
	}
}

sub FixMakefile
{
	return unless -d 'inc';
	my $file = shift;
	
	local *MAKEFILE;
	open MAKEFILE, "< $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	my $makefile = do { local $/; <MAKEFILE> };
	close MAKEFILE or die $!;
	
	$makefile =~ s/\b(test_harness\(\$\(TEST_VERBOSE\), )/$1'inc', /;
	$makefile =~ s/( -I\$\(INST_ARCHLIB\))/ -Iinc$1/g;
	$makefile =~ s/( "-I\$\(INST_LIB\)")/ "-Iinc"$1/g;
	$makefile =~ s/^(FULLPERL = .*)/$1 "-Iinc"/m;
	$makefile =~ s/^(PERL = .*)/$1 "-Iinc"/m;
	
	open  MAKEFILE, "> $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	print MAKEFILE $makefile or die $!;
	close MAKEFILE or die $!;
}

my $mm = WriteMakefile(%WriteMakefileArgs);
FixMakefile($mm->{FIRST_MAKEFILE} || 'Makefile');
exit(0);

