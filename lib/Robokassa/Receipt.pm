package Robokassa::Receipt;
use strict;
use warnings;
use utf8;
use JSON::MaybeXS ();
use Carp qw(croak);

our $VERSION = '0.001';

sub new {
    my ( $class, $sno ) = @_;

    my $self = { items => [] };

    croak 'Wrong sno passed' if ( defined $sno && !_check_sno($sno) );

    $self->{sno} = $sno if ( defined $sno );

    bless $self, $class;

    return $self;
}

sub _check_sno {
    my $sno = $_[0];

    return 1
      if grep { $sno eq $_ }
      qw (osn usn_income usn_income_outcome envd esn patent);

    return 0;
}

sub _check_payment_method {
    my $sno = $_[0];

    return 1
      if grep { $sno eq $_ }
      qw (full_prepayment prepayment advance full_payment partial_payment credit credit_payment);

    return 0;
}

sub _check_payment_object {
    my $sno = $_[0];

    return 1
      if grep { $sno eq $_ }
      qw (commodity excise job service gambling_bet gambling_prize lottery lottery_prize intellectual_activity payment agent_commission composite another property_right non-operating_gain insurance_premium sales_tax resort_fee);

    return 0;
}

sub _check_tax {
    my $sno = $_[0];

    return 1 if grep { $sno eq $_ } qw (none vat0 vat10 vat110 vat20 vat120);

    return 0;
}

sub sno {
    my ( $self, $sno ) = @_;

    if ( $self && $sno && _check_sno($sno) ) {
        $self->{sno} = $sno;
        return 1;
    }

    croak 'Wrong sno passed';
}

sub add_item {
    my ( $self, %args ) = @_;

    my %available =
      map { $_ => 1 } qw(name sum quantity payment_method payment_object tax);
    foreach ( keys %args ) {
        croak 'Unknown parameter: ' . $_ if ( !exists( $available{$_} ) );
    }

    foreach (qw (name sum)) {
        if ( !defined( $args{$_} ) ) {
            croak $_. ' is not defined';
            return 0;
        }
    }

    croak 'Wrong sum:' . $args{sum} if ( $args{sum} !~ /^\d+([\.\,]\d+)?$/ );
    croak 'Wrong quantity:' . $args{quantity}
      if ( defined( $args{quantity} ) && $args{quantity} =~ /\D/ );

    {
        no strict 'refs';

        foreach (qw (payment_method payment_object tax)) {

            if ( defined( $args{$_} ) ) {

                my $sub = *{ '_check_' . $_ };

                if ( !&$sub( $args{$_} ) ) {
                    croak 'Unknown ' . $_ . ' value: ' . $args{$_};
                    return 0;
                }

            }

        }
    }

    $args{quantity} = 1 if ( !defined( $args{quantity} ) || !$args{quantity} );

    push @{ $self->{items} }, \%args;

    return 1;
}

sub items {
    my $self = $_[0];
    return $self->{items};
}

sub json {
    my $self = $_[0];
    my $hash = { items => $self->{items} };
    $hash->{sno} = $self->{sno} if ( defined( $self->{sno} ) );
    return JSON::MaybeXS::encode_json($hash);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Robokassa::Receipt - creates a Receipt object for Robokassa::Pay interface.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use Robokassa::Pay;
    use Robokassa::Receipt;

    # Creating a payment object
    my $robokassa = Robokassa::Pay->new(
        MerchantLogin => 'your login',
        Password1 =>'your password1',
        OutSum =>1000,
        InvDesc => 'Order #123'
    );

    # Creating a receipt object
	my $receipt = Robokassa::Receipt->new();

	$receipt->sno('usn_income'); # Set a system of taxation

    # Add an item to the receipt
    $receipt->add_item(
        name => 'Something',
        quantity => 1,
        sum => 1000,
        payment_method => 'full_payment',
        payment_object => 'commodity',
        tax => 'none'
    );

    $robokassa -> param(Receipt => $receipt); # Add the receipt to the payment object

    # Create a payment link for a customer
    my $link = $robokassa->get_url();
    print "Please click <a href='$link'>here</a> to pay your order";

    # Get a hash of receipt items
    my  $items = $receipt->items();

    # Get a json view of the receipt
    my  $json = $receipt->json();

=head1 DESCRIPTION

Robokassa L<https://www.robokassa.ru/en/> is one of the largest Russian payment services.

Robokassa::Receipt helps to create Robokassa Receipt object and to meet the Russian law 54-FZ.

The module works only with the L<Robokassa::Pay> interface.

=head1 METHODS

=head2 new ($sno)

    # Create a new receipt object
	my $receipt = Robokassa::Receipt->new();
	# or
    my $receipt = Robokassa::Receipt->new('envd');

Takes only argument $sno - a system of taxation. It can be one of 'osn', 'usn_income', 'usn_income_outcome', 'envd', 'esn', 'patent'.

Ignore $sno if you have only one system of taxation and set it in a Robokassa client account or if you don't need to comply with the Russian law 54-FZ.

=head2 sno($sno)

Set a system of taxation. See the above section for details.

    my $receipt = Robokassa::Receipt->new();
    $receipt->sno('patent');

=head2 add_item(%args)

Adds an item to the receipt.

    # Add an item to the receipt
    $receipt->add_item(
        name => 'Something',
        quantity => 1,
        sum => 1000,
        payment_method => 'full_payment',
        payment_object => 'commodity',
        tax => 'none'
    );

Arguments that may be passed include:

=over 3

=item name

A name of commodity, service and so on.

=item quantity

Quantity of elements.

=item sum

A total amount of the item

=item payment_method

A method of payment. Should be one of 'full_prepayment', 'prepayment', 'advance', 'full_payment', 'partial_payment', 'credit', 'credit_payment'.

=item payment_object

A type of a payment object. Should be one of 'commodity', 'excise', 'job', 'service', 'gambling_bet', 'gambling_prize', 'lottery', 'lottery_prize', 'intellectual_activity', 'payment', 'agent_commission', 'composite', 'another', 'property_right', 'non-operating_gain', 'insurance_premium', 'sales_tax', 'resort_fee'.

=item tax

What tax included? Should be one of 'none', 'vat0', 'vat10', 'vat110', 'vat20', 'vat120'.

=back

=head2 items()

Returns a hash of early added items.

=head2 json()

Returns a JSON representation of the receipt.

=head1 BUGS AND LIMITATIONS

The package works only with L<Robokassa::Pay> interface.

=head1 SEE ALSO

L<Robokassa::Pay> - general payment interface.

=head1 AUTHOR

Ivan Artamonov, <ivan.s.artamonov {at} gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Ivan Artamonov.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut
