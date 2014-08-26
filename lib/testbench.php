<?PHP
include './Averager.php';

$a = new Averager(13);
echo("     13 == " . $a->current());
$a->average(3);
echo("      8 == " . $a->current());
$a->average(5, 12, 8, 7.3);
echo("   8.05 == " . $a->current());

$b = new Averager();
echo("      0 == " . $b->current());
$b->average(13);
echo("     13 == " . $b->current());
$b->average(55, 712.197, 18, 99);
echo("179.439 == " . $b->current());

$c = new Averager();
$c->average(-2147483648, 2147483647, 2147483647, -2147483648);
echo("   -0.5 == " . $c->current());

echo("      6 == " . $a->count());
echo("      5 == " . $b->count());
echo("      4 == " . $c->count());

/*
Output should be exactly:

	 13 == 13
	  8 == 8
   8.05 == 8.05
	  0 == 0
	 13 == 13
179.439 == 179.439
   -0.5 == -0.5
	  6 == 6
	  5 == 5
	  4 == 4

*/
?>