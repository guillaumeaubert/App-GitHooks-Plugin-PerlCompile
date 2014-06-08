package App::GitHooks::Plugin::PerlCompile;

use strict;
use warnings;

use base 'App::GitHooks::Plugin';

# External dependencies.
use System::Command;

# Internal dependencies.
use App::GitHooks::Constants qw( :PLUGIN_RETURN_CODES );


=head1 NAME

App::GitHooks::Plugin::PerlCompile - Verify that Perl files compile without errors.


=head1 DESCRIPTION

This plugin verifies that staged Perl files compile without errors before
allowing the commit to be completed.


=head1 VERSION

Version 1.0.1

=cut

our $VERSION = '1.0.1';


=head1 METHODS

=head2 get_file_pattern()

Return a pattern to filter the files this plugin should analyze.

	my $file_pattern = App::GitHooks::Plugin::PerlCompile->get_file_pattern(
		app => $app,
	);

=cut

sub get_file_pattern
{
	return qr/\.(?:pl|pm|t|cgi)$/x;
}


=head2 get_file_check_description()

Return a description of the check performed on files by the plugin and that
will be displayed to the user, if applicable, along with an indication of the
success or failure of the plugin.

	my $description = App::GitHooks::Plugin::PerlCompile->get_file_check_description();

=cut

sub get_file_check_description
{
	return 'The file passes perl -c';
}


=head2 run_pre_commit_file()

Code to execute for each file as part of the pre-commit hook.

  my $success = App::GitHooks::Plugin::PerlCompile->run_pre_commit_file();

=cut

sub run_pre_commit_file
{
	my ( $class, %args ) = @_;
	my $file = delete( $args{'file'} );
	my $git_action = delete( $args{'git_action'} );
	my $app = delete( $args{'app'} );
	my $repository = $app->get_repository();

	# Ignore deleted files.
	return $PLUGIN_RETURN_SKIPPED
			if $git_action eq 'D';

	# Execute perl -cw.
	my $path = $repository->work_tree() . '/' . $file;
	my ( $pid, $stdin, $stdout, $stderr ) = System::Command->spawn( $^X, '-cw', $path );

	# Retrieve the output.
	my $output;
	{
			local $/ = undef;
			$output = <$stderr>;
			chomp( $output );
	}

	# Raise an exception if we didn't get "syntax OK".
	die "$output\n"
			if $output !~ /\Q$file syntax OK\E$/x;

	return $PLUGIN_RETURN_PASSED;
}


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-PerlCompile/issues/new>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc App::GitHooks::Plugin::PerlCompile


You can also look for information at:

=over

=item * GitHub's request tracker

L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-PerlCompile/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/app-githooks-plugin-perlcompile>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/app-githooks-plugin-perlcompile>

=item * MetaCPAN

L<https://metacpan.org/release/App-GitHooks-Plugin-PerlCompile>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2013-2014 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
