#!/bin/bash
testarray1=""\
"100:1:1:${msg_type1} "\
"100:2:1:${msg_type1} "\
"100:5:1:${msg_type1} "\
"100:10:1:${msg_type1} "\
"100:50:1:${msg_type1} "\
"100:100:1:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:1:${msg_type2} "\
"1024:2:1:${msg_type2} "\
"1024:5:1:${msg_type2} "\
"1024:10:1:${msg_type2} "\
"1024:50:1:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

xIFS=$IFS
IFS=$';'
for testarray in ${testarray1} ${testarray2}; do
	echo "testarray=${testarray}"
	IFS=$xIFS
	for parameters in ${testarray}; do
      if [ -n "${parameters}" ]; then
        # Parse parameters for a single test
        echo "parameters=${parameters}"
        exit
      fi
    done
done
	