use ExtUtils::MakeMaker;
WriteMakefile(
    NAME			=> 'Data::Phrasebook::Loader::DBI',
    VERSION_FROM	=> 'lib/Data/Phrasebook/Loader/DBI.pm',
    PREREQ_PM		=> {
		'Data::Phrasebook' => '0.18',
        'DBI'              => '1.38',
        'Test::More'       => '0.47',
    },
    ($] >= 5.005 ?
		(ABSTRACT_FROM => 'lib/Data/Phrasebook/Loader/DBI.pm',
		 AUTHOR        => 'Barbie <barbie@cpan.org>') : ()),
);
