init_acq2106_leds() {
	let px=1
	for led in FMC1_G FMC2_G FMC3_G FMC4_G FMC5_G FMC6_G \
			   FMC1_R FMC2_R FMC3_R FMC4_R FMC5_R FMC6_R \
			   ACT_G  ACT_R
	do		
		ln -s /dev/gpio/$1/$(printf P%02d $px)/value /dev/gpio/LED/$led
		let px=$px+1	
	done
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

lp3943_exists() {
	if [ -e /sys/bus/i2c/devices/${1}/lp3943-gpio.* ] ; then
		echo 1
	else
		echo 0
	fi
}

PWMCHIP=$(getchip 1-0060)
FPCHIP1=$(getchip 1-0061)
FPCHIP2=$(getchip 1-0062)
