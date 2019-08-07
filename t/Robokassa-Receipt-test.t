use strict;
use warnings;

use Test::More tests => 6;

use_ok('Robokassa::Receipt');


subtest 'new() tests' => sub {
        plan tests => 3;

        ok(Robokassa::Receipt->can('new'), 'method new() is available');

        my $receipt = Robokassa::Receipt->new();

        isa_ok($receipt, 'Robokassa::Receipt', 'new() returns an instance of Robokassa::Receipt');

        eval {
            $receipt = Robokassa::Receipt->new('bad_sno');
        };

        like($@, qr/Wrong sno passed/, 'Wrong sno check ok');
    };

subtest 'sno() tests' => sub {

        plan tests => 4;

        ok(Robokassa::Receipt->can('sno'), 'method sno() is available');

        my $receipt = Robokassa::Receipt->new();

        eval {
                $receipt -> sno('bad_sno');
        };

        like($@, qr/Wrong sno passed/, 'Wrong sno check ok');

        foreach (qw (osn usn_income usn_income_outcome envd esn patent))
        {
                eval
                {
                        $receipt -> sno($_);
                };
        }

            ok(!$@, 'sno check ok');
            is($receipt -> {sno},'patent', 'sno set ok');
    };


subtest 'add_item() tests' => sub {

            plan tests => 20;

            ok(Robokassa::Receipt->can('add_item'), 'method add_item() is available');

            my $receipt = Robokassa::Receipt->new();

            ok(exists($receipt->{items}), 'Empty items elem exists');
            isa_ok($receipt->{items}, 'ARRAY', 'Array items elem ok');

            eval {
                    $receipt -> add_item(name => 'Something');
            };

            like($@, qr/sum is not defined/, 'Mandatory sum check ok');

            eval {
                    $receipt -> add_item(sum => 1000);
            };

            like($@, qr/name is not defined/, 'Mandatory name check ok');

            eval {
                    $receipt -> add_item(name => 'Something', sum => 10.10);
            };

            ok(!$@, 'Float sum check ok');

            eval {
                    $receipt -> add_item(name => 'Something', sum => '10!10');
            };

            like($@, qr/Wrong sum/, 'Wrong sum check ok');

            eval {
                    $receipt -> add_item(
                        name           => 'Something',
                        sum            => 1000,
                        quantity => 'a');
            };

            like($@, qr/Wrong quantity/, 'Wrong quantity check ok');

            eval {
                    $receipt -> add_item(Foo => 'Bar');
            };

            like($@, qr/Unknown parameter: Foo/, 'Unknown parameter check ok');

            foreach (qw (payment_method payment_object tax)) {

                    eval {
                            $receipt->add_item(
                                name           => 'Something',
                                sum            => 1000,
                                $_ => 'foobar'
                            );
                    };
                    #print $@."\n";

                    ok( $@ =~ m/^Unknown $_ value: foobar/, "Wrong $_ check ok");
            }

            $receipt = Robokassa::Receipt->new();
            $receipt -> add_item(name => 'Something', sum => 1000);
            is($receipt->{items}->[0]->{quantity}, 1, 'Default quantity creating ok');

            $receipt->add_item(
                name => 'Something2',
                quantity => 2,
                sum => 2000,
                payment_method => 'full_payment',
                payment_object => 'commodity',
                tax => 'none'
            );

            is(scalar @{$receipt->{items}}, 2, 'Adding to items array ok');
            is($receipt->{items}->[1]->{name}, 'Something2', 'name item adding ok');
            is($receipt->{items}->[1]->{quantity}, 2, 'quantity item adding ok');
            is($receipt->{items}->[1]->{sum}, 2000, 'sum item adding ok');
            is($receipt->{items}->[1]->{payment_method}, 'full_payment', 'payment_method item adding ok');
            is($receipt->{items}->[1]->{payment_object}, 'commodity', 'payment_object item adding ok');
            is($receipt->{items}->[1]->{tax}, 'none', 'tax item adding ok');

    };


subtest 'items() tests' => sub {

            plan tests => 8;

            ok(Robokassa::Receipt->can('items'), 'method items() is available');

            my $receipt = Robokassa::Receipt->new();

            $receipt->add_item(
                name => 'Something2',
                quantity => 2,
                sum => 2000,
                payment_method => 'full_payment',
                payment_object => 'commodity',
                tax => 'none'
            );

            isa_ok($receipt->items(), 'ARRAY', 'Array items elem ok');

            is($receipt->items()->[0]->{name}, 'Something2', 'name item adding ok');
            is($receipt->items()->[0]->{quantity}, 2, 'quantity item adding ok');
            is($receipt->items()->[0]->{sum}, 2000, 'sum item adding ok');
            is($receipt->items()->[0]->{payment_method}, 'full_payment', 'payment_method item adding ok');
            is($receipt->items()->[0]->{payment_object}, 'commodity', 'payment_object item adding ok');
            is($receipt->items()->[0]->{tax}, 'none', 'tax item adding ok');
    };


subtest 'json() tests' => sub {

            plan tests => 2;

            ok(Robokassa::Receipt->can('json'), 'method json() is available');

            my $receipt = Robokassa::Receipt->new();

            $receipt->add_item(
                name => 'Something2',
                sum => 2000
            );

            my $json = $receipt->json();

            ok( $json =~ m/^\{"items":\[\{".*\}$/, 'JSON ok');

    };

