# NAME

Robokassa::Receipt - creates a Receipt object for Robokassa::Pay interface.

# VERSION

version 0.001

# SYNOPSIS

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

# DESCRIPTION

Robokassa [https://www.robokassa.ru/en/](https://www.robokassa.ru/en/) is one of the largest Russian payment services.

Robokassa::Receipt helps to create Robokassa Receipt object and to meet the Russian law 54-FZ.

The module works only with the [Robokassa::Pay](https://metacpan.org/pod/Robokassa::Pay) interface.

# METHODS

## new ($sno)

    # Create a new receipt object
        my $receipt = Robokassa::Receipt->new();
        # or
    my $receipt = Robokassa::Receipt->new('envd');

Takes only argument $sno - a system of taxation. It can be one of 'osn', 'usn\_income', 'usn\_income\_outcome', 'envd', 'esn', 'patent'.

Ignore $sno if you have only one system of taxation and set it in a Robokassa client account or if you don't need to comply with the Russian law 54-FZ.

## sno($sno)

Set a system of taxation. See the above section for details.

    my $receipt = Robokassa::Receipt->new();
    $receipt->sno('patent');

## add\_item(%args)

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

- name

    A name of commodity, service and so on.

- quantity

    Quantity of elements.

- sum

    A total amount of the item

- payment\_method

    A method of payment. Should be one of 'full\_prepayment', 'prepayment', 'advance', 'full\_payment', 'partial\_payment', 'credit', 'credit\_payment'.

- payment\_object

    A type of a payment object. Should be one of 'commodity', 'excise', 'job', 'service', 'gambling\_bet', 'gambling\_prize', 'lottery', 'lottery\_prize', 'intellectual\_activity', 'payment', 'agent\_commission', 'composite', 'another', 'property\_right', 'non-operating\_gain', 'insurance\_premium', 'sales\_tax', 'resort\_fee'.

- tax

    What tax included? Should be one of 'none', 'vat0', 'vat10', 'vat110', 'vat20', 'vat120'.

## items()

Returns a hash of early added items.

## json()

Returns a JSON representation of the receipt.

# BUGS AND LIMITATIONS

The package works only with [Robokassa::Pay](https://metacpan.org/pod/Robokassa::Pay) interface.

# SEE ALSO

[Robokassa::Pay](https://metacpan.org/pod/Robokassa::Pay) - general payment interface.

# AUTHOR

Ivan Artamonov, &lt;ivan.s.artamonov {at} gmail.com>

# LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Ivan Artamonov.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
