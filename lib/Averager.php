<?PHP
/**
 * Averages very many numbers while using only 128 bits of memory (one floating-point and one integer), to store the average
 * information. This also allows for a more accurate result than adding all and dividing by the number of inputs. The downside
 * is that you sacrifice speed, but rigorous testing of this speed loss has not yet been performed.
 * 
 * @license MIT to Blue Husky Programming, ©2012
 * @author Kyli Rouge of Blue Husky Studios
 * @since 2012-04-06
 * @version 1.0.1
 * 		- 2014-08-13 (1.0.1) - Kyli Rouge translated it to PHP
 * 		- 2012-04-06 (1.0.0) - Kyli Rouge made base code
 */

class Averager
{
	/** Holds the current average. If $startingNumber is specified, it is used. Else, this is 0 */
	private $currentAverage;
	/**
	 * Remembers the number of times we've averaged this, to ensure proportional division. If $startingNumber is specified, this
	 * is 1. Else, it is 0.
	 */
	private $timesAveraged;

	public function __construct()
	{
		$this->currentAverage = 0;
		$this->timesAveraged = 0;
	}

	public function __construct($startingNumber)
	{
		$this->currentAverage = $startingNumber;
		$this->timesAveraged = 1;
	}

	/**
	 * Adds the given numbers to the average. Any number of arguments can be given.
	 * 
	 * @param $d one or more numbers to average.
	 * @return a copy of this, so calls can be chained. For example: $avgr->average($arrayOfNumbers)->average(123, 654);
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public function addToAverage(...$d)
	{
		for ($d as $e)
			$this->addToAverage(e);
		return $this;
	}

	/**
	 * Adds the given number to the average.
	 * 
	 * @param $d one number to average.
	 * @return a copy of this, so calls can be chained. For example: $avgr->average($myNumber)->average(123);
	 * 
	 * @author Kyli Rouge
	 * @since 2012-04-06
	 * @version 1.0.0
	 */
	public function addToAverage($d)
	{
		$this->currentAverage = (($this->currentAverage * $this->timesAveraged) + $d) / ++$this->timesAveraged;
		return $this;
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
	public function getCurrentAverage()
	{
		return $this->currentAverage;
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
	public function getTimesAveraged()
	{
		return $this->timesAveraged;
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
	public function clearAverage()
	{
		$this->currentAverage = 0;
		$this->timesAveraged = 0;
		return $this;
	}
}
?>