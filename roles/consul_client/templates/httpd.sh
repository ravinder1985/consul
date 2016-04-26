service httpd status | grep "active (running)"
if [[ $? > 0 ]]; then
        exit 2
else
         exit 0
fi
