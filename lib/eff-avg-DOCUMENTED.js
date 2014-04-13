/*
 * This is functionally exactly the same as eff-avg.js, but documented, unrolled, and with unnecessary bits re-added to help
 * make it more easily understood. Note, also, that this is not the same as if whitespace had been added to eff-avg.js
 * 
 * !! DO NOT USE THIS in a production environment !!
 * This file is 3,511 Bytes, and eff-avg.js is only 252 Bytes.
 */


/**
 * Averages very many numbers while using at most 128 bits of memory (one floating-point and one integer), to store the average
 * information. This also allows for a more accurate result than adding all and dividing by the number of inputs. The downside
 * is that you sacrifice speed, but rigorous testing of this speed loss has not yet been performed.
 * 
 * @param startingNumber an optional number to start from
 * 
 * @license MIT
 * @author Kyli Rouge of Blue Husky Studios
 * @since 2014-04-09 (based off a version designed 2012-04-06 in Java)
 * @version 1.1.1
 * 		- 2014-04-12 (1.1.1) - Kyli Rouge improved documentation
 * 		- 2014-04-09 (1.1.0) - Kyli Rouge added current() and count() methods to reliably access variables
 * 		- 2014-04-09 (1.0.0) - Kyli Rouge made base code
 */

var Averager = function(startingNumber)
{
	/** The value that will be returned */
	var self = {
		/** Holds the current average. If startingNumber is specified, it is used. Else, this is 0 */
		currentAverage : startingNumber || 0,
		/**
		 * Remembers the number of times we've averaged this, to ensure proportional division. If startingNumber is specified,
		 * this is 1. Else, it is 0.
		 */
		timesAveraged : startingNumber ? 1 : 0,
		
		/**
		 * Adds the given numbers to the average. Any number of arguments can be given.
		 * 
		 * @param [arguments] a list of numbers to average. This is a vararg, not an array, so you don't have to worry about
		 * 		putting it in an array
		 * @return a copy of this, so calls can be chained. For example: avgr.average(arrayOfNumbers).average(123, 654);
		 * 
		 * @author Kyli Rouge
		 * @since 2014-04-09
		 * @version 1.0.0
		 */
		average : function()
		{
			var d = arguments; // store the arguments in a variable
			if (d.length == 1 && d[0] instanceof Array) // if they passed an array instead of listing them manually
				d = d[0]; // reassign d to be the array in its first slot
			for (var e in d) // for all items given
				this.currentAverage = // set the current average to:
					(
						(this.currentAverage * this.timesAveraged) // the old average times the old number of times averaged
						+ d[e] // plus the current item to be averaged
					)
					/ ++this.timesAveraged; // divide this value by the new number of times averaged
			return this; // return the Averager so they can chain .addToAverager() calls
		},
		
		/**
		 * Returns the current average
		 * 
		 * @return the current average, as a floating-point number
		 * 
		 * @author Kyli Rouge
		 * @since 2014-04-09
		 * @version 1.0.0
		 * 		- 2014-04-09 (1.0.0) - Kyli Rouge added to reliably access the current average, even in minified code
		 */
		current : function()
		{
			return this.currentAverage;
		},
		
		/**
		 * Returns the number of times this has been averaged
		 * 
		 * @return the number of times this has been averaged, as an integer
		 * 
		 * @author Kyli Rouge
		 * @since 2014-04-09
		 * @version 1.0.0
		 * 		- 2014-04-09 (1.0.0) - Kyli Rouge added to reliably access the average counter, even in minified code
		 */
		count : function()
		{
			return this.timesAveraged;
		}
	};
	return self;
};
