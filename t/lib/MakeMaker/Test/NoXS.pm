package MakeMaker::Test::NoXS;

# Disable all XS loading.

require DynaLoader;
require XSLoader;

# Things like Cwd key on this to decide if they're running miniperl
delete $DynaLoader::{boot_DynaLoader};

# This isn't 100%.  Things like Win32.pm will crap out rather than
# just not load.  See ExtUtils::MM->_is_win95 for an example
no warnings 'redefine';
*DynaLoader::bootstrap = sub { die "Tried to load XS for @_\nTrace:\n"._stacktrace()."\n"; };
*XSLoader::load        = sub { die "Tried to load XS for @_\nTrace:\n"._stacktrace()."\n"; };

sub _stacktrace {
    my $call_string = '';

    ## first, get raw stack info as deep as we can
    my @calls;
    my $i = 0;
    while ( my @call = caller($i) ) {
        push @calls, \@call;
        $i++;
    }

    shift @calls;

    my @call_strings;
    for ( reverse @calls ) {
        next if !$_->[2];
        $_->[1] = 'main' if $_->[0] eq 'main';
        push @call_strings, "   $_->[3]() called at $_->[1] line $_->[2]\n";
    }

    $call_string = join '', @call_strings;

	return $call_string;
}

1;
