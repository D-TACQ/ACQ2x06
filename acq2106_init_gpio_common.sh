
init_dummy_leds() { 
	for led in FMC1_G FMC2_G FMC3_G FMC4_G FMC5_G FMC6_G \
			   FMC1_R FMC2_R FMC3_R FMC4_R FMC5_R FMC6_R \
			   ACT_G  ACT_R
	do
	    echo 1 > /dev/gpio/LED/$led
	done
}
init_acq2106_leds() {
	let px=1
	for led in FMC1_G FMC2_G FMC3_G FMC4_G FMC5_G FMC6_G \
			   FMC1_R FMC2_R FMC3_R FMC4_R FMC5_R FMC6_R \
			   ACT_G  ACT_R
	do
	    rm -f /dev/gpio/LED/$led
		ln -s /dev/gpio/$1/$(printf P%02d $px)/value /dev/gpio/LED/$led
		let px=$px+1	
	done
}

init_acq2106d37_leds() {
    let px=0
    for led in FMC1_G FMC3_G FMC5_G \
			   FMC1_R FMC3_R FMC5_R \
			   ACT_G ACT_R CLK_G CLK_R TRG_G TRG_R   
    do
    	rm -f /dev/gpio/LED/$led
    	ln -s /dev/gpio/$1/$(printf P%02d $px)/value /dev/gpio/LED/$led
        let px=$px+1
	done
	
	rm -f /dev/gpio/LED/FPGA_DONE
	ln -s /dev/gpio/$1/$(printf P%02d 15)/value /dev/gpio/LED/FPGA_DONE
    echo 1 > /dev/shm/is_d37
}

create_set_fanspeed() {
		# acq2006 only		 
	cat - >/usr/local/bin/set.fanspeed <<EOF
#!/bin/sh
# set fanspeed acq2006 style
if [ "x\$2" != "x" ]; then
	FAN=\$1
	FSPERCENT=\$2
else
	FAN=0
	FSPERCENT=\${1:-50}
fi
if [ \$FSPERCENT -gt 100 ]; then 
	let FSPERCENT=100
elif [ \$FSPERCENT -lt 0 ]; then
	let FSPERCENT=0
fi
# inverse ratio
let DC="(100-\$FSPERCENT)*1000"
set.sys /sys/class/pwm/pwmchip0/pwm\${FAN}/duty_cycle \$DC
EOF
		
	chmod a+rx /usr/local/bin/set.fanspeed
	echo /usr/local/bin/set.fanspeed created
}



acq2006_create_pwm() {
	if [ -e /sys/class/pwm/pwmchip0/pwm0 ]; then
# inversed control dropped from released driver
#set.sys /sys/class/pwm/pwmchip0/pwm0/polarity inversed
		set.sys /sys/class/pwm/pwmchip0/pwm0/period 100000
		set.sys /sys/class/pwm/pwmchip0/pwm0/duty_cycle 50000
		set.sys /sys/class/pwm/pwmchip0/pwm0/enable 1
		create_set_fanspeed
	fi
	if [ -e /sys/class/pwm/pwmchip0/pwm1 ]; then
# inversed control dropped from released driver
#set.sys /sys/class/pwm/pwmchip0/pwm0/polarity inversed
		set.sys /sys/class/pwm/pwmchip0/pwm1/period 100000
		set.sys /sys/class/pwm/pwmchip0/pwm1/duty_cycle 50000
		set.sys /sys/class/pwm/pwmchip0/pwm0/enable 1		
	fi	
}

HAS_PWMCHIP=false
PWMCHIP=$(getchip 1-0060)
[ "x$PWMCHIP" != "x" ] && HAS_PWMCHIP=true

HAS_FPCHIP1=false
FPCHIP1=$(getchip 1-0061)
[ "x$FPCHIP1" != "x" ] && HAS_FPCHIP1=true

HAS_FPCHIP2=false
FPCHIP2=$(getchip 1-0062)
[ "x$FPCHIP2" != "x" ] && HAS_FPCHIP2=true

HAS_D37=false
MODEL=$(cat /proc/device-tree/chosen/model)
[ "${MODEL#*d37}" != "$MODEL" ] && HAS_D37=true

