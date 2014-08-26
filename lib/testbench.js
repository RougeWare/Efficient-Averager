var a = new Averager(13);
console.log("     13 == " + a.current());
a.average(3);
console.log("      8 == " + a.current());
a.average(5, 12, 8, 7.3);
console.log("   8.05 == " + a.current());

var b = new Averager();
console.log("      0 == " + b.current());
b.average(13);
console.log("     13 == " + b.current());
b.average(55, 712.197, 18, 99);
console.log("179.439 == " + b.current());

var c = new Averager();
c.average(-2147483648, 2147483647, 2147483647, -2147483648);
console.log("   -0.5 == " + c.current());

console.log("      6 == " + a.count());
console.log("      5 == " + b.count());
console.log("      4 == " + c.count());

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