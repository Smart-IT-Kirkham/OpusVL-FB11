test('ID Test', function() {
    equal( $.tablesorter.getParser().id , 'opus-dates', 'ID correct' );
});

test('Type Test', function() {
    equal( $.tablesorter.getParser().type , 'text', 'Type correct' );
});

test('Match test', function() {
    ok( !$.tablesorter.getParser().is('test') , 'Not a date' );
    // our parser is only interested in the one date format
    // so we should reject anything else.
    ok( !$.tablesorter.getParser().is('2012-04-30') , 'Not a date' );
    ok( !$.tablesorter.getParser().is('') , 'Not a date' );
    ok( !$.tablesorter.getParser().is() , 'Not a date' );

    ok( $.tablesorter.getParser().is('20-Jan-2012') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Jan-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Jun-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Mar-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Feb-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Apr-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Jul-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-May-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Aug-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Sep-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Oct-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('20-Nov-2012 00:00') , 'A date' );
    ok( $.tablesorter.getParser().is('01-Dec-2012 10:00') , 'A date' );
});

test('Format test', function() {
    equal( $.tablesorter.getParser().format('20-Jan-2012 00:00') , '2012-01-20 00:00', 'Reformatted date' );
    equal( $.tablesorter.getParser().format('20-Jun-2012 00:00'), '2012-06-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Mar-2012 00:00'), '2012-03-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Feb-2012 00:00'), '2012-02-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Apr-2012 00:00'), '2012-04-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Jul-2012 00:00'), '2012-07-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-May-2012 00:00'), '2012-05-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Aug-2012 00:00'), '2012-08-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Sep-2012 00:00'), '2012-09-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Oct-2012 00:00'), '2012-10-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('20-Nov-2012 00:00'), '2012-11-20 00:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('01-Dec-2012 10:00'), '2012-12-01 10:00', 'Reformatted date');
    equal( $.tablesorter.getParser().format('01-Dec-2012'), '2012-12-01', 'Reformatted date');
});
