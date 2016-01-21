#!/usr/bin/tclsh

package require csv
package require struct::matrix

::struct::matrix data

namespace eval zubzub {
	variable STAKE_FACTOR 
}

proc zubzub::init {} {

	set chan [open data2.csv]
	csv::read2matrix $chan data , auto
	close $chan	

	set rows [data rows]

	set idx 0; #file cursor
	set cust_id 0; # column:1

	for {set row 0} {$row < $rows} {incr row} {
		zubzub::populate_row $row cust_id [data get cell 1 $row]
		zubzub::populate_row $row aud_op [data get cell 2 $row]
		zubzub::populate_row $row prev_sf [data get cell 3 $row]
		zubzub::populate_row $row curr_sf [data get cell 3 $row]
	}

}

proc zubzub::populate_row { row key value } {
	variable STAKE_FACTOR

	set STAKE_FACTOR($row,$key) $value
}

proc zubzub::display_array {} {
	variable STAKE_FACTOR

	parray STAKE_FACTOR
}


# initialize + parse
zubzub::init

# alter row 8
zubzub::populate_row 8 curr_sf {1.00}

# a helper to display the array contents
zubzub::display_array