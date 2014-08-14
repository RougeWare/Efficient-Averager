/**
 * Averages very many numbers while using only 128 bits of memory (one floating-point and one integer), to store the average
 * information. This also allows for a more accurate result than adding all and dividing by the number of inputs. The downside
 * is that you sacrifice speed, but rigorous testing of this speed loss has not yet been performed.
 * 
 * @license MIT to Blue Husky Programming, ©2012
 * @author Kyli Rouge of Blue Husky Studios
 * @since 2012-04-06
 * @version 1.0.1
 * 		- 2014-08-13 (1.0.1) - Kyli Rouge reformatted and documented the code for GitHub
 * 		- 2012-04-06 (1.0.0) - Kyli Rouge made base code
 */

public class Averager extends Number
{
	/** Holds the current average. If startingNumber is specified, it is used. Else, this is 0 */
	private double currentAverage;
	/**
	 * Remembers the number of times we've averaged this, to ensure proportional division. If startingNumber is specified, this
	 * is 1. Else, it is 0.
	 */
	private long timesAveraged;

	public Averager()
	{
		currentAverage = 0;
		timesAveraged = 0;
	}

	public Averager(double startingNumber)
	{
		currentAverage = startingNumber;
		timesAveraged = 1;
	}

	/**
	 * Adds the given numbers to the average. Any number of arguments can be given.
	 * 
	 * @param d one or more numbers to average.
	 * @return a copy of this, so calls can be chained. For example: avgr.average(arrayOfNumbers).average(123, 654);
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public strictfp Averager addToAverage(double... d)
	{
		for (double e : d)
			addToAverage(e);
		return this;
	}

	/**
	 * Adds the given number to the average.
	 * 
	 * @param d one number to average.
	 * @return a copy of this, so calls can be chained. For example: avgr.average(myNumber).average(123);
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public strictfp Averager addToAverage(double d)
	{
		currentAverage = ((currentAverage * timesAveraged) + d) / ++timesAveraged;
		return this;
	}

		
	/**
	 * Returns the current average
	 * 
	 * @return the current average, as a floating-point number
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public double getCurrentAverage()
	{
		return currentAverage;
	}

	/**
	 * Returns the number of times this has been averaged
	 * 
	 * @return the number of times this has been averaged, as an integer
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public long getTimesAveraged()
	{
		return timesAveraged;
	}
	
	/**
	 * Returns the number of times this has been averaged
	 * 
	 * @return the number of times this has been averaged, as an integer
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public Averager clearAverage()
	{
		currentAverage = 0;
		timesAveraged = 0;
		return this;
	}

	/**
	 * @deprecated This might be inaccurate. Use {@link #doubleValue()} instead.
	 * 
	 * Returns the value of the current average as an int.
	 * 
	 * @return the value of the current average, as a 32-bit integer.
	 * 
	 * @see #doubleValue()
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	@Override
	public int intValue()
	{
		return (int)longValue();
	}

	/**
	 * @deprecated This might be inaccurate. Use {@link #doubleValue()} instead.
	 * 
	 * Returns the value of the current average as an int.
	 * 
	 * @return the value of the current average, as a 64-bit integer.
	 * 
	 * @see #doubleValue()
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	@Override
	public long longValue()
	{
		return (long)doubleValue();
	}

	/**
	 * @deprecated This might be inaccurate. Use {@link #doubleValue()} instead.
	 * 
	 * Returns the value of the current average as a float.
	 * 
	 * @return the value of the current average, as a 32-bit floating-point number.
	 * 
	 * @see #doubleValue()
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	@Override
	public float floatValue()
	{
		return (float)doubleValue();
	}

	/**
	 * Returns the value of the current average as a double.
	 * 
	 * @return the value of the current average, as a 64-bit floating-point number.
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	@Override
	public double doubleValue()
	{
		return getCurrentAverage();
	}
}
