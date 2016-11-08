proc gen_h_file { } {

set month [clock format [clock seconds] -format {%m}];
set day [clock format [clock seconds] -format  {%d}];
set year [clock format [clock seconds] -format {%y}];
set hour [clock format [clock seconds] -format {%H}];
set min [clock format [clock seconds] -format {%M}];

#generate custom include files for turning on different features
set out_file [open "../rtl/ver_info.v" w];

#build version
puts $out_file "`define VER_MAJOR  8'h2";
puts $out_file "`define VER_MINOR  8'h0";
puts $out_file "`define VER_CONFIG 8'h0";
puts $out_file "";

#build date-time
puts $out_file [format "`define BUILD_YEAR %s"  8'h$year];
puts $out_file [format "`define BUILD_MONTH %s" 8'h$month];
puts $out_file [format "`define BUILD_DAY %s"   8'h$day];
puts $out_file [format "`define BUILD_HOUR %s"  8'h$hour];
puts $out_file [format "`define BUILD_MIN %s"   8'h$min];
puts $out_file "";

flush $out_file;
close $out_file;
post_message "running build version script"
}

# This line accommodates script automation, described later
#foreach { flow project revision } $quartus(args) { break }

gen_h_file;
