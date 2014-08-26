public class testbench
{
	public static void main(String[] args)
	{
		Averager a = new Averager(13);
		System.out.println("   13.0 == " + a.current());
		a.average(3);
		System.out.println("    8.0 == " + a.current());
		a.average(5, 12, 8, 7.3);
		System.out.println("   8.05 == " + a.current());

		Averager b = new Averager();
		System.out.println("    0.0 == " + b.current());
		b.average(13);
		System.out.println("   13.0 == " + b.current());
		b.average(55, 712.197, 18, 99);
		System.out.println("179.439 == " + b.current());

		Averager c = new Averager();
		c.average(-2147483648, 2147483647, 2147483647, -2147483648);
		System.out.println("   -0.5 == " + c.current());

		System.out.println("      6 == " + a.count());
		System.out.println("      5 == " + b.count());
		System.out.println("      4 == " + c.count());

		/*
		Output should be exactly:

		   13.0 == 13.0
		    8.0 == 8.0
		   8.05 == 8.05
		    0.0 == 0.0
		   13.0 == 13.0
		179.439 == 179.439
		   -0.5 == -0.5
		      6 == 6
		      5 == 5
		      4 == 4

		*/
	}
}