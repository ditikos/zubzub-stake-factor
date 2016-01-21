#!/usr/bin/tclsh

package require csv
package require struct::matrix

::struct::matrix data

namespace eval zubzub {
	variable STAKE_FACTOR 
	variable idx
}

proc zubzub::init {} {

	variable idx

	set chan [open data.csv]
	csv::read2matrix $chan data , auto
	close $chan	

	set rows [data rows]

	set idx 0; #file cursor
	set cust_id 0; # column:1

	for {set row 0} {$row < $rows} {incr row} {

		set aud_op [data get cell 2 $row]
		if {$aud_op == "D"} {
			set prev_sf [data get cell 4 $row]
			set curr_sf {1.00}
			zubzub::set_row $idx cust_id   [data get cell 0 $row]
			zubzub::set_row $idx prev_sf   $prev_sf
			zubzub::set_row $idx user_id   [data get cell 1 $row]
			zubzub::set_row $idx user_time [data get cell 3 $row]
			zubzub::set_row $idx curr_sf   $curr_sf
			if {$cust_id!=[data get cell 1 $row]} {
				incr idx
			}
		} elseif {$aud_op == "I"} {			
			if {$cust_id != [data get cell 0 $row]} {
				set prev_sf {1.00}
				set curr_sf [data get cell 4 $row]
				zubzub::set_row $idx cust_id   [data get cell 0 $row]
				zubzub::set_row $idx prev_sf   $prev_sf
				zubzub::set_row $idx curr_sf   $curr_sf
				zubzub::set_row $idx user_id   [data get cell 1 $row]
				zubzub::set_row $idx user_time [data get cell 3 $row]				
				incr idx
			} else {
				zubzub::set_row $idx cust_id   [data get cell 0 $row]
				zubzub::set_row $idx user_id   [data get cell 1 $row]
				zubzub::set_row $idx user_time [data get cell 3 $row]				
				if {$prev_sf == [data get cell 4 $row]} {
					# empty
				} else {
					set curr_sf [data get cell 4 $row]
					zubzub::set_row $idx curr_sf   [data get cell 4 $row]
					zubzub::set_row $idx prev_sf   $prev_sf
					incr idx
				}
			}
		}


		set cust_id [data get cell 0 $row]
	}

}

proc zubzub::set_row { row key value } {
	variable STAKE_FACTOR

	set STAKE_FACTOR($row,$key) $value
}

proc zubzub::get_row { row key } {
	variable STAKE_FACTOR
	return $STAKE_FACTOR($row,$key)
}


proc zubzub::display_array {} {
	variable STAKE_FACTOR
	variable idx

	#parray STAKE_FACTOR
	for {set i 0} {$i<$idx} {incr i} {
		puts [list $i $STAKE_FACTOR($i,cust_id) $STAKE_FACTOR($i,user_time) $STAKE_FACTOR($i,prev_sf) $STAKE_FACTOR($i,curr_sf)]
	}
}


# initialize + parse
zubzub::init

# a helper to display the array contents
zubzub::display_array